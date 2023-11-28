module bomberman
    (input clk,reset,                   //System Clock, Game Reset
    input L, U, R, D, C, 	            //bomberman actions -> Comes from top  module
    input v_x, v_y,                     //current pixel location -> Comes from vga_sync module
    input [9:0] e_x, e_y,                     //Explosion x,y
    input explosion_SCEN,               //Explosion single clock enable pulse
    input [3:0] bomberman_blocked,      //bomberman is allowed to move? -> Comes from B_compare module
    output reg game_over,                    //game is over? -> Comes from top module
    output [9:0] b_x, b_y,              //top left corner pixel location of bomberman sprite -> Goes to Bomberman_Rom_module
    output bomberman_on,                //current pixel location is inside bomberman sprite? -> Goes to Top_module 
    output [11:0] rgb_out               //color of current pixel within the bomberman sprite -> Goes to Top_module
    );
    
    /* INPUTS */
    wire clk, reset;
    wire [9:0] v_x, v_y;
    wire [3:0] bomberman_blocked;

    /* OUTPUTS */
    wire bomberman_on;
    reg [9:0] b_x, b_y;
    wire [11:0] rgb_out;


    //pixel coordinate boundaries for VGA display area, based on display_controller.v
    localparam MAX_X = 784;
    localparam MIN_X = 143;
    localparam MAX_Y = 516;
    localparam MIN_Y =  34;

    //Bomberman tile width height
    localparam B_W = 16;
    localparam B_H = 16;

    //Explosion dimensions - from the explosion pixel, 48 pixels up and left, or 63 pixels right and down
    localparam E_HP = 48; //height positive (number of pixels up from e_x)
    localparam E_WP = 63; //width positive
    localparam E_HN = 63; //height negative
    localparam E_WN = 48; //width negative
    localparam E_Width = 16; //width of the beams 

    //Wall locations relative to space taken up by Bomberman
    localparam LEFT_WALL = MIN_X;
    localparam RIGHT_WALL = MAX_X - B_W;
    localparam TOP_WALL = MIN_Y;
    localparam BOTTOM_WALL = MAX_Y - B_H;

    //Time that needs to be reached before Bomberman starts moving
    //For 21 bit counter, the range is 0 to 2097152
    localparam TIME_LIMIT = 1400000;

    reg exploded_temp_x, exploded_temp_y;


// * FSM THAT UPDATES BOMBERMAN'S SPRITE LOCATION *//

// Bomberman sprite location -> pixel location with respect to top left corner
//Assume user will not press multiple buttons at once, if they do then bomberman goes idle

localparam Left = 4'b1000;                        
localparam Right = 4'b0100; 
localparam Up = 4'b0010;
localparam Down = 4'b0001;
localparam Idle = 4'b0000;

   reg [3:0] movement_state;	
   assign {q_Left, q_Right, q_Up, q_Down} = movement_state;

    wire blocked_left, blocked_right, blocked_up, blocked_down;
   // Assign individual bits
    assign blocked_left  = bomberman_blocked[0];
    assign blocked_right = bomberman_blocked[1];
    assign blocked_up    = bomberman_blocked[2];
    assign blocked_down  = bomberman_blocked[3];
   
   //21 bit counter
   reg[20:0] counter;
 
    always @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                    //Initialize bomberman to corner of the map
                    b_x     <= MIN_X;                 
                    b_y     <= MIN_Y;
                    //Initialize movement state to idle
                    movement_state <= Idle;
                    game_over <= 0;
                end
            
            else begin
                if (explosion_SCEN) begin
                    //Explosion resembles a plus sign - exploded_temp_x represents the horizontal part of the plus sign
                    //exploded_temp_y represents the vertical part
                    exploded_temp_x = ((b_x + B_W >= e_x - E_WN) && (b_x <= e_x + E_WP) && 
                        (((b_y >= e_y) && (b_y <= e_y + E_Width)) || ((b_y + B_H < e_y + E_Width) && (b_y + B_H > e_y))));
                    
                    exploded_temp_y = ((b_y <= e_y + E_HN) && (b_y + B_H >= e_y - E_HP) && 
                        (((b_x >= e_x) && (b_x <= e_x + E_Width)) || ((b_x + B_W >= e_x) && (b_x + B_W <= e_x + E_Width))));

                    game_over <= (game_over || exploded_temp_x || exploded_temp_y);
                end
                //TODO add enemy collision logic here
                // if (enemy_SCEN) begin...
                case (movement_state)
                    Idle:
                        begin
                        //NSL
                        if (L&&(b_x >= LEFT_WALL))
                            movement_state <= Left;
                        else if (R && (b_x <= RIGHT_WALL))
                            movement_state <= Right;
                        else if (U && (b_y >= TOP_WALL))
                            movement_state <= Up;
                        else if (D && (b_y <= BOTTOM_WALL))
                            movement_state <= Down;
                        //else we stay idle

                        //RTL - b_x and b_y don't need to be updated
                            counter <=0;
                        end
                    Left:
                        begin
                        //NSL
                        if(!L)
                            movement_state <= Idle;
                        //else we stay left

                        //RTL
                        if(!blocked_left && !game_over && (b_x > LEFT_WALL) && (counter == TIME_LIMIT))
                            b_x <= b_x - 1;
                        //else
                           // b_x <= b_x;
                            
                        if (counter == TIME_LIMIT)
                            counter <= 0;
                        else
                            counter <= counter +1;
                        end
    
                    Right:
                        begin
                        //NSL
                        if(!R)
                            movement_state <= Idle;
                        //else we stay right

                        //RTL
                        if(!blocked_right && !game_over && (b_x <= RIGHT_WALL) && (counter== TIME_LIMIT))
                            b_x <= b_x + 1;
                       // else
                            //b_x <= b_x;
                        if (counter == TIME_LIMIT)
                            counter <= 0;
                        else
                            counter <= counter +1;
                        
                        end                                       
                    Down:
                        begin
                        //NSL
                        if(!D)
                            movement_state <= Idle;
                        //else we stay down

                        //RTL
                        if(!blocked_down && !game_over && (b_y < BOTTOM_WALL) && (counter==TIME_LIMIT))
                            b_y <= b_y + 1;
                        //else
                           // b_y <= b_y;
                            
                        if (counter == TIME_LIMIT)
                            counter <= 0;
                        else
                            counter <= counter +1;
                                                
                        end
                    Up:
                        begin
                        //NSL
                        if(!U)
                            movement_state <= Idle;
                        //else we stay up

                        //RTL
                        if(!blocked_up && !game_over && (b_y > TOP_WALL) && (counter==TIME_LIMIT))
                            b_y <= b_y - 1;
                        //else
                          //  b_y <= b_y;
                        if (counter == TIME_LIMIT)
                            counter <= 0;
                        else
                            counter <= counter +1;                        
                                    
                        end
                        
                    default:		
						movement_state <= Idle;
                endcase
            end
        end

    always @(posedge explosion_SCEN)
    begin

                
    end
// * BOMBERMAN RGB OUT *//
assign col = v_x - b_x; // column of current pixel within bomberman sprite
assign row = v_y - b_y; // row of current pixel within bomberman sprite

// instantiate bomberman ROM, Note color_data_bomberman will output the color of the current pixel within the bomberman sprite
bomberman_rom bm_rom_unit(.clk(clk), .row(row), .col(col), .color_data(rgb_out));
           
// Notify top_module that current pixel is inside of bomberman's sprite, so it should display the rgb_out from the bombermman module 
assign bomberman_on = (v_x >= b_x) && (v_x <= b_x + B_W - 1) && (v_y >= b_y) && (v_y <= b_y + B_H - 1);

endmodule