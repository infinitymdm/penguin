module divide_by_1m (input logic clk,
                     output logic out_clk);
    logic [26:0] counter;

    always @(posedge clk) begin
        if (counter == 'd100_000_000) begin
            out_clk <= 1;
            counter <= 'b0;
        end
        else begin
            out_clk <= 0;
            counter <= counter + 1;
        end
    end
endmodule
