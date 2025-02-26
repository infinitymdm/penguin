module alu #(
  parameter WORD_LEN /* verilator public */ = 32 
) (
  input logic [WORD_LEN-1:0] a, b,
  input logic [3:0] op_select,
  output logic [WORD_LEN-1:0] result,
  output logic zero, carry
);

  // ALU supporting add, sub, and, or, xor, signed and unsigned comparison, shift, and arithmetic
  // shift operations.

  logic [WORD_LEN-1:0] opt_inv_b, sum;

  assign opt_inv_b = op_select[0]? ~b+1 : b;
  ppa_sklansky #(WORD_LEN) adder (.a, .b(opt_inv_b), .c_in(0), .s(sum), .c(carry));

  always_comb begin
    case (op_select)
      0: result = a & b;
      1: result = a | b;
      2: result = a ^ b;
      8: result = sum; // add
      9: result = sum; // sub
      default: result = sum;
    endcase

    //overflow = 
    zero = ~(|result);
  end

endmodule
