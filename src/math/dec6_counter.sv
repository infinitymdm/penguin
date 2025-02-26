module dec6_counter (
  input logic clk, dec, reset,
  output logic [3:0] data,
  output logic carry
);

  // A Moore FSM which increments once each time
  // clk is asserted. dec can be asserted to decrease by 1 
  // synchronously, or reset can be asserted to set to 0 
  // asynchronously.
  // Also provides a carry output for cascading with other counters.

  typedef enum logic [4:0] {S0, S1, S2, S3, S4, S5} statetype;
  statetype state, nextstate;

  // state register
  always_ff @(posedge clk, posedge reset) begin
    if (reset)
      state <= S0;
    else
      state <= nextstate;
  end

  // next state logic
  always_comb begin
    case (state)
      S0: nextstate = dec ? S5 : S1;
      S1: nextstate = dec ? S0 : S2;
      S2: nextstate = dec ? S1 : S3;
      S3: nextstate = dec ? S2 : S4;
      S4: nextstate = dec ? S3 : S5;
      S5: nextstate = dec ? S4 : S0;
      default: nextstate = S0;
    endcase
  end

  // output logic
  always_comb begin
    case (state)
      S0: data = 4'd0;
      S1: data = 4'd1;
      S2: data = 4'd2;
      S3: data = 4'd3;
      S4: data = 4'd4;
      S5: data = 4'd5;
      default: data = 4'd0;
    endcase
  end
  delay_ff d1(clk, (state == S5) & (nextstate == S0), carry);

endmodule
