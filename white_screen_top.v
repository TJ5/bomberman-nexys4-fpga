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

display_controller dc
    (.clk(sys_clk), .hSync(hSync), .vSync(vSync), .hCount(hc), .vCount(vc));

assign vgaR = 4'b1111;
assign vgaB = 4'b1111;
assign vgaG = 4'b1111;

endmodule