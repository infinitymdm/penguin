module keccak_pipelined_datapath #(
    parameter D = 512,      // digest length in bits
    parameter L = 6,        // log base 2 of lane size. L=6 for all SHA3/SHAKE ops.
    parameter W = 2**L,     // lane size (i.e. word length) in bits
    parameter B = 25*W,     // keccak permuation width in bits
    parameter C = 2*D,      // capacity of the sponge function in bits
    parameter R = B - C,    // rate of the sponge function in bits
) (
    input  logic         clk,
    input  logic         reset_pi, reset_chi, reset_iota,
    input  logic         enable_pi, enable_chi, enable_iota,
    input  logic   [4:0] round,
    input  logic [R-1:0] message,
    output logic [D-1:0] digest
);
    logic [23:0][6:0] iota_consts = {
        7'b0010111,
        7'b1000010,
        7'b0001101,
        7'b1001111,
        7'b0110011,
        7'b0110100,
        7'b0001001,
        7'b0100101,
        7'b1100101,
        7'b1011101,
        7'b1111001,
        7'b1111110,
        7'b0110010,
        7'b1010110,
        7'b0011000,
        7'b0111000,
        7'b1010101,
        7'b1001111,
        7'b1000010,
        7'b1111100,
        7'b0000111,
        7'b0111101,
        7'b0101100,
        7'b1000000
    };
    logic [4:0][4:0][w-1:0] x, d_pi, d_chi, d_iota,
                               q_pi, q_chi, q_iota;
    logic [b-1:0] mask = {message, C{1'b0}};
    logic [b-1:0] y;

    generate
        for (genvar i = 0; i < 5; i++) begin: sheet_select
            for (genvar j = 0; j < 5; j++) begin: lane_select
                // organize input vector into a 3D block
                assign x[i][j] = (round == 0) ? y[W*(i+5*j)+:W] ^ mask[W*(i+5*j)+:W]
                                              : y[W*(i+5*j)+:W];

                // registers after pi, chi, and iota phases
                dffre #(.width(W)) pi_reg (
                    .clk,
                    .reset(reset_pi),
                    .enable(enable_pi),
                    .d(d_pi[i][j]),
                    .q(q_pi[i][j])
                );
                dffre #(.width(W)) chi_reg (
                    .clk,
                    .reset(reset_chi),
                    .enable(enable_chi),
                    .d(d_chi[i][j]),
                    .q(q_chi[i][j])
                );
                dffre #(.width(W)), iota_reg (
                    .clk,
                    .reset(reset_iota),
                    .enable(enable_iota),
                    .d(d_iota[i][j]),
                    .q(q_iota[i][j])
                );

                // organize iota output 3D block into a vector
                assign y[W*(i+5*j)+:W] = d_iota[i][j]
        end
    endgenerate

    keccak_theta_rho_pi #(W) trp  (.x,        .y(d_pi));
    keccak_chi          #(W) chi  (.x(q_pi),  .y(d_chi));
    keccak_iota         #(W) iota (.x(q_chi), .y(d_iota), .rc(iota_consts[round]));

endmodule
