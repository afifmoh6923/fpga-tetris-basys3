module top_module (
    input  logic clk,
    input  logic rst,
    output logic vga_hsync,
    output logic vga_vsync,
    output logic [3:0] vga_red,
    output logic [3:0] vga_green,
    output logic [3:0] vga_blue
);
logic slw;
logic [9:0] x_pos;
logic [9:0] y_pos;
logic active;

clock_divider clk_div(
    .fast_clock(clk),
    .slow_clock(slw)
);

vga_controller dsply(
    .clk(slw),
    .rst(rst),
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .x_pos(x_pos),
    .y_pos(y_pos),
    .active(active)
);

always_comb begin
    if (active) begin
        if(x_pos < 10 || x_pos > 630 || y_pos < 10 || y_pos > 470) begin
            vga_red = 4'hF;
            vga_green = 4'h0;
            vga_blue = 4'h0; // Background color
        end else begin
            vga_red = 4'hF; // Example color for active area
            vga_green = 4'hF;
            vga_blue = 4'hF;
        end
    end else begin
        vga_red = 4'h0; // Inactive area color
        vga_green = 4'h0;
        vga_blue = 4'h0;
    end
end

endmodule