module top_module (
    input logic clk,
    input logic rst,
    output logic hsync,
    output logic vsync,
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue
);

logic fast_clk;
logic [9:0] x_pos;
logic [9:0] y_pos;
logic active;

clock_divider clk_div(
    .clk(clk),
    .rst(rst),
)

vga_controller dsply(
    .clk(fast_clk),
    .rst(rst),
    .hsync(hsync),
    .vsync(vsync),
    .x_pos(x_pos),
    .y_pos(y_pos),
    .active(active)
)

always @(*) begin
    if (active) begin
        if(x_pos < 10 || x_pos > 630 || y_pos < 10 || y_pos > 470) begin
            red = 4'hF;
            green = 4'h0;
            blue = 4'h0; // Background color
        end else begin
            red = 4'hF; // Example color for active area
            green = 4'hF;
            blue = 4'hF;
        end
    end else begin
        red = 4'h0; // Inactive area color
        green = 4'h0;
        blue = 4'h0;
    end
end

endmodule