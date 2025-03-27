module keccak_iota #(
    parameter l = 6,
    parameter w = 2**l
) (
    input  logic [4:0][4:0][w-1:0] x,
    input  logic             [l:0] rc,
    output logic [4:0][4:0][w-1:0] y
);

    generate
        for (genvar i = 0; i < 5; i++) begin: sheet_select
            for (genvar j = 0; j < 5; j++) begin: lane_select
                if ((i == 4) & (j == 4)) begin: apply_rc
                    for (genvar k = 0; k < w; k++) begin: bit_select
                        // Note: The indices are a bit strange here because we're compensating for
                        // byte-endianness. If you reverse the order of the bytes, the indices
                        // match up with Sideris et. al.
                        if (k == 63)        assign y[i][j][k] = x[i][j][k] ^ rc[3];
                        else if (k == 59)   assign y[i][j][k] = x[i][j][k] ^ rc[4];
                        else if (k == 57)   assign y[i][j][k] = x[i][j][k] ^ rc[5];
                        else if (k == 56)   assign y[i][j][k] = x[i][j][k] ^ rc[6];
                        else if (k == 55)   assign y[i][j][k] = x[i][j][k] ^ rc[2];
                        else if (k == 39)   assign y[i][j][k] = x[i][j][k] ^ rc[1];
                        else if (k == 7)    assign y[i][j][k] = x[i][j][k] ^ rc[0];
                        else                assign y[i][j][k] = x[i][j][k];
                    end
                end else begin: passthrough
                    assign y[i][j] = x[i][j];
                end
            end
        end
    endgenerate

endmodule
