module keccak #(
    parameter d = 512,      // digest length in bits
    parameter l = 6,        // log base 2 of the lane size. Use l=6 for all SHA3/SHAKE ops.
    parameter s = 6,        // number of stages (i.e. number of cycles for one sponge operation)
    parameter w = 2**l,     // lane size (i.e. word length) in bits
    parameter b = 25*w,     // keccak permutation width (i.e. state vector length) in bits
    parameter c = 2*d,      // capacity of the sponge function in bits
    parameter r = b - c,    // rate of the sponge function in bits
    parameter n = 12 + 2*l, // total number of rounds
    parameter q = n / s     // number of rounds per stage
) (
    input  logic         clk,
    input  logic         reset,
    input  logic         enable,
    input  logic [r-1:0] message,
    output logic [d-1:0] digest
);

    // keccak encapsulates the necessary hardware required to implement the keccak function as
    // described in FIPS202 section 5.

    // TODO
    // - investigate variable capacity/rate (i.e. to allow <512 bit digests on SHA3-512 hardware)
    //     - Bus widths would need to be max(d) and max(r) = 1600 - 2*min(d) bits
    //     - This would require parameters for max(d) and min(d)

    // Note: These work for all SHA3/SHAKE algorithms (i.e., where l=6).
    // See FIPS202 section 3.2.5 for details on how to generate constants for l!=6.
    // These are equivalent to the constants in FIPS202, but minimized per the procedure
    // in https://link.springer.com/article/10.1007/s13389-023-00334-0
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
