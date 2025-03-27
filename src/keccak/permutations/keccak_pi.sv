module keccak_pi #(
    parameter w = 64
) (
    input  logic [4:0][4:0][w-1:0] x,
    output logic [4:0][4:0][w-1:0] y
);

    generate
        for (genvar i = 0; i < 5; i++) begin: sheet_select
            for(genvar j = 0; j < 5; j++) begin: lane_select
                assign y[j][(2*i+3*j+4)%5] = x[i][j];
            end
        end
    endgenerate

endmodule
