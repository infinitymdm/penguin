module uart_rx #(
    parameter BAUD = 9600,
    parameter USE_PARITY = 0
) (
    input  logic       clk,
    input  logic       uart_tx_in,
    output logic [8:0] data,
);

endmodule
