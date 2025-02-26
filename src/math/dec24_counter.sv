module dec24_counter (
  input logic clk, dec, reset,
  output logic [3:0] ones, tens,
  output logic carry
);

  // decimal_counter is a Moore FSM which counts up once each time
  // clk is asserted. dec can be asserted to decrease by 1 
  // synchronously, or reset can be asserted to set to 0 
  // asynchronously.
  // Also provides a carry output for cascading with other counters.

  typedef enum logic [5:0] {S0, S1, S2, S3, S4, S5, S6, S7, S8, S9,
                    S10, S11, S12, S13, S14, S15, S16, S17,
                    S18, S19, S20, S21, S22, S23} statetype;
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
      S0: nextstate = dec ? S9 : S1;
      S1: nextstate = dec ? S0 : S2;
      S2: nextstate = dec ? S1 : S3;
      S3: nextstate = dec ? S2 : S4;
      S4: nextstate = dec ? S3 : S5;
      S5: nextstate = dec ? S4 : S6;
      S6: nextstate = dec ? S5 : S7;
      S7: nextstate = dec ? S6 : S8;
      S8: nextstate = dec ? S7 : S9;
      S9: nextstate = dec ? S8 : S10;
      S10: nextstate = dec ? S9 : S11;
      S11: nextstate = dec ? S10 : S12;
      S12: nextstate = dec ? S11 : S13;
      S13: nextstate = dec ? S12 : S14;
      S14: nextstate = dec ? S13 : S15;
      S15: nextstate = dec ? S14 : S16;
      S16: nextstate = dec ? S15 : S17;
      S17: nextstate = dec ? S16 : S18;
      S18: nextstate = dec ? S17 : S19;
      S19: nextstate = dec ? S18 : S20;
      S20: nextstate = dec ? S19 : S21;
      S21: nextstate = dec ? S20 : S22;
      S22: nextstate = dec ? S21 : S23;
      S23: nextstate = dec ? S22 : S0;
      default: nextstate = S0;
    endcase
  end

  // output logic
  always_comb begin
    case (state)
      S0: begin
        ones = 0;
        tens = 0;
      end
      S1: begin
        ones = 1;
        tens = 0;
      end
      S2: begin
        ones = 2;
        tens = 0;
      end
      S3: begin
        ones = 3;
        tens = 0;
      end
      S4: begin 
        ones = 4;
        tens = 0;
      end
      S5: begin
        ones = 5;
        tens = 0;
      end
      S6: begin
        ones = 6;
        tens = 0;
      end
      S7: begin
        ones = 7;
        tens = 0;
      end
      S8: begin
        ones = 8;
        tens = 0;
      end
      S9: begin
        ones = 9;
        tens = 0;
      end

      S10: begin
        ones = 0;
        tens = 1;
      end
      S11: begin
        ones = 1;
        tens = 1;
      end
      S12: begin
        ones = 2;
        tens = 1;
      end
      S13: begin
        ones = 3;
        tens = 1;
      end
      S14: begin 
        ones = 4;
        tens = 1;
      end
      S15: begin
        ones = 5;
        tens = 1;
      end
      S16: begin
        ones = 6;
        tens = 1;
      end
      S17: begin
        ones = 7;
        tens = 1;
      end
      S18: begin
        ones = 8;
        tens = 1;
      end
      S19: begin
        ones = 9;
        tens = 1;
      end

      S20: begin
        ones = 0;
        tens = 2;
      end
      S21: begin
        ones = 1;
        tens = 2;
      end
      S22: begin
        ones = 2;
        tens = 2;
      end
      S23: begin
        ones = 3;
        tens = 2;
      end
      default: begin
        ones = 4'd0;
        tens = 4'd0;
      end
    endcase
  end

  delay_ff d1(clk, (state == S23) & (nextstate == S0), carry);
  
endmodule
