module sync_2ff (
  input logic clk,
  input logic d,
  input logic q
);

  logic n;

  always_ff @(posedge clk) begin
    n <= d;
    q <= n;
  end

endmodule
