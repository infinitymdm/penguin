module graycell (
  input  logic g_in, p_in,
  input  logic c_in,
  output logic c
);

  assign c = g_in | (p_in & c_in);

endmodule
