module blackcell (
  input  logic [1:0] g_in, p_in,
  output logic g, p
);

  assign g = g_in[1] | (p_in[1] & g_in[0]);
  assign p = &p_in;

endmodule
