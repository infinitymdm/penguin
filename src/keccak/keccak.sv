module keccak #(
    parameter d = 512,      // digest length in bits
    parameter l = 6,        // log base 2 of the lane size. Use l=6 for all SHA3/SHAKE ops.
    parameter s = 6,        // number of stages (i.e. number of cycles for one sponge operation)
    parameter w = 2**l,     // lane size (i.e. word length)
    parameter b = 25*w,     // keccak permutation width (i.e. state vector length)
    parameter c = 2*d,      // capacity of the sponge function
    parameter r = b - c,    // rate of the sponge function
    parameter n = 12 + 2*l, // total number of rounds
    parameter q = n / s     // number of rounds per stage
) (
    input  logic         clk,
    input  logic         reset,
    input  logic         enable,
    input  logic [r-1:0] message,
    output logic [d-1:0] digest
);

    // keccak encapsulates the necessary hardware required to implement the keccak[c] function as
    // described in FIPS202 section 5.2.

    // TODO: implement the below
    // - SHA3 and SHAKE suffixes
    // - padding function
    // - iota_const generation

    // Note: These work for all SHA3/SHAKE algorithms (i.e., where l=6).
    // See FIPS202 section 3.2.5 for details on how to generate constants for l!=6.
    logic [23:0][63:0] iota_consts = {
        64'h8000000080008008,
        64'h0000000080000001,
        64'h8000000000008080,
        64'h8000000080008081,
        64'h800000008000000a,
        64'h000000000000800a,
        64'h8000000000000080,
        64'h8000000000008002,
        64'h8000000000008003,
        64'h8000000000008089,
        64'h800000000000008b,
        64'h000000008000808b,
        64'h000000008000000a,
        64'h0000000080008009,
        64'h0000000000000088,
        64'h000000000000008a,
        64'h8000000000008009,
        64'h8000000080008081,
        64'h0000000080000001,
        64'h000000000000808b,
        64'h8000000080008000,
        64'h800000000000808a,
        64'h0000000000008082,
        64'h0000000000000001
    };

    // Count stages. This controls whether we xor with the message chunk and which round constants
    // we pass to the keccak_iota blocks.
    logic [$clog2(s)-1:0] stage;
    generate
        if (s > 1) begin: gen_stage_counter
            always_ff @(posedge clk) begin: stage_counter
                if (reset) begin: reset_stage_count
                    stage <= 0;
                end else if (enable) begin: inc_stage_count
                    stage <= (stage == s-1) ? 0 : stage+1;
                end
            end
        end else begin: assign_stage
            assign stage = 0;
        end
    endgenerate

    logic [b-1:0] x, y;

    assign x = {y[b-1:c] ^ message, y[c-1:0]};
    keccak_p #(l, q) keccak_permute (
        .clk, .reset, .enable,
        .x((stage == 0) ? x : y),
        .rc(iota_consts[q*stage+:q]),
        .y
    );
    assign digest = y[b-1-:d];

endmodule
