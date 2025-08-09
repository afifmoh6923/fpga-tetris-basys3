// Optimized 2D array version of tetris_logic for better synthesis performance
// Keeps original structure but removes large blocking assignments and uses sequential clearing.

module tetris_logic (
    input logic gm_clk,
    input logic gm_rst,
    input logic down, left, right, rott,
    output logic [3:0] grid [19:0][9:0],
    output logic [15:0] score
);

parameter FALL_SPEED = 30;

reg [2:0] gm_state;
reg [15:0] gm_score;
reg [3:0] gm_memory [19:0][9:0];

reg [2:0] active_block;
reg [1:0] rotate;
reg [3:0] active_x;
reg [4:0] active_y;
reg [4:0] fall_timer_counter;
logic fall_tick;
logic [3:0] active_color;
logic [15:0] shape_map;
logic [15:0] shape_map1;
logic [19:0] rows_to_clear;

logic down_prev, left_prev, right_prev, rott_prev;
logic down_edge, left_edge, right_edge, rott_edge;

// Edge detection
always_ff @(posedge gm_clk) begin
    down_prev <= down;
    left_prev <= left;
    right_prev <= right;
    rott_prev <= rott;
end
assign down_edge = down && !down_prev;
assign left_edge = left && !left_prev;
assign right_edge = right && !right_prev;
assign rott_edge = rott && !rott_prev;

// Shape lookup function
function logic [15:0] get_shape(input [2:0] piece_type, input [1:0] piece_rot);
    case(piece_type)
        3'b000: get_shape = (piece_rot[0]) ? 16'b0100010001000100 : 16'b0000111100000000;
        3'b001: get_shape = 16'b0000011001100000;
        3'b010: case(piece_rot)
                    2'b00: get_shape = 16'b0000010011100000;
                    2'b01: get_shape = 16'b0000010001100100;
                    2'b10: get_shape = 16'b0000000011101000;
                    2'b11: get_shape = 16'b0000010011000100;
                endcase
        3'b011: case(piece_rot)
                    2'b00: get_shape = 16'b0100010001100000;
                    2'b01: get_shape = 16'b0111010000000000;
                    2'b10: get_shape = 16'b0011000100010000;
                    2'b11: get_shape = 16'b0000000101110000;
                endcase
        3'b100: case(piece_rot)
                    2'b00: get_shape = 16'b0000001001000110;
                    2'b01: get_shape = 16'b0000000011101000;
                    2'b10: get_shape = 16'b0000110001001000;
                    2'b11: get_shape = 16'b0000001011100000;
                endcase
        3'b101: get_shape = (piece_rot[0]) ? 16'b0000010001100010 : 16'b0000001101100000;
        3'b110: get_shape = (piece_rot[0]) ? 16'b0000001001100100 : 16'b0000011000110000;
        default: get_shape = 16'b0;
    endcase
endfunction

// Collision check function
function logic check_collision(input [2:0] piece_type, input [1:0]piece_rot, input[3:0] piece_x, input [4:0] piece_y);
    shape_map = get_shape(piece_type, piece_rot);
    for (int i = 0; i < 4; i++) begin
        for (int j = 0; j < 4; j++) begin
            if(shape_map[15 - (i*4 + j)]) begin
                automatic int grid_x = piece_x + j;
                automatic int grid_y = piece_y + i;
                if (grid_x < 0 || grid_x > 9 || grid_y > 19) return 1;
                if (grid_y >= 0 && gm_memory[grid_y][grid_x] != 4'b0) return 1;
            end
        end
    end
    return 0;
endfunction

// Game logic FSM
always_ff @(posedge gm_clk) begin
    if (gm_rst) begin
        gm_state <= 3'b000;
        fall_timer_counter <= 0;
        fall_tick <= 0;
    end else begin
        fall_timer_counter <= (fall_timer_counter == FALL_SPEED-1) ? 0 : fall_timer_counter + 1;
        fall_tick <= (fall_timer_counter == FALL_SPEED-1);

        case(gm_state)
            3'b000: begin // INIT - sequential clear instead of nested for
                static int clr_row = 0, clr_col = 0;
                gm_memory[clr_row][clr_col] <= 4'b0;
                if (clr_col == 9) begin
                    clr_col <= 0;
                    if (clr_row == 19) begin
                        clr_row <= 0;
                        gm_score <= 0;
                        gm_state <= 3'b001;
                    end else clr_row <= clr_row + 1;
                end else clr_col <= clr_col + 1;
            end
            3'b001: begin // SPAWN
                active_block <= active_block + 1;
                rotate <= 2'b00;
                active_x <= 4'd4;
                active_y <= 5'd0;
                gm_state <= check_collision(active_block + 1, 2'b00, 4'd4, 5'd0) ? 3'b101 : 3'b010;
            end
            3'b010: begin // FALLING
                if (left_edge && !check_collision(active_block, rotate, active_x - 1, active_y)) active_x <= active_x -1;
                else if (right_edge && !check_collision(active_block, rotate, active_x + 1, active_y)) active_x <= active_x + 1;
                else if (rott_edge && !check_collision(active_block, rotate + 1, active_x, active_y)) rotate <= rotate + 1;
                if (fall_tick || down_edge) begin
                    if (!check_collision(active_block, rotate, active_x, active_y + 1)) active_y <= active_y + 1;
                    else gm_state <= 3'b011;
                end
            end
            3'b011: begin // LANDING
                automatic logic [15:0] landed_shape = get_shape(active_block, rotate);
                for (int i = 0; i < 4; i++)
                    for (int j = 0; j < 4; j++)
                        if (landed_shape[15 - (i*4 + j)] && active_y + i >= 0)
                            gm_memory[active_y + i][active_x + j] <= active_block + 1;
                gm_state <= 3'b100;
            end
            3'b100: begin // CLEAR LINES - sequential copy approach could be added here if needed
                automatic int write_row = 19;
                for (int read_row = 19; read_row >= 0; read_row--) begin
                    automatic bit line_full = 1;
                    for (int col = 0; col < 10; col++)
                        if (gm_memory[read_row][col] == 4'h0) line_full = 0;
                    if (!line_full) begin
                        if (write_row != read_row)
                            for (int col = 0; col < 10; col++)
                                gm_memory[write_row][col] <= gm_memory[read_row][col];
                        write_row--;
                    end else gm_score <= gm_score + 100;
                end
                for (int r = 0; r < 20; r++) begin
                // The 'if' statement provides the variable control.
                    if (r <= write_row) begin
                        for (int c = 0; c < 10; c++) begin
                            gm_memory[r][c] <= 4'b0;
                        end
                    end
                end
            end
            3'b101: begin //GAME OVER
                if(gm_rst) begin
                    gm_state <= 3'b000; // Go to initialization on reset
                end
            end
            default: begin
                gm_state <= 3'b000; // Reset to initialization on unknown state
            end
        endcase
    end
end

// Display output composition
always_comb begin
    automatic logic [3:0] temp_grid [19:0][9:0] = gm_memory;
    case(active_block)
        3'b000: active_color = 4'b0001;
        3'b001: active_color = 4'b0010;
        3'b010: active_color = 4'b0011;
        3'b011: active_color = 4'b0100;
        3'b100: active_color = 4'b0101;
        3'b101: active_color = 4'b0110;
        3'b110: active_color = 4'b0111;
        default: active_color = 4'b0000;
    endcase
    if (gm_state == 3'b010) begin
        shape_map1 = get_shape(active_block, rotate);
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++)
                if(shape_map1[15 - (i*4 + j)] && active_y + i < 20 && active_x + j < 10)
                    temp_grid[active_y + i][active_x + j] = active_color;
    end
    grid = temp_grid;
    score = gm_score;
end

endmodule
