module score_display (
    input logic slw_clk,
    input logic rst,
    input logic [15:0] score,
    output logic [3:0] an_cntrl,
    output logic [6:0] seg_cntrl
);

logic [1:0] dig_sel;

always @(posedge slw_clk or posedge rst) begin
    if (rst) begin
        dig_sel <= 2'b00;
    end else begin
        dig_sel <= dig_sel + 1;
    end
end

logic [3:0] dig;

always_comb begin
    case(dig_sel)
        2'b00: begin
            dig = score[3:0];   // Least significant digit
            an_cntrl = 4'b1110; // Activate first digit
        end
        2'b01: begin
            dig = score[7:4];   // Second digit
            an_cntrl = 4'b1101; // Activate second digit
        end
        2'b10: begin
            dig = score[11:8];  // Third digit
            an_cntrl = 4'b1011; // Activate third digit
        end
        2'b11: begin
            dig = score[15:12]; // Most significant digit
            an_cntrl = 4'b0111; // Activate fourth digit
        end
        default: begin
            dig = 4'b0000;       // Default case
            an_cntrl = 4'b1111;  // Deactivate all digits
        end
    endcase
end

segment_decoder seg_dec(
    .digig(dig),
    .seg(seg_cntrl)
);

endmodule