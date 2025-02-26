module full_adder (
  input  logic a, b, c_in,
  output logic s, c
);

  assign s = c_in ? ~(a^b) : (a^b);
  assign c = (a^b)? c_in : (a&b);

endmodule
