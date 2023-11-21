module white_screen_top (
    output MemOE, MemWR, RamCS, QuadSpiFlashCS,
    input ClkPort,                           // the 100 MHz incoming clock signal
    //VGA signals
    output wire hSync, vSync, 
    output [3:0] vgaR, vgaG, vgaB
);
assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

//VGA pixel
wire[9:0] hc, vc;
wire sys_clk;
assign sys_clk = ClkPort;
wire bright;

display_controller dc
    (.clk(sys_clk), .hSync(hSync), .vSync(vSync), .hCount(hc), .vCount(vc), .bright(bright));

reg[11:0] rgb_data;
always @(posedge sys_clk)
begin
    if (bright == 1)
    begin
        rgb_data <= 12'b111111111111;
    end
    else
    begin
        rgb_data <= 12'b000000000000;
    end
end
assign vgaR = rgb_data[11:8];
assign vgaB = rgb_data[3:0];
assign vgaG = rgb_data[7:4];

endmodule