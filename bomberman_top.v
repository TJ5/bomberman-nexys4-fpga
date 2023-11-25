module bomberman_top (   
	output MemOE, MemWR, RamCS, QuadSpiFlashCS,
    input ClkPort,                           // the 100 MHz incoming clock signal
	input BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons 		BtnL, BtnR,
	input BtnC,                      // the center button (this is our reset in most of our designs)
	input Sw0, //USED TO RESET BOMBERMAN LOCATION
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

//Bomb location
wire [9:0] bomb_x,bomb_y;

//Exploding bomb location
wire [9:0] exploding_bomb_x,exploding_bomb_y;

//Active Explosion location
wire [9:0] explosion_x,explosion_y;

//new explosion
wire flag;

//Game over
reg game_over;

//Bomberman blocked

reg [3:0] bomberman_blocked = 4'b0000;


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
    (.CLK(sys_clk), .RESET(Reset), .PB(BtnC), .DPB(), .SCEN(Middle_DPB), .MCEN( ), .CCEN( ));

//Display Controller
display_controller dc
    (.clk(sys_clk), .hSync(hSync), .vSync(vSync), .hCount(hc), .vCount(vc), .bright(bright));

//TODO instantiate modules

bomberman bm 
    (.clk(sys_clk), .reset(Sw0), .L(Left_DPB), .R(Right_DPB), .U(Up_DPB), 
    .D(Down_DPB), .C(Middle_DPB), .b_x(b_x), .b_y(b_y), .game_over(game_over), 
    .bomberman_blocked(bomberman_blocked), .v_x(hc), .v_y(vc), .rgb_out(bomberman_rgb),
    .bomberman_on(bomberman_rgb_en));
   
bomb bmb
(
    .clk(sys_clk), .reset(Sw0), .b_x(b_x), .b_y(b_y), .v_x(hc), .v_y(vc), .C(Middle_DPB),
    .bomb_x(bomb_x), .bomb_y(bomb_y), .bomb_on(bomb_rgb_en),  .rgb_out(bomb_rgb), 
    .exploding_bomb_x(exploding_bomb_x), .exploding_bomb_y(exploding_bomb_y)
);

explosion bme

(
    .clk(sys_clk), .reset(Sw0), .b_x(b_x), .b_y(b_y), .v_x(hc), .v_y(vc),
    .exploding_bomb_x(exploding_bomb_x), .exploding_bomb_y(exploding_bomb_y), .C(Middle_DPB),
    .exploding_x(exploding_x), .exploding_y(exploding_y), .bomb_explosion_on(explosion_rgb_en),  
    .rgb_out(explosion_rgb)
);

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
                6'b100010: {vgaR, vgaG, vgaB} <= 12'b1111_1111_1111; //HANDLE OVERLAY when EXPLOSION SPRITE AND BOBMERMAN ON
                6'b100100: {vgaR, vgaG, vgaB} <= 12'b1111_1111_1111; //HANDLE OVERLAY IMAGE CASE BOMB AND BOMBERMAN ON SAME LOCATION
                6'b100110: {vgaR, vgaG, vgaB} <= explosion_rgb; //HANDLE OVERLAY IMAGE WHEN BOmberman, bomb,explosion on same tile
                default: {vgaR, vgaG, vgaB} <= 12'b0110_1001_1100;
            endcase
        end
        else
            {vgaR, vgaG, vgaB} <= 12'b0000_0000_0000;
    end
endmodule