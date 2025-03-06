struct {
    bit     start;
    byte    data; // Assume 8 bit data frame, no parity (we can change this later)
    bit     stop;
} uart_packet;

