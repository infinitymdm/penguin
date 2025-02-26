module mux2 #(
  parameter N = 8
) (
  input logic s,
  input logic [N-1:0] d0, d1,
  output logic [N-1:0] y
);

  always_comb begin : select
    if (s)
      y = d1;
    else
      y = d0;
  end

endmodule
