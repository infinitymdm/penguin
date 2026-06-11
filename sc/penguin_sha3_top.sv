`timescale 1 ns / 1 ps

module penguin_sha3_top #(
    parameter D = 512
) (
    input  logic              clk, reset, enable,
    input  logic        [4:0] round,
    input  logic [1599-2*D:0] message,
    output logic      [D-1:0] digest
);
    keccak_pipelined #(.D(D)) sha3_pipelined (.*);
endmodule
