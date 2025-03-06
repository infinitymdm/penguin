`include "uart.svh"

module uart_tx (
    input  logic       clk,
    input  logic [8:0] data
    output logic       tx
)

    uart_packet pkt;

endmodule
