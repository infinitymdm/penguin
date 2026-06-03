`timescale 1 ns / 1 ps

module tb_sha3_pipelined #(
    parameter    int D = 512, // 512, 384, 256, 224 all work
    parameter    int R = 1600 - 2*D,
    parameter string M = "../README.md",
    parameter string EXPECTED_DIGEST = "cc06f7362fa672954deea15583e881c9282863c6d0d726e1a27c69ac2ff8da612643c17e1e1fa0d018c9acd047c7547170975b33f8c9a3c22dcfccb3d5528ef8"
);

    int message_file;
    int cycle_counter;

    bit clk, reset, enable;
    bit         op;
    bit   [4:0] round;
    bit [R-1:0] message;
    bit [D-1:0] digest, expected_digest;

    keccak_pipelined #(D) dut (
        .clk, .reset, .enable,
        .op, .round,
        .message, .digest
    );
    assign op = cycle_counter % 2;

    initial begin: dump_vcd
        `ifdef SILICONCOMPILER_TRACE_FILE
            $dumpfile(`SILICONCOMPILER_TRACE_FILE);
        `else
            $dumpfile("wave.vcd");
        `endif
        $dumpvars(0, tb_sha3_pipelined);
    end

    initial begin: init_and_reset
        clk = 1'b1;
        enable = 1'b0;
        reset = 1'b1;
        message = '0;
        cycle_counter = 1;
        round = 23;
        #10;
        enable = 1'b1;
        #5;
        reset = 1'b0;
    end
    always #5 clk <= ~clk;

    initial begin: open_message_file
        message_file = $fopen(M, "rb");
        if (message_file == 0) $error("Unable to open file '%s'", M);
    end

    task automatic read_message_chunk (input int m_file, output bit [R-1:0] m);
        int pad_count = 0;
        byte c;
        byte message_byte;
        for (int i = 0; i < R/8; i++) begin: get_message_byte
            c = $fgetc(m_file);
            if (!$feof(m_file)) begin: read_byte
                // Read as long as there are bytes
                message_byte = c;
            end else begin: pad_byte
                // Once out of bytes to read, pad according to SHA3
                pad_count++;
                case ({pad_count == 1, i == R/8-1})
                    2'b00: message_byte = 8'h00;
                    2'b01: message_byte = 8'h80;
                    2'b10: message_byte = 8'h06;
                    2'b11: message_byte = 8'h86;
                endcase
            end
            m = {m[R-9:0], message_byte};
        end
    endtask

    always @(posedge clk) begin: inc_cycles
        cycle_counter++;
        if ((op == 0)) round = (round < 23) ? round + 1 : 0;
    end

    always @(negedge clk) begin: stimulate_dut
        if (!$feof(message_file)) begin: get_message
            if ((round == 23) && op) read_message_chunk(message_file, message);
        end else begin: handle_eof
            #480;
            `ifdef MODEL_TECH
                #10; // If using modelsim, we need 1 more cycle of delay for some reason
            `endif
            enable = 1'b0;
            #1;
            $display("digest:   %h", digest);
            $fclose(message_file);
            $sscanf(EXPECTED_DIGEST, "%h", expected_digest);
            $display("expected: %h", expected_digest);
            if (digest == expected_digest) begin
                $write("%c[1;32m", 27); // Set style bold, green foreground
                $display("PASS");
            end else begin
                $write("%c[1;30m", 27); // Set style bold, red foreground
                $error("FAIL");
            end
            $write("%c[0m", 27); // reset graphics modes
            $finish;
        end
    end

endmodule
