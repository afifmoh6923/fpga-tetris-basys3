// Testbench for score_display.sv
// This module will verify the 7-segment display driver and decoder.

module score_display_tb;

  // Testbench signals
  logic clk;
  logic rst;
  logic [15:0] score;

  // Wires to connect to the outputs of the DUT
  wire [3:0] an;  // Anode outputs
  wire [6:0] seg; // Segment outputs

  // Define a clock period for a 1 kHz clock (1 millisecond)
  // This is a typical refresh rate for a 7-segment display.
  parameter CLK_PERIOD = 1_000_000; // ns

  // Instantiate the score display module
  score_display uut (
    .slw_clk(clk),
    .rst(rst),
    .score(score),
    .an_cntrl(an),
    .seg_cntrl(seg)
  );

  // Clock generator block
  always #(CLK_PERIOD / 2) clk = ~clk;

  // Test sequence block
  initial begin
    // 1. Initialize signals
    clk = 0;
    rst = 1;
    score = 16'd4702; // Set a static score to test

    // 2. Apply reset pulse
    #100; // Wait for 100 ns
    rst = 0;

    // 3. Run for long enough to see a few full cycles of the display
    #10_000_000; // Run for 10 ms

    // 4. End the simulation
    $stop;
  end

endmodule