module seven_seg_driver (
  input  logic       clk,
  input  logic [3:0] a, b, c, d,
  output logic [3:0] select,
  output logic [7:0] segments
);

  // seven_seg_driver asynchronously drives a bank of four seven-
  // segment displays with a duty cycle of 1/16.

  typedef enum logic [1:0] {S0, S1, S2, S3} statetype;
  statetype state, nextstate;

  // Subdivide clock. Select should be slower than refresh.
  logic select_clk, refresh_clk;
  divide_by_4 refresh_divider(clk, refresh_clk);
  divide_by_4 select_divider(refresh_clk, select_clk);

  // state register
  always_ff @(posedge select_clk)
      state <= nextstate;

  // next state logic - cycle in a fixed ring
  always_comb begin
    case (state)
      S0: nextstate = S1;
      S1: nextstate = S2;
      S2: nextstate = S3;
      S3: nextstate = S0;
      default: nextstate = S0;
    endcase
  end

  // select output logic
  logic [1:0] s;
  always_comb begin
    case (state)
      S0: s = 0;
      S1: s = 1;
      S2: s = 2;
      S3: s = 3;
      default: s = 2'b00;
    endcase
  end
  seven_seg_select_decoder select_driver(s, select);

  // segments output logic
  logic [3:0] data;
  always_comb begin
    case (state)
      S0: data = a;
      S1: data = b;
      S2: data = c;
      S3: data = d;
      default: data = 4'b1111;
    endcase
  end
  seven_seg_bcd_decoder segments_driver(data, 1'b0, segments);

endmodule
