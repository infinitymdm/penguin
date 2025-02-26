module sklansky_block #(
  parameter WIDTH = 2
) (
  input  logic [WIDTH-1:0] g_in, p_in,
  output logic [WIDTH-1:0] g, p
);
  localparam LOWER_WIDTH = 2 ** ($clog2(WIDTH) - 1); // Guaranteed to be a power of 2
  localparam UPPER_WIDTH = WIDTH - LOWER_WIDTH; // Not guaranteed to be a power of 2

  genvar i;
  generate
    if (LOWER_WIDTH > 1) begin : recurse_add_layer
      // New layer, new layer-specific interconect network
      logic [WIDTH-1:0] g_l, p_l;

      // Generate parent layers
      sklansky_block #(UPPER_WIDTH) upper_parent (
        .g_in(g_in[WIDTH-1:LOWER_WIDTH]),
        .p_in(p_in[WIDTH-1:LOWER_WIDTH]),
        .g(g_l[WIDTH-1:LOWER_WIDTH]),
        .p(p_l[WIDTH-1:LOWER_WIDTH])
      );
      sklansky_block #(LOWER_WIDTH) lower_parent (
        .g_in(g_in[LOWER_WIDTH-1:0]),
        .p_in(p_in[LOWER_WIDTH-1:0]),
        .g(g_l[LOWER_WIDTH-1:0]),
        .p(p_l[LOWER_WIDTH-1:0])
      );

      // Generate this layer's blackcells
      // - upper half get blackcells with RHS connected to top bit of lower half
      // - lower half get assigns/buffers
      for (i = 0; i < WIDTH; i += 1) begin : current_layer
        if (i < LOWER_WIDTH) begin : lower_wire
          assign g[i] = g_l[i];
          assign p[i] = p_l[i];
        end else begin : upper_cell
          blackcell upper_node (
            .g_in({g_l[i], g_l[LOWER_WIDTH-1]}),
            .p_in({p_l[i], p_l[LOWER_WIDTH-1]}),
            .g(g[i]),
            .p(p[i])
          );
        end
      end
    end else begin : base_layer
      if (WIDTH == 2) begin : base_cell
        blackcell base_node (
          .g_in(g_in[1:0]),
          .p_in(p_in[1:0]),
          .g(g[1]),
          .p(p[1])
        );
      end

      // TODO: should these be replaced with buffers? i.e. buf({g_in[0], p_in[0]}, {g[0], p[0]})
      assign g[0] = g_in[0];
      assign p[0] = p_in[0];
    end
  endgenerate

endmodule
