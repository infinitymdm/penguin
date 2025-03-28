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

module tb_sha3_nist;

    localparam d = `DIGEST_LENGTH;  // 512, 384, 256, 224 all work
    localparam s = `STAGES;         // All integer divisors of 24 work
    string rsp_file_name = {"../", `TO_STRING(`MESSAGE_FILE)};

    // Derived
    localparam r = 1600 - 2*d;

    int rsp_file;
    int waited_cycles;
    int len, chunk_index;
    bit eof, no_more_chunks;
    string message_full, expected_digest, temp;
    bit [r-1:0] message_chunk;
    bit [d-1:0] digest;

    bit clk, reset, enable;
    keccak #(d, 6, s) dut (
        .clk, .reset, .enable,
        .message(message_chunk), .digest
    );

    initial begin: dump_vcd
        $dumpfile("wave.vcd");
        $dumpvars;
    end

    initial begin: init_dut
        clk = 0;
        enable = 0;
        reset = 1;
        message_chunk = 0;
    end
    always #5 clk <= ~clk;

    initial begin: open_rsp_file
        rsp_file = $fopen(rsp_file_name, "rb");
        if (rsp_file == 0) $error("Unable to open file '%s'", rsp_file_name);
    end

    task automatic read_test_vector (
        input  int rsp_file,
        output bit eof,
        output int len,
        output string message_full,
        output string expected_digest
    );
        string line, value;

        // scan Len
        while (!$feof(rsp_file)) begin: scan_Len
            $fgets(line, rsp_file);
            if ($sscanf(line, "Len = %s\n", value) == 1) break;
        end
        len = value.atoi();
        // scan Msg
        while (!$feof(rsp_file)) begin: scan_Msg
            $fgets(line, rsp_file);
            if ($sscanf(line, "Msg = %s\n", value) == 1) break;
        end
        message_full = value;
        // scan MD
        while (!$feof(rsp_file)) begin: scan_MD
            $fgets(line, rsp_file);
            if ($sscanf(line, "MD = %s\n", value) == 1) break;
        end
        expected_digest = value;
        eof = $feof(rsp_file);
    endtask

    task automatic get_message_chunk (
        input int len,
        input int index,
        input string message_full,
        output bit [r-1:0] message_chunk,
        output bit no_more_chunks
    );
        int chunk_len = len - (r * index);
        bit [1:0] suffix = 2'b01;

        if (chunk_len < r) begin: pad_chunk
            no_more_chunks = 1;
            // TODO: Iterate over the string one byte at a time. This won't work because atohex only returns integers
            message_chunk = {>>{message_full.atohex()[r*index+:r], suffix}} & 'b01;
        end else begin: slice_chunk
            no_more_chunks = 0;
            message_chunk = message_full.atohex()[r*index+:r];
        end
    endtask

    initial begin: init_stimulus
        waited_cycles = 0;
        no_more_chunks = 1;
        chunk_index = 0;
    end

    string pls_delete_me;

    always @(posedge clk) begin: stimulate_dut
        if (!eof) begin: get_next_message_or_wait_for_next_chunk
            if (no_more_chunks) begin: get_next_test_vector
                read_test_vector(rsp_file, eof, len, message_full, expected_digest);
                $display("Msg = %s", message_full);
                $display("MD = %s", expected_digest);
                chunk_index = 0;
            end else begin: wait_for_next_chunk
                if (waited_cycles % s == 0) begin: get_next_chunk
                    $display("digest = %h", digest);
                    get_message_chunk(len, chunk_index, message_full, message_chunk, no_more_chunks);
                    chunk_index++;
                end
                waited_cycles++;
            end
        end else begin: handle_eof
            enable = 0;
            $fclose(rsp_file);
            $finish;
        end
    end

endmodule
