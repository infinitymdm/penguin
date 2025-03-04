module uart_tx (
    input  logic clk,
    input  [8:0] data,
)

    // Start bit: 1 clk low
    // Data bits: min 5 max 9 bits
    // Parity bit: optional 1 bit (options N=none, E=even, O=odd)
    // Stop bit: 2 clks high

endmodule
