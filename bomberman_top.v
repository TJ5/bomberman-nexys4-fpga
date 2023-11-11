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
//VGA signals


/* Local Signals */ 
//TODO - clock divider here? 

// Disable the two memories so that they do not interfere with the rest of the design.
assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;

assign board_clk = ClkPort;	 	

//TODO instantiate modules

endmodule