module bomberman
    (input clk,reset,                                    //System Clock, Game Reset
    input L, U, R, D, C, 	              //bomberman actions -> Comes from top  module
    input v_x, v_y,                                     //current pixel location -> Comes from vga_sync module
    input [3:0] bomberman_blocked,                                    //bomberman is allowed to move? -> Comes from B_compare module
    input game_over,                                    //game is over? -> Comes from top module
    output [9:0] b_x, b_y,                                     //top left corner pixel location of bomberman sprite -> Goes to Bomberman_Rom_module
    output bomberman_on,                                 //current pixel location is inside bomberman sprite? -> Goes to Top_module 
    output [11:0] rgb_out                                       //color of current pixel within the bomberman sprite -> Goes to Top_module
    );
    
    /* INPUTS */
    wire clk, reset;
    wire [9:0] v_x, v_y;
    wire [3:0] bomberman_blocked;
    wire game_over;

    /* OUTPUTS */     
    wire bomberman_on;
    reg [9:0] b_x, b_y; 
    wire [11:0] rgb_out;


    //pixel coordinate boundaries for VGA display area
    localparam MAX_X = 740;
    localparam MIN_X = 144;
    localparam MAX_Y = 500;
    localparam MIN_Y =  144;

    //Bomberman tile width height
    localparam B_W = 16;
    localparam B_H = 16;
    
    //Wall locations relative to space taken up by Bomberman
    localparam LEFT_WALL = MIN_X;
    localparam RIGHT_WALL = MAX_X - B_W;
    localparam TOP_WALL = MIN_Y;
    localparam BOTTOM_WALL = MAX_Y - B_H;
    
    //Time that needs to be reached before Bomberman starts moving
    localparam TIME_LIMIT = 100000;
    
 
 

  
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
   
   //20 bit counter
   reg[20:0] counter;
 
    always @(posedge clk, posedge C)
        begin
            if (C)
                begin
                //Initialize bomberman to corner of the map
                b_x     <= MIN_X;                 
                b_y     <= 400;
                //Initialize movement state to idle
                movement_state <= Idle;
                
                end
            
            else
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
                        if(!blocked_left && !game_over && (b_x >= LEFT_WALL) && (counter ==100000))
                            b_x <= b_x - 1;
                        else
                            b_x <= b_x;
                            
                        if (counter == 100000)
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
                        if(!blocked_right && !game_over && (b_x <= RIGHT_WALL) && (counter==100000))
                            b_x <= b_x + 1;
                        else
                            b_x <= b_x;
                        if (counter == 100000)
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
                        if(!blocked_down && !game_over && (b_y <= BOTTOM_WALL) && (counter==100000))
                            b_y <= b_y + 1;
                        else
                            b_y <= b_y;
                            
                        if (counter == 100000)
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
                        if(!blocked_up && !game_over && (b_y >= TOP_WALL) && (counter==100000))
                            b_y <= b_y - 1;
                        else
                            b_y <= b_y;
                        if (counter == 100000)
                            counter <= 0;
                        else
                            counter <= counter +1;                        
                                    
                        end
                        
                    default:		
						movement_state <= Idle;
                endcase   
        end

                    
// * BOMBERMAN RGB OUT *//
assign col = v_x - b_x; // column of current pixel within bomberman sprite
assign row = v_y - b_y; // row of current pixel within bomberman sprite

// instantiate bomberman ROM, Note color_data_bomberman will output the color of the current pixel within the bomberman sprite
bomberman_rom bm_rom_unit(.clk(clk), .row(row), .col(col), .color_data(rgb_out));
           
// Notify top_module that current pixel is inside of bomberman's sprite, so it should display the rgb_out from the bombermman module 
assign bomberman_on = (v_x >= b_x) && (v_x <= b_x + B_W - 1) && (v_y >= b_y) && (v_y <= b_y + B_H - 1);

endmodule