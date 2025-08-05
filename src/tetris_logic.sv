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
reg [3:0] active_x;
reg [4:0] active_y;
reg [4:0] fall_timer_counter;
logic fall_tick;

function check_collision
function get_shape


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

