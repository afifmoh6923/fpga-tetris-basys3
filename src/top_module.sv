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

// =====================================================
    // Gravity clock divider (5 Hz fall tick from 100 MHz)
    // =====================================================
    parameter int CLK_HZ     = 100_000_000;
    parameter int GRAVITY_HZ = 5; // adjust for faster/slower fall
    localparam int DIV_N     = CLK_HZ / GRAVITY_HZ;

    logic [$clog2(DIV_N)-1:0] grav_cnt;
    logic grav_ce;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            grav_cnt <= '0;
            grav_ce  <= 1'b0;
        end else begin
            if (grav_cnt == DIV_N-1) begin
                grav_cnt <= '0;
                grav_ce  <= 1'b1;
            end else begin
                grav_cnt <= grav_cnt + 1;
                grav_ce  <= 1'b0;
            end
        end
    end

logic slw;
logic clk_1khz;
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
    .gm_clk(clk),
    .gm_rst(rst),
    .left(left_clean),
    .right(right_clean),
    .down(down_clean),
    .rott(up_clean),
    .grav_ce(grav_ce),
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