module keccak_p #(
    parameter l = 6,
    parameter n = 4,
    parameter w = 2**l,
    parameter b = 25*w
) (
    input  logic clk,
    input  logic enable,
    input  logic reset,
    input  logic [b-1:0] x,
    input  logic [n-1:0][w-1:0] rc,
    output logic [b-1:0] y
);

    // keccak_p encapsulates n sequentially-connected keccak_rounds, with the result fed into a
    // b-bit register. This allows us to subdivide the keccak function into a multicycle process.
    // See FIPS202 section 3.3 for details.

    logic [b-1:0] m [n+1] /*verilator split_var*/; // Intermediates to connect rounds
    assign m[0] = x;

    // Construct n rounds connected sequentially
    generate
        for (genvar round = 0; round < n; round++) begin: round_select
            keccak_round #(l) keccak_rnd (
                .x(m[round]),
                .rc(rc[round]),
                .y(m[round+1])
            );
        end
    endgenerate

    // Register the output of the final round
    dffre #(.width(b)) state_reg (
        .clk, .reset, .enable,
        .d(m[n]),
        .q(y)
    );

endmodule
