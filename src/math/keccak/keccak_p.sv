`timescale 1 ns / 1 ps

module keccak_p #(
    parameter L = 6,
    parameter N = 4,
    parameter W = 2**L,
    parameter B = 25*W
) (
    input  logic clk,
    input  logic enable,
    input  logic reset,
    input  logic [B-1:0] x,
    input  logic [N-1:0][L:0] rc,
    output logic [B-1:0] y
);

    // keccak_p encapsulates n sequentially-connected keccak_rounds, with the result fed into a
    // b-bit register. This allows us to subdivide the keccak function into a multicycle process.
    // See FIPS202 section 3.3 for details.

    logic [B-1:0] m [N+1] /*verilator split_var*/; // Intermediates to connect rounds
    assign m[0] = x;

    // Construct N rounds connected sequentially
    generate
        for (genvar round = 0; round < N; round++) begin: round_select
            keccak_round #(L) keccak_rnd (
                .x(m[round]),
                .rc(rc[round]),
                .y(m[round+1])
            );
        end
    endgenerate

    // Register the output of the final round
    dffre #(.width(B)) state_reg (
        .clk, .reset, .enable,
        .d(m[N]),
        .q(y)
    );

endmodule
