`timescale 1 ns / 1 ps

module penguin_sha3_top (
    input  logic         clk, reset, enable,
    input  logic   [1:0] op,
    input  logic   [4:0] round,
    input  logic [575:0] message,
    output logic [511:0] digest
);
    keccak_pipelined #(.D(512)) sha3_512_pipelined (.*);
endmodule
