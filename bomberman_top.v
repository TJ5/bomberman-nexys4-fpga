module bomberman_top (   
	output MemOE, MemWR, RamCS, QuadSpiFlashCS,
    input ClkPort,                           // the 100 MHz incoming clock signal
	input BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons 		BtnL, BtnR,
	input BtnC,                      // the center button (this is our reset in most of our designs)
    //VGA signals
    output hSync, vSync, 
    output reg [3:0] vgaR, vgaG, vgaB

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

wire bright; 

//Bomberman location
wire [9:0] b_x, b_y;

//Game over
reg game_over;

//Bomberman blocked - [Left, Right, Up, Down] 
//If the corresponding direction is blocked the bit is set to 1

wire [3:0] bomberman_blocked_bw; //breakable wall module blocks
wire [3:0] bomberman_blocked_ubw = 4'b0000; //unbreakable wall module blocks

wire [3:0] bomberman_blocked; //final blocked signal
assign bomberman_blocked = bomberman_blocked_bw | bomberman_blocked_ubw; 

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
debouncer #(.N_dc(25)) debouncer_left
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnL), .DPB(Left_DPB), .SCEN(), .MCEN( ), .CCEN( ));

debouncer #(.N_dc(25)) debouncer_right
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnR), .DPB(Right_DPB), .SCEN(), .MCEN( ), .CCEN( ));

debouncer #(.N_dc(25)) debouncer_up
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB(Up_DPB), .SCEN(), .MCEN( ), .CCEN( ));

debouncer #(.N_dc(25)) debouncer_down
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnD), .DPB(Down_DPB), .SCEN(), .MCEN( ), .CCEN( ));

debouncer #(.N_dc(25)) debouncer_middle
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnC), .DPB(Middle_DPB), .SCEN(), .MCEN( ), .CCEN( ));

//Display Controller
display_controller dc
    (.clk(sys_clk), .hSync(hSync), .vSync(vSync), .hCount(hc), .vCount(vc), .bright(bright));

//TODO instantiate modules

bomberman bm 
    (.clk(sys_clk), .reset(Reset), .L(Left_DPB), .R(Right_DPB), .U(Up_DPB), 
    .D(Down_DPB), .C(Middle_DPB), .b_x(b_x), .b_y(b_y), .game_over(game_over), 
    .bomberman_blocked(bomberman_blocked), .v_x(hc), .v_y(vc), .rgb_out(bomberman_rgb),
    .bomberman_on(bomberman_rgb_en));

box_top box_top
    (.clk(sys_clk), .reset(Reset), .b_x(b_x), .b_y(b_y), .v_x(hc), .v_y(vc), 
    .box_on(breakable_wall_rgb_en), .bomberman_blocked(bomberman_blocked_bw), .rgb_out(breakable_wall_rgb));

always @ (posedge sys_clk)
    begin
        if (bright == 1)
        begin
            case ({bomberman_rgb_en, breakable_wall_rgb_en, enemy_rgb_en, bomb_rgb_en, explosion_rgb_en, unbreakable_wall_rgb_en})
                6'b000001: {vgaR, vgaG, vgaB} <= unbreakable_wall_rgb;
                6'b000010: {vgaR, vgaG, vgaB} <= explosion_rgb;
                6'b000100: {vgaR, vgaG, vgaB} <= bomb_rgb;
                6'b001000: {vgaR, vgaG, vgaB} <= enemy_rgb;
                6'b010000: {vgaR, vgaG, vgaB} <= breakable_wall_rgb;
                6'b100000: {vgaR, vgaG, vgaB} <= bomberman_rgb;
                default: {vgaR, vgaG, vgaB} <= 12'b0110_1001_1100;
            endcase
        end
        else
            {vgaR, vgaG, vgaB} <= 12'b0000_0000_0000;
    end
endmodule