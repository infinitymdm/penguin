module keccak_round #(
    parameter l = 6,
    parameter w = 2**l,
    parameter b = 25*w
) (
    input  logic [b-1:0] x,
    input  logic   [l:0] rc,
    output logic [b-1:0] y
);

    // keccak_round encapsulates a single step of the keccak transformation function.
    // Each step contains theta, rho, pi, chi, and iota subfunctions in sequence.
    // See FIPS202 section 3.2 for details.

    logic [4:0][4:0][w-1:0] x_block, x_pi, x_chi, y_block;

    // Reorganize i/o into 3-dimensional blocks for easy indexing in subfunctions
    generate
        for (genvar i = 0; i < 5; i++) begin: sheet_select
            for (genvar j = 0; j < 5; j++) begin: lane_select
                assign x_block[i][j] = x[w*(i+5*j)+:w];
                assign y[w*(i+5*j)+:w] = y_block[i][j];
            end
        end
    endgenerate

    // Perform a single round of the keccak-p permutation
    keccak_theta_rho_pi #(w) thrhp (.x(x_block), .y(x_pi));
    keccak_chi          #(w) chi   (.x(x_pi),    .y(x_chi));
    keccak_iota         #(l) iota  (.x(x_chi),   .y(y_block), .rc);

endmodule
