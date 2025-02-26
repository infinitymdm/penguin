module mux4 #(
  parameter N = 8
) (
  input logic [1:0] s,
  input logic [N-1:0] d0, d1, d2, d3,
  output logic [N-1:0] y
);

  always_comb begin : select
    case (s)
      0: y = d0;
      1: y = d1;
      2: y = d2;
      3: y = d3;
      default: y = 'bx;
    endcase
  end
endmodule
