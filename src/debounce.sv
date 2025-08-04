module debounce (
    input wire clk,
    input wire noisy,
    output logic clean
);

logic [2:0] shift_reg;

always @(posedge clk) begin
    shift_reg <= {shift_reg[1:0], noisy};
end

assign clean = (shift_reg == 3'b111) ? 1 : 0;

endmodule