module hhmm_clock (
  input logic clk, dec, reset,
  output logic [3:0] min_ones, min_tens, hour_ones, hour_tens,
  output logic day_clk
);

  logic m0_clk, m1_clk, h_clk;

  divide_by_1m clock_divider(clk, m0_clk);

  dec10_counter m0(.clk(m0_clk), .dec, .reset, .data(min_ones), .carry(m1_clk));
  dec6_counter m1(.clk(m1_clk), .dec, .reset, .data(min_tens), .carry(h_clk));
  dec24_counter h1(.clk(h_clk), .dec, .reset, .ones(hour_ones), .tens(hour_tens), .carry(day_clk));

endmodule
