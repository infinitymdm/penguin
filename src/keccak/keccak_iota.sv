module keccak_iota #(
    parameter w = 64
) (
    input  logic [4:0][4:0][w-1:0] x,
    input  logic           [w-1:0] rc,
    output logic [4:0][4:0][w-1:0] y
);

    generate
        for (genvar i = 0; i < 5; i++) begin: sheet_select
            for (genvar j = 0; j < 5; j++) begin: lane_select
                if ((i == 4) & (j == 4)) begin: apply_rc
                    // If yosys supported streaming operators, we'd flip the rc bytes like so:
                    // assign y[i][j] = x[i][j] ^ {<<8{rc}};
                    // Unfortunately yosys doesn't support the {<<{}} streaming operator :(
                    // Instead we have to swap bytes manually, adding this gross for loop
                    for (genvar b = 0; b < w/8; b++) begin: swap_bytes
                        assign y[i][j][8*(b+1)-1:8*b] = x[i][j][8*(b+1)-1:8*b] ^ rc[w-8*b-1:w-8*(b+1)];
                    end
                end else begin: passthrough
                    assign y[i][j] = x[i][j];
                end
            end
        end
    endgenerate

endmodule
