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
logic [15:0] shape;
logic [15:0] shape_map1;
logic [4:0] lines_cleared;
logic [19:0] rows_to_clear;
int write_row;

logic down_prev, left_prev, right_prev, rott_prev;
logic down_edge, left_edge, right_edge, rott_edge;

always @(posedge gm_clk) begin
    down_prev <= down;
    left_prev <= left;
    right_prev <= right;
    rott_prev <= rott;
end

assign down_edge = down && !down_prev;
assign left_edge = left && !left_prev;
assign right_edge = right && !right_prev;
assign rott_edge = rott && !rott_prev;

reg [6:0] lfsr;
always @(posedge gm_clk) begin
    if (gm_rst) begin
        lfsr <= 7'b1010101; // Reset LFSR to a non-zero value
    end else begin
        lfsr <= {lfsr[5:0], lfsr[6] ^ lfsr[5]}; // LFSR feedback
    end
end

function logic [15:0] get_shape(input [2:0] piece_type, input [1:0] piece_rot);
    // Return the shape of the piece based on its type and rotation
    // This function should return a 4x4 array representing the piece)
    // Each 4 bits represent a row of the piece
    case(piece_type)
        3'b000: begin // I
            case(piece_rot)
                2'b00, 2'b10: get_shape = 16'b0000111100000000; // Horizontal
                2'b01, 2'b11: get_shape = 16'b0010001000100010; // Vertical
                default: get_shape = 16'b0000000000000000;
            endcase
        end
        3'b001: begin // O
            case(piece_rot)
                default: get_shape = 16'b0000011001100000; // Square, no rotation
            endcase
        end
        3'b010: begin // T
            case(piece_rot)
                2'b00: get_shape = 16'b1110010000000000;
                2'b01: get_shape = 16'b0001001100010000;
                2'b10: get_shape = 16'b0000000000100111;
                2'b11: get_shape = 16'b0000100011001000;
                default: get_shape = 16'b0000000000000000;
            endcase
        end
        3'b011: begin // L
            case(piece_rot)
                2'b00: get_shape = 16'b0100010001100000;
                2'b01: get_shape = 16'b0111010000000000;
                2'b10: get_shape = 16'b0011000100010000;
                2'b11: get_shape = 16'b0000000101110000;
                default: get_shape = 16'b0000000000000000;
            endcase
        end
        3'b100: begin // J
            case(piece_rot)
                2'b00: get_shape = 16'b0010001001100000;
                2'b01: get_shape = 16'b0000010001110000;
                2'b10: get_shape = 16'b0110010001000000;
                2'b11: get_shape = 16'b0111000100000000;
                default: get_shape = 16'b0000000000000000;
            endcase
        end
        3'b101: begin // S
            case(piece_rot) 
                2'b00, 2'b10: get_shape = 16'b0000001101100000;
                2'b01, 2'b11: get_shape = 16'b0000010001100010;
                default: get_shape = 16'b0000000000000000;
            endcase
        end
        3'b110: begin // Z
            case(piece_rot)
                2'b00, 2'b10: get_shape = 16'b0000011000110000;
                2'b01, 2'b11: get_shape = 16'b0000001001100100;
                default: get_shape = 16'b0000000000000000;
            endcase
        end
        default: get_shape = 16'b0000000000000000;
    endcase 
endfunction

function logic check_collision(input [2:0] piece_type, input [1:0]piece_rot, input[3:0] piece_x, input [4:0] piece_y);
    // Check if the piece collides with the grid or goes out of bounds
    // This function should return 1 if there is a collision, 0 otherwise
    shape_map = get_shape(piece_type, piece_rot);

    for (int i = 0; i < 4; i++) begin
        for (int j = 0; j < 4; j++) begin
            if(shape_map[15 - (i*4 + j)]) begin
                automatic int grid_x = piece_x + j;
                automatic int grid_y = piece_y + i;
                if (grid_x < 0 || grid_x > 9 || grid_y > 19) begin
                    return 1; // Out of bounds
                end
                if (grid_y >= 0 && gm_memory[grid_y][grid_x] != 4'b0) begin
                    return 1; // Collision with existing block
                end
            end
        end
    end
    return 0;
endfunction

always @(posedge gm_clk) begin
    if (gm_rst) begin
        gm_state <= 3'b000; // Reset state
        fall_timer_counter <= 0;
        fall_tick <= 0;
    end else begin
        if(fall_timer_counter == FALL_SPEED - 1) begin
            fall_timer_counter <= 0;
            fall_tick <= 1;
        end else begin
            fall_timer_counter <= fall_timer_counter + 1;
            fall_tick <= 0;
        end
    
        // Game logic here, e.g., moving blocks, checking for collisions, etc.
        case(gm_state)
            3'b000: begin //INITIALIZATION
                for (int i = 0; i < 20; i++) begin
                    for (int j = 0; j < 10; j++) begin
                        gm_memory[i][j] <= 4'b0;
                    end
                end
                gm_score <= 16'b0; // Reset score
                active_block <= 3'b0; // Reset active block
                active_x <= 4'b0; // Reset active block X position
                active_y <= 5'b0; // Reset active block Y position
                fall_timer_counter <= 0;
                gm_state <= 3'b001; // Move to next state
            end
            3'b001: begin //SPAWN
                active_block <= lfsr[2:0]; // Random block
                rotate <= 2'b00; // Reset rotation
                active_x <= 4'd3; // Center the block
                active_y <= 5'd0; // Start at the top
                if(check_collision(lfsr[2:0], 2'b00, 4'd3, 5'd0)) begin
                    gm_state <= 3'b101;
                end else begin
                    gm_state <= 3'b010;
                end
            end
            3'b010: begin //FALLING
                if (left_edge && !check_collision(active_block, rotate, active_x - 1, active_y)) begin
                    active_x <= active_x -1;
                end else if (right_edge && !check_collision(active_block, rotate, active_x + 1, active_y)) begin
                    active_x <= active_x + 1;
                end else if (rott_edge && !check_collision(active_block, rotate + 1, active_x, active_y)) begin
                    rotate <= rotate + 1; // Rotate the piece
                end
               
                if (fall_tick || down_edge) begin
                    if (!(check_collision(active_block, rotate, active_x, active_y + 1))) begin
                        active_y <= active_y + 1; // Move down
                    end else begin
                        gm_state <= 3'b011;
                    end
                end
            end
            3'b011: begin //LANDING
                automatic logic [15:0] landed_shape = get_shape(active_block, rotate);
                for (int i = 0; i < 4; i++) begin
                    for (int j = 0; j < 4; j++) begin
                        if (landed_shape[15 - (i*4) - j]) begin
                            if (active_y + i >= 0)
                                gm_memory[active_y + i][active_x + j] <= active_block + 1; // Use color code
                        end
                    end
                end
                gm_state <= 3'b100;
            end
            3'b100: begin //CLEAR LINE
                automatic logic [3:0] new_grid [19:0][9:0];
                lines_cleared = 0;
                write_row = 19; // Start writing from the bottom

                for (int read_row = 19; read_row >= 0; read_row--) begin
                        automatic logic line_full = 1'b1;
                        for (int col = 0; col < 10; col++) begin
                            if (gm_memory[read_row][col] == 4'h0) line_full = 1'b0;
                        end
                        if (!line_full) begin
                            for (int col = 0; col < 10; col++) begin
                                new_grid[write_row][col] = gm_memory[read_row][col];
                            end
                            write_row = write_row - 1;
                        end else begin
                            lines_cleared = lines_cleared + 1;
                        end
                    end
                    for (int row = 0; row < 20; row++) begin
                        // The 'if' statement provides the variable control.
                        if (row <= write_row) begin
                            for (int col = 0; col < 10; col++) begin
                                new_grid[row][col] = 4'h0; // Clear the top rows
                            end
                        end
                    end
                    gm_memory <= new_grid;
                    gm_score <= gm_score + (lines_cleared * 100);
                    gm_state <= 3'b001; // Spawn new block
                end
            3'b101: begin //GAME OVER
                if(gm_rst) begin
                    gm_state <= 3'b000; // Go to initialization on reset
                end
            end
            default: gm_state <= 3'b000; // Reset to initialization on unknown state
        endcase
    end
end

always_comb begin
    logic [3:0] temp_grid [19:0][9:0];
    temp_grid = gm_memory;

    case(active_block)
        3'b000: active_color = 4'b0001; // I
        3'b001: active_color = 4'b0010; // O
        3'b010: active_color = 4'b0011; // T
        3'b011: active_color = 4'b0100; // L
        3'b100: active_color = 4'b0101; // J
        3'b101: active_color = 4'b0110; // S
        3'b110: active_color = 4'b0111; // Z
        default: active_color = 4'b0000; // Empty
    endcase
    if(gm_state == 3'b010) begin
        shape_map1 = get_shape(active_block, rotate);
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                if(shape_map[15 - (i*4 + j)]) begin
                    if(active_y + i < 20 && active_x + j < 10) begin
                        temp_grid[active_y + i][active_x + j] = active_color;
                    end
                end
            end
        end
    end

    grid = temp_grid;
    score = gm_score;
end

endmodule
