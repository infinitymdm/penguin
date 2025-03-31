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
    string message_full, temp;
    bit [r-1:0] message_chunk;
    bit [d-1:0] expected_digest, digest;

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
        rsp_file = $fopen(rsp_file_name, "r");
        if (rsp_file == 0) $error("Unable to open file '%s'", rsp_file_name);
    end

    task automatic read_test_vector (
        input  int rsp_file,
        output bit eof,
        output int len,
        output string message_full,
        output bit [d-1:0] expected_digest
    );
        string line, value;
        byte digest_byte;

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
        for (int i = 0; 8*i < d; i++) begin: read_expected_digest_bytes
            digest_byte = value.substr(2*i, 2*i+1).atohex();
            expected_digest = {expected_digest[d-9:0], digest_byte};
        end
        eof = $feof(rsp_file);
    endtask

    task automatic get_message_chunk (
        input int len,
        input int index,
        input string message_full,
        output bit [r-1:0] message_chunk,
        output bit no_more_chunks
    );
        int remaining_len = len - (r * index);
        byte message_byte;
        bit [1:0] suffix = 2'b01;

        if (remaining_len < r) begin: pad_chunk
            no_more_chunks = 1;
            // convert one byte at a time until out of bytes
            for (int i = 0; 8*i < remaining_len; i++) begin: read_partial_slice_bytes
                message_byte = message_full.substr(2*i, 2*i+1).atohex();
                message_chunk = {message_chunk[r-9:0], message_byte};
            end
            // pad according to SHA-3 pad10*1 rule
            if (r - remaining_len == 8)
                message_chunk = {message_chunk[r-9:0], 8'h86}; // Special case where only one byte remains
            else begin: pad10_1
                message_chunk = {message_chunk[r-9:0], 8'h06};
                for (int i = 0; 8*i < r - remaining_len - 16; i++)
                    message_chunk = {message_chunk[r-9:0], 8'h00};
                message_chunk = {message_chunk[r-9:0], 8'h80};
            end
        end else begin: slice_chunk
            no_more_chunks = 0;
            // convert one byte at a time until slice is full
            for (int i = 0; 8*i < r; i++) begin: read_full_slice_bytes
                message_byte = message_full.substr(2*i, 2*i+1).atohex();
                message_chunk = {message_chunk[r-9:0], message_byte};
            end
        end
    endtask

    initial begin: init_stimulus
        waited_cycles = 0;
        no_more_chunks = 1;
        chunk_index = 0;
    end

    always @(posedge clk) begin: stimulate_dut
        if (waited_cycles % s == 0)
            if (no_more_chunks) begin: get_next_test_vector
                // Check results if the dut was previously enabled
                if (enable) begin: check_result
                    $display("nist:   %h", expected_digest);
                    $display("digest: %h", digest);
                    if (digest == expected_digest) begin: result_pass
                        $write("%c[1;32m", 27); // Set style bold, green foreground
                        $display("PASS");
                        $write("%c[0m", 27); // reset graphics modes
                    end else begin: result_fail
                        $write("%c[1;30m", 27); // Set style bold, red foreground
                        $display("FAIL");
                        $error("Failed on message %s with %d bits!", message_full, len);
                    end
                end

                // Reset and load the next test vector
                enable = 0;
                reset = 1;
                #1;
                reset = 0;
                read_test_vector(rsp_file, eof, len, message_full, expected_digest);
                no_more_chunks = 0; // Force next cycle to fetch a new chunk
                chunk_index = 0;

                // If we reached eof while looking for the next test vector, exit
                if (eof) begin: handle_eof
                    $display("Reached EOF. Exiting...");
                    $fclose(rsp_file);
                    $finish;
                end
            end else begin: get_next_chunk
                // Load the next chunk of the message (with padding applied as appropriate)
                get_message_chunk(len, chunk_index, message_full, message_chunk, no_more_chunks);
                chunk_index++;
                enable = 1;
            end
        waited_cycles++;
    end

endmodule
