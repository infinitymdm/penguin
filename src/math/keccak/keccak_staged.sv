`timescale 1 ns / 1 ps

module keccak_pipelined #(
    parameter D = 512,      // digest length in bits
    parameter L = 6,        // log base 2 of lane size. L=6 for all SHA3/SHAKE ops.
    parameter W = 2**L,     // lane size (i.e. word length) in bits
    parameter B = 25*W,     // keccak permuation width in bits
    parameter C = 2*D,      // capacity of the sponge function in bits
    parameter R = B - C     // rate of the sponge function in bits
) (
    input  logic         clk, reset, enable,
    input  logic         op,
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
    logic [B-1:0] x, y, q;
    logic [4:0][4:0][W-1:0] x_block, y_pi, y_chi, y_iota, y_block;

    assign x = {q[B-1:C] ^ message, q[C-1:0]};
    vector2block #(W) v2b (.vector((round == 0) && (op == 0) ? x : q), .block(x_block));

    // op 0: fused & optimized theta/rho/pi
    keccak_theta_rho_pi #(W) theta_rho_pi (.x(x_block), .y(y_pi));

    // op 1: fused chi/iota
    keccak_chi          #(W) chi          (.x(x_block), .y(y_chi));
    keccak_iota         #(L) iota         (.x(y_chi), .y(y_iota), .rc(iota_consts[round]));

    assign y_block = op ? y_iota : y_pi;

    block2vector #(W) b2v (.block(y_block), .vector(y));
    dffre #(.width(B)) iota_reg (.clk, .reset, .enable, .d(y), .q);
    assign digest = q[B-1-:D];

endmodule
