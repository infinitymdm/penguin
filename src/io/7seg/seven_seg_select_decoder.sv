module seven_seg_select_decoder (
  input logic [1:0] s,
  output logic [3:0] y
);

  always_comb begin
    case (s)
      0: y = 4'b1110;
      1: y = 4'b1101;
      2: y = 4'b1011;
      3: y = 4'b0111;
    endcase
  end

endmodule
