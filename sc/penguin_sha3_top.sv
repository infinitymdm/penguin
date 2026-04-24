`timescale 1 ns / 1 ps

module penguin_sha3_top (
    input  logic         clk, reset, enable,
    input  logic [575:0] message,
    output logic [511:0] digest
);
    keccak #(.d(512), .l(6), .s(6)) sha3_512_6stage (.*);
endmodule
