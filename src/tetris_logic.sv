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

function logic [15:0] get_shape([2:0] piece_type, [1:0] piece_rot);
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
        3'b001; begin // O
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

function boolean check_collision([2:0] piece_type, [1:0]piece_rot, [3:0] piece_x, [4:0] piece_y);
    // Check if the piece collides with the grid or goes out of bounds
    // This function should return 1 if there is a collision, 0 otherwise
    logic [15:0] shape_map = get_shape(piece_type, piece_rot);
    for (int i = 0; i < 4; i + 1) begin
        for (int j = 0; j < 4; j + 1) begin
            if(shape_map[i*4 + j]) begin
                int grid_x = piece_x + j;
                int grid_y = piece_y + i;
                if (grid_x < 0 || grid_x > 9 || grid_y < 0 || grid_y > 19) begin
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

always_ff @(posedge gm_clk || posedge gm_rst) begin
    if(fall_timer_counter == FALL_SPEED - 1) begin
        fall_timer_counter <= 0;
        fall_tick <= 1;
    end else begin
        fall_timer_counter <= fall_timer_counter + 1;
        fall_tick <= 0;
    end
    if (gm_rst) begin
        gm_state <= 3'b000; // Reset state
    end else begin
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
                active_block <= $urandom_range(0,6);
                active_x <= 4'b4; // Center the block
                active_y <= 5'b0; // Start at the top
                if(check_collision(active_block, rotate, active_x, active_y)) begin
                    gm_state <= 3'b100;
                end else begin
                    gm_state <= 3'b010;
                end
            end
            3'b010: begin //FALLING
                logic [3:0] next_x;
                logic [4:0] next_y;
                logic [1:0] next_rot;
                assign next_x = active_x;
                assign next_y = active_y;
                assign next_rot = rotate;
                if (left) begin
                    next_x = active_x -1;
                end else if (right) begin
                    next_x = active_x + 1;
                end else if (rott) begin
                    next_rot = (rotate + 1) % 4; // Rotate the piece
                end
                if (!(check_collision(active_block, next_rot, next_x, active_y))) begin
                    active_x = next_x;
                    rotate = next_rot;
                end
                if (fall_tick || down) begin
                    next_y = active_y + 1;
                    if (!(check_collision(active_block, rotate, active_x, next_y))) begin
                        active_y = next_y;
                    end else begin
                        logic [15:0] shape_map = get_shape(active_block, rotate);
                        for (int i = 0; i < 4; i++) begin
                            for (int j = 0; j < 4; j++) begin
                                if(shape_map[i*4 + j]) begin
                                    gm_memory[active_y + i][active_x + j] <= active_block;
                                end
                            end
                        end
                    end
                        gm_state <= 3'b011;
                    end
            end
            3'b011: begin //CLEAR LINE
                int cleared = 0;
                for(int i = 0; i < 20; i++) begin
                    boolean complete = 1;
                    for(int j = 0; j < 10; j++) begin
                        if(gm_memory[i][j] == 4'b0000) begin
                            complete = 0;
                            break;
                        end
                    end
                    if(complete) begin
                        cleared = cleared + 1;
                        for(int k = i; k > 0; k--) begin
                            for(int j = 0; j < 10; j++) begin
                                gm_memory[k][j] <= gm_memory[k-1][j];
                            end
                        end
                        gm_score <= gm_score + (cleared * 100); // Update score
                    end
                end
                if(cleared > 0) begin
                    gm_state <= 3'b001; // Go back to spawn state
                end else begin
                    gm_state <= 3'b010; // Continue falling
                end
            end
            3'b100: begin //GAME OVER
                if(gm_rst) begin
                    gm_state <= 3'b000; // Go to initialization on reset
                end
            end
        endcase
    end
end

always_comb begin
    logic [3:0] temp_grid [19:0][9:0];
    temp_grid = gm_memory;
    logic active_color;

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

    logic [15:0] shape_map = get_shape(active_block, rotate);
    if(gm_state == 3'b001 || gm_state == 3'b010) begin
        for (int i = 0; i < 4; i++) begin
            for (int j = 0; j < 4; j++) begin
                if(shape_map[i*4 + j]) begin
                    if(active_y + i < 20 && active_x + j < 10) begin
                        temp_grid[active_y + i][active_x + j] = active_color;
                    end
                end
            end
        end
    end

    assign grid = temp_grid;
    assign score = gm_score;
end

endmodule
