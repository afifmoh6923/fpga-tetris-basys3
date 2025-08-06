module tetris_logic (
    input logic gm_clk,
    input logic gm_rst,
    input logic down, left, right, rotate,
    output logic [3:0] grid [19:0][9:0],
    output logic [15:0] score
);

parameter FALL_SPEED = 30;

reg [2:0] gm_state;
reg [15:0] gm_score;
reg [3:0] gm_memory [19:0][9:0];


reg [2:0] active_block;
reg [1:0] rotate;
reg [4:0] active_x;
reg [3:0] active_y;
reg [4:0] fall_timer_counter;
logic fall_tick;

function logic [15:0] get_shape([2:0] piece_type, [1:0] piece_rot);
    // Return the shape of the piece based on its type and rotation
    // This function should return a 4x4 array representing the piece)
    case(piece_type) begin
        3'b000: begin // I
            case(piece_rot) begin
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
                2'b00: get_shape = 16'b1000100011000000;
                2'b01: get_shape = 16'b0111010000000000;
                2'b10: get_shape = 16'b0000001100010001;
                2'b11: get_shape = 16'b0000000000010111;
                default: get_shape = 16'b0000000000000000;
            endcase
        end
        3'b100: begin // J






function boolean check_collision([2:0] piece_type, [1:0]piece_rot, [4:0] piece_x, [3:0] piece_y);
    // Check if the piece collides with the grid or goes out of bounds
    // This function should return 1 if there is a collision, 0 otherwise
    logic [15:0] shape_map = get_shape(piece_type, piece_rot);
    for (int i = 0; i < 4; i + 1) begin
        for (int j = 0; j < 4; j + 1) begin
            if (shape_map[i][j] )
        end
    end

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
        gm_score <= 16'b0; // Reset score
        active_block <= 3'b0; // Reset active block
        active_x <= 4'b0; // Reset active block X position
        active_y <= 5'b0; // Reset active block Y position
        // Initialize grid to empty
        for (int i = 0; i < 20; i++) begin
            for (int j = 0; j < 10; j++) begin
                gm_memory[i][j] <= 4'b0;
            end
        end
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
                gm_state <= 3'b001; // Move to next state
            3'b001: begin //SPAWN
                active_block <= $urandom_range(0,6);
                active_x <= 4'b4; // Center the block
                active_y <= 5'b0; // Start at the top
                gm_state <= 3'b010;
            3'b010: begin //FALLING







    end

