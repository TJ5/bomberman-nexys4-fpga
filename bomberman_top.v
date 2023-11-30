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
assign Reset = Sw0;
//RGB Signals
wire [11:0] bomberman_rgb,
            breakable_wall_rgb,
            enemy_rgb_1,
            enemy_rgb_2,
            enemy_rgb_3,
            enemy_rgb_4,
            enemy_rgb_5,
            enemy_rgb_6,
            bomb_rgb,
            explosion_rgb,
            unbreakable_wall_rgb;

//RGB Enable signals
wire 
    bomberman_rgb_en,
    breakable_wall_rgb_en,
    enemy_rgb_en_1,
    enemy_rgb_en_2,
    enemy_rgb_en_3,
    enemy_rgb_en_4,
    enemy_rgb_en_5,
    enemy_rgb_en_6,
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
wire explosion_write_enable;

//Game over
wire game_over;

// Send start enemy movement signal
wire enemy_start;



//Bomberman blocked - [Left, Right, Up, Down] 
//If the corresponding direction is blocked the bit is set to 1

wire [3:0] bomberman_blocked_bw; //breakable wall module blocks
wire [3:0] bomberman_blocked_ubw = 4'b0000; //unbreakable wall module blocks

wire [3:0] bomberman_blocked; //final blocked signal
assign bomberman_blocked = bomberman_blocked_bw | bomberman_blocked_ubw; 

//Enemy starts moving as soon as Bomberman moves
assign enemy_start = BtnL || BtnU || BtnD || BtnR;

//enemy blocked array
wire [3:0] enemy_blocked[0:5];

//enemy location array

wire [9:0] enemy_x[0:5];
wire [9:0] enemy_y[0:5];

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
    .D(Down_DPB), .C(Middle_DPB), .b_x(b_x), .b_y(b_y), .e_x(exploding_bomb_x), .e_y(exploding_bomb_y), 
    .game_over(game_over), .explosion_SCEN(explosion_write_enable),
    .bomberman_blocked(bomberman_blocked), .v_x(hc), .v_y(vc), .rgb_out(bomberman_rgb),
    .bomberman_on(bomberman_rgb_en));
   
bomb bmb
(
    .clk(sys_clk), .reset(Sw0), .b_x(b_x), .b_y(b_y), .v_x(hc), .v_y(vc), .C(Middle_DPB),
    .bomb_x(bomb_x), .bomb_y(bomb_y), .bomb_on(bomb_rgb_en),  .rgb_out(bomb_rgb), 
    .exploding_bomb_x(exploding_bomb_x), .exploding_bomb_y(exploding_bomb_y), .explosion_write_enable(explosion_write_enable)
);

explosion bme

(
    .clk(sys_clk), .reset(Sw0), .b_x(b_x), .b_y(b_y), .v_x(hc), .v_y(vc),
    .exploding_bomb_x(exploding_bomb_x), .exploding_bomb_y(exploding_bomb_y), .C(Middle_DPB),
    .exploding_x(exploding_x), .exploding_y(exploding_y), .bomb_explosion_on(explosion_rgb_en),  
    .rgb_out(explosion_rgb), .explosion_write_enable(explosion_write_enable), .explosion_timer_clk(DIV_CLK[7])
);

box_top box_top
    (.clk(sys_clk), .reset(Reset), .b_x(b_x), .b_y(b_y), .v_x(hc), .v_y(vc), 
    .box_on(breakable_wall_rgb_en), .bomberman_blocked(bomberman_blocked_bw), .rgb_out(breakable_wall_rgb),
    .e_x(exploding_bomb_x), .e_y(exploding_bomb_y), .explosion_SCEN(explosion_write_enable), .enemy_blocked0(enemy_blocked[0]),
    .enemy_blocked1(enemy_blocked[1]), .enemy_blocked2(enemy_blocked[2]), .enemy_blocked3(enemy_blocked[3]), .enemy_blocked4(enemy_blocked[4]),
    .enemy_blocked5(enemy_blocked[5]),
    .enemy_x0(enemy_x[0]), .enemy_y0(enemy_y[0]), .enemy_x1(enemy_x[1]), .enemy_y1(enemy_y[1]), .enemy_x2(enemy_x[2]), .enemy_y2(enemy_y[2]),
    .enemy_x3(enemy_x[3]), .enemy_y3(enemy_y[3]), .enemy_x4(enemy_x[4]), .enemy_y4(enemy_y[4]), .enemy_x5(enemy_x[5]), .enemy_y5(enemy_y[5]));

//* Instantiate module for enemy//*

    //pixel coordinate boundaries for VGA display area, based on display_controller.v
    localparam MAX_X = 784;
    localparam MIN_X = 143;
    localparam MAX_Y = 516;
    localparam MIN_Y =  34;
    
    //tile size
    localparam T_SIZE =16;

//Initial locations for bots
wire [9:0] sx_1, sx_2, sx_3, sx_4,sx_5,sx_6;
wire [9:0] sy_1,sy_2,sy_3,sy_4,sy_5,sy_6;

//Assigning initial locations;

assign sx_1 = MAX_X-32;
assign sy_1 = MAX_Y-32;
assign sx_2 = MAX_X-64;
assign sy_2 = MAX_Y-64;
assign sx_3 = MAX_X-96;
assign sy_3 = MAX_Y-96;
assign sx_4 = MIN_X +144;
assign sy_4 = MIN_Y +144;
assign sx_5 = MIN_X + 48;
assign sy_5 = MIN_Y + 48;
assign sx_6 = MIN_X + 80;
assign sy_6 = MIN_Y +80;


//Send signal that enemy sprite overlaps with bomberman sprite -> life lost
wire death_signal;

//Send signal that enemy sprite overlaps with bomberman sprite -> life lost , from different enemies
wire death_signal_1,death_signal_2,death_signal_3,death_signal_4,death_signal_5, death_signal_6;
wire enemy_killed_1, enemy_killed_2, enemy_killed_3, enemy_killed_4, enemy_killed_5, enemy_killed_6;
wire player_wins;
assign player_wins = enemy_killed_1 && enemy_killed_2 && enemy_killed_3 && enemy_killed_4 && enemy_killed_5 && enemy_killed_6;
assign death_signal = death_signal_1 || death_signal_2 || death_signal_3 || death_signal_4 || death_signal_5 || death_signal_6;



enemy em_0
    (.clk(sys_clk), .reset(Sw0), .b_x(b_x), .b_y(b_y), .enemy_blocked(enemy_blocked[0]), .v_x(hc), .v_y(vc), 
    .rgb_out(enemy_rgb_1), .death_signal(death_signal_1), .explosion_SCEN(explosion_write_enable),
    .enemy_start(enemy_start), .set_x(sx_1),.set_y(sy_1), .e_x(exploding_bomb_x), .e_y(exploding_bomb_y),
    .enemy_on(enemy_rgb_en_1), .enemy_x(enemy_x[0]), .enemy_y(enemy_y[0]), .enemy_killed(enemy_killed_1));

enemy em_1
    (.clk(sys_clk), .reset(Sw0), .b_x(b_x), .b_y(b_y), .enemy_blocked(enemy_blocked[1]), .v_x(hc), .v_y(vc), 
    .rgb_out(enemy_rgb_2),  .death_signal(death_signal_2), .explosion_SCEN(explosion_write_enable),
    .enemy_start(enemy_start), .set_x(sx_2),.set_y(sy_2), .e_x(exploding_bomb_x), .e_y(exploding_bomb_y),
    .enemy_on(enemy_rgb_en_2), .enemy_x(enemy_x[1]), .enemy_y(enemy_y[1]), .enemy_killed(enemy_killed_2));
    
enemy em_2
    (.clk(sys_clk), .reset(Sw0), .b_x(b_x), .b_y(b_y), .enemy_blocked(enemy_blocked[2]), .v_x(hc), .v_y(vc), 
    .rgb_out(enemy_rgb_3), .death_signal(death_signal_3), .explosion_SCEN(explosion_write_enable),
    .enemy_start(enemy_start), .set_x(sx_3),.set_y(sy_3), .e_x(exploding_bomb_x), .e_y(exploding_bomb_y),
    .enemy_on(enemy_rgb_en_3), .enemy_x(enemy_x[2]), .enemy_y(enemy_y[2]), .enemy_killed(enemy_killed_3));

enemy em_3
    (.clk(sys_clk), .reset(Sw0), .b_x(b_x), .b_y(b_y), .enemy_blocked(enemy_blocked[3]), .v_x(hc), .v_y(vc), 
    .rgb_out(enemy_rgb_4), .death_signal(death_signal_4), .explosion_SCEN(explosion_write_enable),
    .enemy_start(enemy_start), .set_x(sx_4),.set_y(sy_4), .e_x(exploding_bomb_x), .e_y(exploding_bomb_y),
    .enemy_on(enemy_rgb_en_4), .enemy_x(enemy_x[3]), .enemy_y(enemy_y[3]), .enemy_killed(enemy_killed_4));

enemy em_4
    (.clk(sys_clk), .reset(Sw0), .b_x(b_x), .b_y(b_y), .enemy_blocked(enemy_blocked[4]), .v_x(hc), .v_y(vc), 
    .rgb_out(enemy_rgb_5),  .death_signal(death_signal_5), .explosion_SCEN(explosion_write_enable),
    .enemy_start(enemy_start), .set_x(sx_5),.set_y(sy_5), .e_x(exploding_bomb_x), .e_y(exploding_bomb_y),
    .enemy_on(enemy_rgb_en_5), .enemy_x(enemy_x[4]), .enemy_y(enemy_y[4]), .enemy_killed(enemy_killed_5));
enemy em_5
    (.clk(sys_clk), .reset(Sw0), .b_x(b_x), .b_y(b_y), .enemy_blocked(enemy_blocked[5]), .v_x(hc), .v_y(vc), 
    .rgb_out(enemy_rgb_6), .death_signal(death_signal_6), .explosion_SCEN(explosion_write_enable),
    .enemy_start(enemy_start), .set_x(sx_6),.set_y(sy_6), .e_x(exploding_bomb_x), .e_y(exploding_bomb_y),
    .enemy_on(enemy_rgb_en_6), .enemy_x(enemy_x[5]), .enemy_y(enemy_y[5]), .enemy_killed(enemy_killed_6));


//* Instantiate module for enemy//*

always @ (posedge sys_clk)
    begin
        if (bright == 1)
        begin
            if (game_over || death_signal) 
            begin
                {vgaR, vgaG, vgaB} <= 12'b1111_0000_0000; //Red = lose
            end
            else if (player_wins)
            begin
                {vgaR, vgaG, vgaB} <= 12'b0000_1111_0000; //Green = win
            end
            else 
            begin
                case ({enemy_rgb_en_2,enemy_rgb_en_3,enemy_rgb_en_4,enemy_rgb_en_5,enemy_rgb_en_6,bomberman_rgb_en, breakable_wall_rgb_en, enemy_rgb_en_1, bomb_rgb_en, explosion_rgb_en, unbreakable_wall_rgb_en})
                    11'b00000000001: {vgaR, vgaG, vgaB} <= unbreakable_wall_rgb;
                    11'b00000000010: {vgaR, vgaG, vgaB} <= explosion_rgb;
                    11'b00000000100: {vgaR, vgaG, vgaB} <= bomb_rgb;
                    11'b00000001000: {vgaR, vgaG, vgaB} <= enemy_rgb_1;
                    11'b00000010000: {vgaR, vgaG, vgaB} <= breakable_wall_rgb;
                    11'b00000100000: {vgaR, vgaG, vgaB} <= bomberman_rgb;
                    11'b10000000000: {vgaR, vgaG, vgaB} <= enemy_rgb_2;
                    11'b01000000000: {vgaR, vgaG, vgaB} <= enemy_rgb_3;
                    11'b00100000000: {vgaR, vgaG, vgaB} <= enemy_rgb_4;
                    11'b00010000000: {vgaR, vgaG, vgaB} <= enemy_rgb_5;
                    11'b00001000000: {vgaR, vgaG, vgaB} <= enemy_rgb_6;
                    11'b00000100010: {vgaR, vgaG, vgaB} <= bomberman_rgb; //HANDLE OVERLAY when EXPLOSION SPRITE AND BOBMERMAN ON
                    11'b00000100100: {vgaR, vgaG, vgaB} <= bomberman_rgb; //HANDLE OVERLAY IMAGE CASE BOMB AND BOMBERMAN ON SAME LOCATION
                    11'b00000100110: {vgaR, vgaG, vgaB} <= bomberman_rgb; //HANDLE OVERLAY IMAGE WHEN BOmberman, bomb,explosion on same tile
                    
                    default: {vgaR, vgaG, vgaB} <= 12'b0110_1001_1100;
                endcase
            end
        end
        else
            {vgaR, vgaG, vgaB} <= 12'b0000_0000_0000;
    end
endmodule
