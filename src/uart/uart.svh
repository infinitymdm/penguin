`ifndef UART_SVH
`define UART_SVH

typedef enum logic [1:0] {
    IDLE = 0,
    START,
    DATA,
    STOP
} uart_state;
`endif
