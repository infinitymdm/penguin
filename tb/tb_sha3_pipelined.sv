`define TO_STRING(x) `"x`"

// The following vars must be defined, usually in a simulator +define+ flag
`ifndef DIGEST_LENGTH
    `error_define_DIGEST_LENGTH_must_be_set
`endif
`ifndef STAGES
    `error_define_STAGES_must_be_set
`endif
`ifndef MESSAGE_FILE
    `error_define_MESSAGE_FILE_must_be_set
`endif

module tb_sha3_pipelined;

    localparam d = `DIGEST_LENGTH;  // 512, 384, 256, 224 all work
    string message_file_name = {"../", `TO_STRING(`MESSAGE_FILE)};

    // Derived
    localparam r = 1600 - 2*d;

    int message_file;
    int cycle_counter;

    bit clk, reset, enable;
    bit   [1:0] op;
    bit   [4:0] round;
    bit [r-1:0] message;
    bit [d-1:0] digest, expected_digest;

    keccak_pipelined #(d) dut (
        .clk, .reset, .enable,
        .op, .round,
        .message, .digest
    );

    initial begin: dump_vcd
        $dumpfile("wave.vcd");
        $dumpvars;
    end

    initial begin: init_and_reset
        clk = 1'b1;
        enable = 1'b0;
        reset = 1'b1;
        message = '0;
        cycle_counter = 2;
        round = 23;
        #10;
        enable = 1'b1;
        #5;
        reset = 1'b0;
    end
    always #5 clk <= ~clk;
    assign op = cycle_counter % 3;

    initial begin: open_message_file
        message_file = $fopen(message_file_name, "rb");
        if (message_file == 0) $error("Unable to open file '%s'", message_file_name);
    end

    task automatic read_message_chunk (input int m_file, output bit [r-1:0] m);
        int pad_count = 0;
        byte c;
        byte message_byte;
        for (int i = 0; i < r/8; i++) begin: get_message_byte
            c = $fgetc(m_file);
            if (!$feof(m_file)) begin: read_byte
                // Read as long as there are bytes
                message_byte = c;
            end else begin: pad_byte
                // Once out of bytes to read, pad according to SHA3
                pad_count++;
                case ({pad_count == 1, i == r/8-1})
                    2'b00: message_byte = 8'h00;
                    2'b01: message_byte = 8'h80;
                    2'b10: message_byte = 8'h06;
                    2'b11: message_byte = 8'h86;
                endcase
            end
            m = {m[r-9:0], message_byte};
        end
    endtask

    task automatic get_expected_digest (input string m_filename, output bit [d-1:0] expected_digest);
        // Call openssl to get the expected result
        int expected_file;
        void'($system({"openssl dgst -sha3-", `TO_STRING(`DIGEST_LENGTH), " ", m_filename, " | awk '{print $2}' > .expected"}));
        expected_file = $fopen(".expected", "r");
        if (expected_file != 0) begin
            void'($fscanf(expected_file, "%h", expected_digest));
            $fclose(expected_file);
        end else begin
            $error("Unable to open file '.expected'");
        end
    endtask

    always @(posedge clk) begin: inc_cycles
        cycle_counter++;
        if ((op == 0)) round = (round < 23) ? round + 1 : 0;
    end

    always @(negedge clk) begin: stimulate_dut
        if (!$feof(message_file)) begin: get_message
            if ((round == 23) && (op == 2)) read_message_chunk(message_file, message);
        end else begin: handle_eof
            #720;
            `ifdef MODEL_TECH
                #10; // If using modelsim, we need 1 more cycle of delay for some reason
            `endif
            enable = 1'b0;
            #1;
            $display("digest:  %h", digest);
            $fclose(message_file);
            get_expected_digest(message_file_name, expected_digest);
            $display("openssl: %h", expected_digest);
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
