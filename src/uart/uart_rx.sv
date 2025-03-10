`include "uart.svh"

module uart_rx #(
    parameter BAUD = 9600,
    parameter CLK_FREQ = 100000000
) (
    input  logic       clk,
    input  logic       rx,
    output logic       data_ready,
    output logic [7:0] data
);

    // TODO: Detect tx start by falling edge and sample data in center
    // Use an FSM

endmodule
