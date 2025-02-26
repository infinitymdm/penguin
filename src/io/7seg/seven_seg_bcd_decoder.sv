module seven_seg_bcd_decoder (
  input logic [3:0] data,
  input logic dp,
  output logic [7:0] segments
);

  always_comb begin
    // Assign segments
    case (data)
      //                      abc_defg
      0:  segments = ~{dp, 7'b111_1110};
      1:  segments = ~{dp, 7'b011_0000};
      2:  segments = ~{dp, 7'b110_1101};
      3:  segments = ~{dp, 7'b111_1001};
      4:  segments = ~{dp, 7'b011_0011};
      5:  segments = ~{dp, 7'b101_1011};
      6:  segments = ~{dp, 7'b101_1111};
      7:  segments = ~{dp, 7'b111_0000};
      8:  segments = ~{dp, 7'b111_1111};
      9:  segments = ~{dp, 7'b111_1011};
      10: segments = ~{dp, 7'b111_0111};
      11: segments = ~{dp, 7'b001_1111};
      12: segments = ~{dp, 7'b000_1101};
      13: segments = ~{dp, 7'b011_1101};
      14: segments = ~{dp, 7'b100_1111};
      15: segments = ~{dp, 7'b100_0111};
      default: segments = ~{dp, 7'b00};
    endcase
  end

endmodule
