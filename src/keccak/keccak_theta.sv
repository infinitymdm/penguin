module keccak_theta #(
    parameter w = 64
) (
    input  logic [4:0][4:0][w-1:0] x,
    output logic [4:0][4:0][w-1:0] y
);

    logic [4:0][w-1:0] C;
    logic [4:0][w-1:0] D;

    generate
        for (genvar i = 0; i < 5; i++) begin: sheet_select
            assign C[i] = x[i][0] ^ x[i][1] ^ x[i][2] ^ x[i][3] ^ x[i][4];
            for (genvar k = 0; k < w/8; k++) begin: byte_select
                // We have to do this awful nonsense to compensate for the difference in endianness from c to sv
                assign D[i][8*k+:8] = {C[(i+4)%5][8*k+:7], C[(i+4)%5][(8*(k+2)-1)%w]} ^ C[(i+1)%5][8*k+:8];
            end
            for (genvar j = 0; j < 5; j++) begin: lane_select
                assign y[i][j] = x[i][j] ^ D[i];
            end
        end
    endgenerate

endmodule
