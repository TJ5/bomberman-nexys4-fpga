module bomberman
    (clk,reset                                    //System Clock, Game Reset
    L, U, R, D, C, 	              //bomberman actions -> Comes from top  module
    v_x, v_y,                                     //current pixel location -> Comes from vga_sync module
    bomberman_blocked,                                    //bomberman is allowed to move? -> Comes from B_compare module
    game_over,                                    //game is over? -> Comes from top module
    b_x, b_y,                                     //top left corner pixel location of bomberman sprite -> Goes to Bomberman_Rom_module
    bomberman_on,                                 //current pixel location is inside bomberman sprite? -> Goes to Top_module 
    rgb_out                                       //color of current pixel within the bomberman sprite -> Goes to Top_module
    );

    /* INPUTS */
   input wire clk, reset,
   input wire [9:0] v_x, v_y,   
   input wire [3:0] bomberman_blocked,  
   input wire game_over,    

   /* OUTPUTS */     
   output wire bomberman_on,   
   output wire [9:0] b_x, b_y,  
   output wire [11:0] rgb_out;   




    //pixel coordinate boundaries for VGA display area
    localparam MAX_X = 640;
    localparam MAX_Y = 480;
    localparam MIN_Y =  16;

    //Bomberman tile width height
    localparam B_W = 16;
    localparam B_H = 16;

  
// * FSM THAT UPDATES BOMBERMAN'S SPRITE LOCATION *//

// Bomberman sprite location -> pixel location with respect to top left corner
//Assume user will not press multiple buttons at once, if they do then bomberman goes idle

localparam Left = 4'b1000;                        
localparam Right = 4'b0100; 
localparam Up = 4'b0010;
localparam Down = 4'b0001;
localparam Idle = 4'b0000;

   output  q_Left, q_Right, q_Up, q_Down;
   reg [3:0] movement_state;	
   assign {q_Left, q_Right, q_Up, q_Down} = movement_state;

    wire blocked_left, blocked_right, blocked_up, blocked_down;
    bomberman_blocked[0] = blocked_down;
    bomberman_blocked[1] = blocked_up;
    bomberman_blocked[2] = blocked_right;
    bomberman_blocked[3] = blocked_left;
   
 
    always @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                //Initialize bomberman to corner of the map
                b_x     <= 0;                 
                b_y     <= 0;
                //Initialize movement state to idle
                movement_state <= Idle;
                end
            
            else
                case (movement_state)
                    Idle:
                        begin
                        //NSL
                        if (L)
                            movement_state <= Left;
                        else if (R)
                            movement_state <= Right;
                        else if (U)
                            movement_state <= Up;
                        else if (D)
                            movement_state <= Down;
                        //else we stay idle

                        //RTL - b_x and b_y don't need to be updated
                        end
                    Left:
                        begin
                        //NSL
                        if(!L)
                            movement_state <= Idle;
                        //else we stay left

                        //RTL
                        if(!blocked_left && !game_over)
                            b_x <= b_x - 1;
                        else
                            b_x <= b_x;
                        end
    
                    Right:
                        begin
                        //NSL
                        if(!R)
                            movement_state <= Idle;
                        //else we stay right

                        //RTL
                        if(!blocked_right && !game_over)
                            b_x <= b_x + 1;
                        else
                            b_x <= b_x;
                        end
                    Down:
                        begin
                        //NSL
                        if(!D)
                            movement_state <= Idle;
                        //else we stay down

                        //RTL
                        if(!blocked_down && !game_over)
                            b_y <= b_y - 1;
                        else
                            b_y <= b_y;
                        end
                    Up:
                        begin
                        //NSL
                        if(!U)
                            movement_state <= Idle;
                        //else we stay up

                        //RTL
                        if(!blocked_up && !game_over)
                            b_y <= b_y + 1;
                        else
                            b_y <= b_y;
                        end
                        
                    default:		
						movement_state <= Idle;
                endcase   
        end

                    
// * BOMBERMAN RGB OUT *//
assign col = v_x - b_x; // column of current pixel within bomberman sprite
assign row = v_y - b_y; // row of current pixel within bomberman sprite

// instantiate bomberman ROM, Note color_data_bomberman will output the color of the current pixel within the bomberman sprite
bomberman_rom bm_rom_unit(.clk(clk), .row(row), .col(col), .color_data(color_data_bomberman));
           
// Notify top_module that current pixel is inside of bomberman's sprite, so it should display the rgb_out from the bombermman module 
assign bomberman_on = (v_x >= b_x) & (v_x <= b_x + B_W - 1) & (v_y >= b_y) & (v_y <= b_y + B_H - 1);

always @ (*)
    begin
        bomberman_on = 0;
        rgb_out = 0;
        if(bomberman_on)
            rgb_out = color_data_bomberman;
    end



endmodule