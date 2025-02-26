module divide_by_4 (input logic clk,
                     output logic out_clk);
    localparam N = 4;
    logic [N-1:0] counter;

    always @(posedge clk)
        counter <= counter + 1;

    assign out_clk = counter[N-1];
endmodule
