module top_module (
    input logic clk,
    input logic rst,
    input logic btnL, btnU, btnD, btnR,
    output logic vga_hsync,
    output logic vga_vsync,
    output logic [3:0] vga_red,
    output logic [3:0] vga_green,
    output logic [3:0] vga_blue,
    output logic [3:0] an,
    output logic [6:0] seg
);

logic slw;
logic clk_1khz;
logic clk_10hz;
logic up_clean, down_clean, left_clean, right_clean;
logic [9:0] x_pos;
logic [9:0] y_pos;
logic active_video;
logic [11:0] rgb;
logic [3:0] game_grid_array [19:0][9:0]; // Example grid array
logic [15:0] score;

clock_divider #(.DIVIDE_BY(4)) vga_clk(
    .fast_clock(clk),
    .slow_clock(slw)
);
clock_divider #(.DIVIDE_BY(100_000)) seg_clk(
    .fast_clock(clk),
    .slow_clock(clk_1khz)
);
clock_divider #(.DIVIDE_BY(1_666_667)) game_clk(
    .fast_clock(clk),
    .slow_clock(clk_10hz)
);

debounce db_up(
    .clk(clk),
    .noisy(btnU),
    .clean(up_clean)
);
debounce db_down(
    .clk(clk),
    .noisy(btnD),
    .clean(down_clean)
);
debounce db_left(
    .clk(clk),
    .noisy(btnL),
    .clean(left_clean)
);
debounce db_right(
    .clk(clk),
    .noisy(btnR),
    .clean(right_clean)
);

vga_controller dsply(
    .clk(slw),
    .rst(rst),
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .x_pos(x_pos),
    .y_pos(y_pos),
    .active(active_video)
);

score_display score_dsp(
    .slw_clk(clk_1khz),
    .rst(rst),
    .score(score),
    .an_cntrl(an),
    .seg_cntrl(seg)
);

block_renderer renderer(
    .curr_pix_x(x_pos),
    .curr_pix_y(y_pos),
    .game_grid_array(game_grid_array),
    .pixel_color(rgb)
);

tetris_logic game(
    .gm_clk(clk_10hz),
    .gm_rst(rst),
    .left(left_clean),
    .right(right_clean),
    .down(down_clean),
    .rott(up_clean),
    .grid(game_grid_array),
    .score(score)
);

always_comb begin
    if (active_video) begin
        vga_red   = rgb[11:8];
        vga_green = rgb[7:4];
        vga_blue  = rgb[3:0];
    end else begin
        vga_red   = 4'h0;
        vga_green = 4'h0;
        vga_blue  = 4'h0;
    end
end

endmodule