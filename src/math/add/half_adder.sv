`timescale 1 ns / 1 ps

module half_adder (
  input  logic a, b,
  output logic s, c
);

  assign s = a^b;
  assign c = a&b;

endmodule
