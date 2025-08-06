module segment_decoder (
    input  logic [3:0] digit,
    output logic [6:0] seg // CA to CG (active low)
);

  always_comb begin
    case (digit)
      4'b0000: seg = 7'b0000001; // "0"  
      4'b0001: seg = 7'b1001111; // "1" 
      4'b0010: seg = 7'b0010010; // "2" 
      4'b0011: seg = 7'b0000110; // "3" 
      4'b0100: seg = 7'b1001100; // "4" 
      4'b0101: seg = 7'b0100100; // "5" 
      4'b0110: seg = 7'b0100000; // "6" 
      4'b0111: seg = 7'b0001111; // "7" 
      4'b1000: seg = 7'b0000000; // "8"  
      4'b1001: seg = 7'b0000100; // "9" 
      default: seg = 7'b0000001; // "0"
    endcase
  end

endmodule