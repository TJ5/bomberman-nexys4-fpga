module divider_top (   
	output MemOE, MemWR, RamCS, QuadSpiFlashCS,
    input ClkPort,                           // the 100 MHz incoming clock signal
	input BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons 		BtnL, BtnR,
	input BtnC,                      // the center button (this is our reset in most of our designs)
    //VGA signals
    output hSync, vSync, 
    output [3:0] vgaR, vgaG, vgaB
    
    );

// TODO VGA signals


/* Local Signals */ 
reg [26:0]	DIV_CLK;
wire        Reset, ClkPort;
wire		sys_clk;

//Debouncer wires
wire  		Left_SCEN;
wire  		Up_SCEN;
wire  		Right_SCEN;
wire  		Down_SCEN;
wire        Middle_SCEN;

//Clock divider
always @(posedge sys_clk, posedge Reset) 	
    begin							
        if (Reset)
		DIV_CLK <= 0;
        else
		DIV_CLK <= DIV_CLK + 1'b1;
    end

assign	sys_clk = ClkPort; //Running at the full 100Mhz speed

// Disable the two memories so that they do not interfere with the rest of the design.
assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;


//Button debouncers
ee201_debouncer #(.N_dc(25)) ee201_debouncer_left
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnL), .DPB( ), .SCEN(Left_SCEN), .MCEN( ), .CCEN( ));

ee201_debouncer #(.N_dc(25)) ee201_debouncer_right
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnR), .DPB( ), .SCEN(Right_SCEN), .MCEN( ), .CCEN( ));

ee201_debouncer #(.N_dc(25)) ee201_debouncer_up
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB( ), .SCEN(Up_SCEN), .MCEN( ), .CCEN( ));

ee201_debouncer #(.N_dc(25)) ee201_debouncer_down
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnD), .DPB( ), .SCEN(Down_SCEN), .MCEN( ), .CCEN( ));

ee201_debouncer #(.N_dc(25)) ee201_debouncer_middle
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnC), .DPB( ), .SCEN(Middle_SCEN), .MCEN( ), .CCEN( ));

//TODO instantiate modules


endmodule