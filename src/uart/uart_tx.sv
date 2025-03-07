`include "uart.svh"

module uart_tx #(
    parameter BAUD = 9600,
    parameter CLK_FREQ = 100000000
) (
    input  logic       clk,
    input  logic       data_ready,  // Indicates we have a new byte of data to transmit
    input  logic [7:0] data,        // The byte of data to transmit
    input  logic       rx_ready,    // Indicates the destination of the tx line is ready to receive
    output logic       tx_busy,     // Indicates the tx line is busy with a transmission
    output logic       tx           // The UART tx line
);

    localparam CLK_PER_BIT = CLK_FREQ / BAUD;
    localparam CLK_CTR_SIZE = $clog2(CLK_PER_BIT);


    uart_state state_d, state_q;
    logic [CLK_CTR_SIZE-1:0] clk_count_d, clk_count_q; // Used to count clock cycles per bit tx'd
    logic [2:0]              bit_count_d, bit_count_q; // Used to count bits tx'd
    logic [7:0]              data_d,      data_q;
    logic                    rx_ready_d,  rx_ready_q;
    logic                    tx_busy_d,   tx_busy_q;
    logic                    tx_d,        tx_q;

    // State register
    assign data_d = (data_ready & !tx_busy_q) ? data : data_q;
    assign rx_ready_d = rx_ready;
    dff #(.width(2+CLK_CTR_SIZE+3+8+1+1+1)) state_reg (
        .clk,
        .d({state_d, clk_count_d, bit_count_d, data_d, rx_ready_d, tx_busy_d, tx_d}),
        .q({state_q, clk_count_q, bit_count_q, data_q, rx_ready_q, tx_busy_q, tx_q})
    );
    assign tx_busy = tx_busy_q;
    assign tx = tx_q;

    // State FSM
    always_comb begin : uart_tx_state_fsm
        case (state_q)
            IDLE: begin
                tx_busy_d = rx_ready_q;
                if (rx_ready_q & data_ready) begin
                    state_d = START;
                    tx_d = 1'b0;
                end else begin
                    state_d = IDLE;
                    tx_d = 1'b1;
                end
                clk_count_d = 'b0;
                bit_count_d = 'b0;
            end
            START: begin
                tx_busy_d = 1'b1;
                tx_d = 1'b0;
                if (clk_count_q == CLK_PER_BIT - 1) begin
                    state_d = DATA;
                    clk_count_d = 'b0;
                end else begin
                    state_d = START;
                    clk_count_d = clk_count_q + 1;
                end
                bit_count_d = 'b0;
            end
            DATA: begin
                tx_busy_d = 1'b1;
                tx_d = data_q[bit_count_q];
                if (clk_count_q == CLK_PER_BIT -1) begin
                    if (bit_count_q == 7) begin
                        state_d = STOP;
                        bit_count_d = 'b0;
                    end else begin
                        state_d = DATA;
                        bit_count_d = bit_count_q + 1;
                    end
                    clk_count_d = 'b0;
                end else begin
                    state_d = DATA;
                    clk_count_d = clk_count_q + 1;
                    bit_count_d = bit_count_q;
                end
            end
            STOP: begin
                tx_busy_d = 1'b1;
                tx_d = 1'b1;
                if (clk_count_q == CLK_PER_BIT - 1) begin
                    state_d = IDLE;
                    clk_count_d = 'b0;
                end else begin
                    state_d = STOP;
                    clk_count_d = clk_count_q + 1;
                end
                bit_count_d = 'b0;
            end
        endcase
    end

endmodule
