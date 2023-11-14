module divider_top (   
	MemOE, MemWR, RamCS, QuadSpiFlashCS,
    ClkPort,                           // the 100 MHz incoming clock signal
	BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons 		BtnL, BtnR,
	BtnC                      // the center button (this is our reset in most of our designs)
    //TODO add whatever needed for the VGA
    );

/*  INPUTS */
input	ClkPort;	
input   BtnL, BtnU, BtnD, BtnR, BtnC;	

/*  OUTPUTS */
// Control signals on Memory chips 	(to disable them)
output 	MemOE, MemWR, RamCS, QuadSpiFlashCS;
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