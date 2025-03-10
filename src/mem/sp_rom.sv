module sp_rom #(
    parameter binfile,
    parameter width = 64,
    parameter depth = 64,
    parameter addr_size = $clog2(depth)
) (
    input  logic                 clk,
    input  logic [addr_size-1:0] addr,
    output logic [width-1:0]     data
);

    logic [width-1:0] rom [0:depth-1];

    // Initialize from binfile
    initial $readmemh(binfile, rom);

    // Read memory
    always_ff @(posedge clk) data <= rom[addr];

endmodule
