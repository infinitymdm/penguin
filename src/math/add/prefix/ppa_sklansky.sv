module ppa_sklansky #(
  parameter WIDTH = 16
) (
  input  logic [WIDTH-1:0] a, b,
  input  logic             c_in,
  output logic [WIDTH-1:0] s,
  output logic             c
);

  logic [WIDTH-1:0] g_in, p_in;
  /* verilator lint_off UNUSEDSIGNAL */
  logic [WIDTH-1:0] g, p;
  /* lint_on */

  // Pre-computation step
  assign g_in = a & b;
  assign p_in = a ^ b;

  // Recursive sklansky structure
  sklansky_block #(WIDTH) adder(.g_in, .p_in, .g, .p);

  // Post-computation step
  // TODO: Check for one-off error
  assign s = p_in ^ {g[WIDTH-2:0], c_in};
  assign c = g[WIDTH-1];

endmodule
