module tb_alu;

    localparam WORD_LEN=8;

    logic               clk;
    bit [WORD_LEN-1:0]  a, b;
    bit [3:0]           op;
    bit [WORD_LEN-1:0]  y;
    bit                 z, c;

    alu #(WORD_LEN) dut (
        .a, .b,
        .op_select(op),
        .result(y),
        .zero(z),
        .carry(c)
    );

    initial begin: dump_vcd
        $dumpfile("wave.vcd");
        $dumpvars;
    end

    initial begin: initialize
        clk = 1'b0;
        a = 'b0;
        b = 'b0;
        op = 4'b0;
    end
    always #5 clk <= ~clk;

    always @(posedge clk) begin: stimulate_dut
        {op, b, a} = {op, b, a} + 1;
        if (op == 4'h3) op += 4'h5; // Skip 3, 4, 5, 6, 7
        if (op == 4'ha) $finish;
    end

    always @(negedge clk) begin: check_dut
        $display("%h(%h, %h) = %h (c=%b, z=%b)", op, a, b, y, c, z);
    end

endmodule
