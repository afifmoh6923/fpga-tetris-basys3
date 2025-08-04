module vga_controller(
    input wire clk,
    input wire rst,
    output reg hsync,
    output reg vsync,
    output reg [9:0] x_pos,
    output reg [9:0] y_pos,
    output reg active
);

parameter H_VIS = 640;
parameter H_FRONT = 16;
parameter H_SYNC = 96;
parameter H_BACK = 48;
parameter H_TOTAL = H_VIS + H_FRONT + H_SYNC + H_BACK;

parameter V_VIS = 480;
parameter V_FRONT = 10;
parameter V_SYNC = 2;
parameter V_BACK = 33;
parameter V_TOTAL = V_VIS + V_FRONT + V_SYNC + V_BACK;

logic [9:0] h_count;
logic [9:0] v_count;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        h_count <= 0;
        v_count <= 0;
    end else begin
        if(h_count == H_TOTAL - 1) begin
            h_count <= 0;
            if(v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end
end

assign hsync = !((h_count >= H_VIS + H_FRONT) && (h_count < H_VIS + H_FRONT + H_SYNC));
assign vsync = !((v_count >= V_VIS + V_FRONT) && (v_count < V_VIS + V_FRONT + V_SYNC));
assign x_pos = (h_count < H_VIS) ? h_count : 0;
assign y_pos = (v_count < V_VIS) ? v_count : 0;
assign active = (h_count < H_VIS) && (v_count < V_VIS);

endmodule