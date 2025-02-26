module rotate #(
    parameter width = 8,
    parameter n = 2
) (
    input  logic [width-1:0] x,
    output logic [width-1:0] y
);

    if (n > 0) begin: rotate_n
        assign y = {x[width-n-1:0], x[width-1:width-n]};
    end else begin: no_rotate
        assign y = x;
    end

endmodule
