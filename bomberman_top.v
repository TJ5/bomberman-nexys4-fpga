module divider_top (   
	output MemOE, MemWR, RamCS, QuadSpiFlashCS,
    input ClkPort,                           // the 100 MHz incoming clock signal
	input BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons 		BtnL, BtnR,
	input BtnC,                      // the center button (this is our reset in most of our designs)
    //VGA signals
    output hSync, vSync, 
    output [3:0] vgaR, vgaG, vgaB

    );

/* Local Signals */ 
reg [26:0]	DIV_CLK;
wire        Reset, ClkPort;
wire		sys_clk;

//RGB Signals
wire [11:0] bomberman_rgb,
            breakable_wall_rgb,
            enemy_rgb,
            bomb_rgb,
            explosion_rgb,
            unbreakable_wall_rgb;

//RGB Enable signals
wire 
    bomberman_rgb_en,
    breakable_wall_rgb_en,
    enemy_rgb_en,
    bomb_rgb_en,
    explosion_rgb_en,
    unbreakable_wall_rgb_en;

//Debouncer wires
wire  		Left_DPB;
wire  		Up_DPB;
wire  		Right_DPB;
wire  		Down_DPB;
wire        Middle_DPB;

//VGA pixel
wire[9:0] hc, vc;

//Bomberman location
reg [9:0] b_x, b_y;

//Game over
reg game_over;

//Bomberman blocked
reg bomberman_blocked_left, bomberman_blocked_right, 
    bomberman_blocked_up, bomberman_blocked_down;

reg [3:0] bomberman_blocked = {
    bomberman_blocked_down, 
    bomberman_blocked_up, 
    bomberman_blocked_right, 
    bomberman_blocked_left};

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
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnL), .DPB(Left_DPB), .SCEN(), .MCEN( ), .CCEN( ));

ee201_debouncer #(.N_dc(25)) ee201_debouncer_right
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnR), .DPB(Right_DPB), .SCEN(), .MCEN( ), .CCEN( ));

ee201_debouncer #(.N_dc(25)) ee201_debouncer_up
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB(Up_DPB), .SCEN(), .MCEN( ), .CCEN( ));

ee201_debouncer #(.N_dc(25)) ee201_debouncer_down
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnD), .DPB(Down_DPB), .SCEN(), .MCEN( ), .CCEN( ));

ee201_debouncer #(.N_dc(25)) ee201_debouncer_middle
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnC), .DPB(Middle_DPB), .SCEN(), .MCEN( ), .CCEN( ));

//Display Controller
display_controller dc
    (.clk(sys_clk), .hSync(hSync), .vSync(vSync), .hCount(hc), .vCount(vc));

//TODO instantiate modules

bomberman bm 
    (.clk(sys_clk), .reset(Reset), .L(Left_DPB), .R(Right_DPB), .U(Up_DPB), 
    .D(Down_DPB), .C(Middle_DPB), .b_x(b_x), .b_y(b_y), .game_over(game_over), 
    .bomberman_blocked(bomberman_blocked), .v_x(hc), .v_y(vc), .rgb_out(bomberman_rgb)
    .bomberman_on(bomberman_rgb_en));

case ({bomberman_rgb_en, breakable_wall_rgb_en, enemy_rgb_en, bomb_rgb_en, explosion_rgb_en, unbreakable_wall_rgb_en})
    6'b000001: {vgaR, vgaB, vgaG} = unbreakable_wall_rgb;
    6'b000010: {vgaR, vgaB, vgaG} = explosion_rgb;
    6'b000100: {vgaR, vgaB, vgaG} = bomb_rgb;
    6'b001000: {vgaR, vgaB, vgaG} = enemy_rgb;
    6'b010000: {vgaR, vgaB, vgaG} = breakable_wall_rgb;
    6'b100000: {vgaR, vgaB, vgaG} = bomberman_rgb;
endcase
endmodule