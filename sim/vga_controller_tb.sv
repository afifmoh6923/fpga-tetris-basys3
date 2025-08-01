// Testbench for vga_controller.sv
// This module will drive the inputs and check the outputs of the VGA controller.

module vga_controller_tb;

  // Testbench signals
  logic clk;
  logic rst;

  // Wires to connect to the outputs of the DUT (Device Under Test)
  wire hsync;
  wire vsync;
  wire [9:0] x;
  wire [9:0] y;
  wire active_video;

  // Define the clock period for a 25 MHz clock (40 nanoseconds)
  parameter CLK_PERIOD = 40;

  // Instantiate the VGA controller module
  vga_controller uut (
    .clk(clk),
    .rst(rst),
    .hsync(hsync),
    .vsync(vsync),
    .x_pos(x),
    .y_pos(y),
    .active(active_video)
  );

  // Clock generator block: creates a continuous 25 MHz clock
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Test sequence block: controls the simulation
  initial begin
    // 1. Initialize signals
    clk = 0;
    rst = 1; // Start in reset

    // 2. Apply reset pulse
    #100; // Wait for 100 ns
    rst = 0; // Release from reset

    // 3. Run simulation for long enough to see at least one full frame
    // A full frame takes 16.8 ms. We'll run for 35 ms to see two frames.
    #35_000_000; // Wait for 35,000,000 ns (35 ms)

    // 4. End the simulation
    $stop;
  end

endmodule