module enemy
    (input clk,reset,                                    //System Clock, Game Reset
    input v_x, v_y,                                     //current pixel location -> Comes from vga_sync module
    input [3:0] enemy_blocked,                                    //bomberman is allowed to move? -> Comes from B_compare module
    input [9:0] b_x, b_y,                               //bomberman location
    //input game_over,                                    //game is over? -> Comes from top module
    input enemy_start,
    input [9:0] set_x,
    input [9:0] set_y,
    input [9:0] e_x,
    input [9:0] e_y,
    input explosion_SCEN,
    output [9:0] enemy_x, enemy_y,                                     //enemy location goes to enemy module
    output enemy_on,                                 //current pixel location is inside bomberman sprite? -> Goes to Top_module 
    output [11:0] rgb_out,                                       //color of current pixel within the bomberman sprite -> Goes to Top_module
    output reg death_signal
    );

    /* INPUTS */
    wire clk, reset;
    wire [9:0] v_x, v_y;
    wire [3:0] enemy_blocked;
    wire [9:0] b_x, b_y; 
    wire enemy_start;
    wire [9:0] set_x_init;
    wire [9:0] set_y_init;
   

    /* OUTPUTS */     
    wire enemy_on;
   // wire game_over;
    reg [9:0] enemy_x, enemy_y; 
    wire [11:0] rgb_out;


    //pixel coordinate boundaries for VGA display area, based on display_controller.v
    localparam MAX_X = 784;
    localparam MIN_X = 143;
    localparam MAX_Y = 516;
    localparam MIN_Y =  34;
    
        //Explosion dimensions - from the explosion pixel, 48 pixels up and left, or 63 pixels right and down
    localparam E_HP = 48;
    localparam E_WP = 63;
    localparam E_HN = 63;
    localparam E_WN = 48;
    localparam E_Width = 16;

    //Enemy tile width height
    localparam ENEMY_W = 16;
    localparam ENEMY_H = 16;
    
    //Bomberman tile width height
    localparam B_W = 16;
    localparam B_H = 16;
        
    //Wall locations relative to space taken up by Bomberman
    localparam LEFT_WALL = MIN_X;
    localparam RIGHT_WALL = MAX_X - ENEMY_W;
    localparam TOP_WALL = MIN_Y;
    localparam BOTTOM_WALL = MAX_Y - ENEMY_H;
    
    //Time that needs to be reached before Bomberman starts moving
    //For 21 bit counter, the range is 0 to 2097152
    //localparam TIME_LIMIT = 1400000;
    localparam TIME_LIMIT = 1400000; //For now make him fast

 reg enemy_killed; //Signal that player killed the enemy
 reg exploded_temp_x, exploded_temp_y; //temp vars for explosion detection

  
// * FSM THAT UPDATES Enemy's SPRITE LOCATION *//

// Bomberman sprite location -> pixel location with respect to top left corner
//Assume user will not press multiple buttons at once, if they do then bomberman goes idle

localparam Left = 4'b1000;                        
localparam Right = 4'b0100; 
localparam Up = 4'b0010;
localparam Down = 4'b0001;
localparam Idle = 4'b0000;

   reg [3:0] movement_state;	
   
    wire blocked_left, blocked_right, blocked_up, blocked_down;
   // Assign individual bits
    assign blocked_left  = enemy_blocked[0];
    assign blocked_right = enemy_blocked[1];
    assign blocked_up    = enemy_blocked[2];
    assign blocked_down  = enemy_blocked[3];

    assign enemy_blocked = 4'b0000; //For Now assume enemy_blocked is never blocked

   
   //21 bit counter
   reg[20:0] counter;
 
    always @(posedge clk, posedge reset)
        begin
            if (reset)
                begin
                enemy_x <= set_x;
                enemy_y <= set_y;
                //Initialize movement state to idle
                movement_state <= Idle;
                death_signal <= 0;
                enemy_killed <= 0;
                end
            
            else begin
                if (explosion_SCEN) begin
                    //Explosion resembles a plus sign - exploded_temp_x represents the horizontal part of the plus sign
                    //exploded_temp_y represents the vertical part
                    exploded_temp_x = ((enemy_x + B_W >= e_x - E_WN) && (enemy_x <= e_x + E_WP) && 
                        (((enemy_y >= e_y) && (enemy_y <= e_y + E_Width)) || ((enemy_y + B_H < e_y + E_Width) && (enemy_y + B_H > e_y))));

                    exploded_temp_y = ((enemy_y <= e_y + E_HN) && (enemy_y + B_H >= e_y - E_HP) && 
                        (((enemy_x >= e_x) && (enemy_x <= e_x + E_Width)) || ((enemy_x + B_W >= e_x) && (enemy_x + B_W <= e_x + E_Width))));

                    enemy_killed <= (enemy_killed || exploded_temp_x || exploded_temp_y);
                end
                if (!enemy_killed) begin
                    //Left
                    if ((b_x >= enemy_x) && (b_x <= enemy_x + ENEMY_W))
                    begin
                        if (((b_y + B_H > enemy_y) && (b_y + B_H) <= enemy_y + ENEMY_H) || ((b_y >= enemy_y) && (b_y < enemy_y + ENEMY_H)))
                            death_signal <= 1;
                    end
                    //Right
                    if ((b_x <= enemy_x) && (b_x >= enemy_x - ENEMY_W))
                    begin
                        if (((b_y + B_H > enemy_y) && (b_y + B_H) <= enemy_y + ENEMY_H) || ((b_y >= enemy_y) && (b_y < enemy_y + ENEMY_H)))
                            death_signal <= 1;
                    end
                    //Up
                    if ((b_y >= enemy_y) && (b_y <= enemy_y + ENEMY_H))
                    begin
                        if (((b_x + B_W > enemy_x) && (b_x + B_W <= enemy_x + ENEMY_W)) || ((b_x >= enemy_x) && (b_x < enemy_x + ENEMY_W)))
                            death_signal <= 1;
                    end
                    //Down
                    if ((b_y <= enemy_y) && (b_y + B_H >= enemy_y))
                    begin
                        if (((b_x + B_W > enemy_x) && (b_x + B_W <= enemy_x + ENEMY_W)) || ((b_x >= enemy_x) && (b_x < enemy_x + ENEMY_W)))
                            death_signal <= 1;
                    end
                end
            //Deals with enemy movement
                case (movement_state)
                    Idle:
                    begin
                        //NSL && RTL
                        if(enemy_start)
                        begin
                        movement_state <= Left;
                        counter <=0;
                        end
                     end

                        //RTL - b_x and b_y don't need to be updated
          

                    Left:
                        begin
                        //NSL
                        if((enemy_x == LEFT_WALL) && enemy_y == BOTTOM_WALL)
                            movement_state <= Up;
                        else if(enemy_x == LEFT_WALL)
                            movement_state <=Right;
                       // if(!L) //if blocked then shift the movement register to a new direction
                         //   movement_state <= Idle;
                        //else we stay left

                        //RTL
                        if(!blocked_left  && (enemy_x > LEFT_WALL) && (counter == TIME_LIMIT))
                            enemy_x <= enemy_x - 1;
                        //else
                           // enemy_x <= enemy_x;
                            
                        if (counter == TIME_LIMIT)
                            counter <= 0;
                        else
                            counter <= counter +1;
                        end
    
                    Right:
                        begin
                        //NSL
                        //if(!R)
                          //  movement_state <= Idle;
                        //else we stay right
                        if ((enemy_x == RIGHT_WALL)&& (enemy_y == TOP_WALL))
                            movement_state <= Down; 
                        else if(enemy_x == RIGHT_WALL)
                            movement_state <= Left;

                        //RTL
                        if(!blocked_right  && (enemy_x < RIGHT_WALL) && (counter== TIME_LIMIT))
                            enemy_x <= enemy_x + 1;
                       // else
                            //enemy_x <= enemy_x;
                        if (counter == TIME_LIMIT)
                            counter <= 0;
                        else
                            counter <= counter +1;
                        
                        end                                       
                    Down:
                        begin
                        //NSL
                        //if(!D)
                           // movement_state <= Idle;
                        //else we stay down
                        if(enemy_y == BOTTOM_WALL && enemy_x == RIGHT_WALL)
                            movement_state <= Left;
                        else if(enemy_y == BOTTOM_WALL)
                            movement_state <= Up;


                        //RTL
                        if(!blocked_down &&  (enemy_y < BOTTOM_WALL) && (counter==TIME_LIMIT))
                            enemy_y <= enemy_y + 1;
                        //else
                           // enemy_y <= enemy_y;
                            
                        if (counter == TIME_LIMIT)
                            counter <= 0;
                        else
                            counter <= counter +1;
                                                
                        end
                    Up:
                        begin
                        //NSL
                        //if(!U)
                          //  movement_state <= Idle;
                        //else we stay up
                       if(enemy_y == TOP_WALL && enemy_x == LEFT_WALL)
                            movement_state <= Right;
                       else if(enemy_y == TOP_WALL)
                            movement_state <= Down;

                        //RTL
                        if(!blocked_up && (enemy_y > TOP_WALL) && (counter==TIME_LIMIT))
                            enemy_y <= enemy_y - 1;
                        //else
                          //  enemy_y <= enemy_y;
                        if (counter == TIME_LIMIT)
                            counter <= 0;
                        else
                            counter <= counter +1;                        
                                    
                        end
                        
                    //default:		
						//movement_state <= Idle;
                endcase
            end
        end


// * BOMBERMAN RGB OUT *//
assign col = v_x - enemy_x; // column of current pixel within bomberman sprite
assign row = v_y - enemy_y; // row of current pixel within bomberman sprite

// instantiate bomberman ROM, Note color_data_bomberman will output the color of the current pixel within the bomberman sprite
enemy_rom em_rom_unit(.clk(clk), .row(row), .col(col), .color_data(rgb_out));
           
// Notify top_module that current pixel is inside of bomberman's sprite, so it should display the rgb_out from the bombermman module 
assign enemy_on = (!enemy_killed) && (v_x >= enemy_x) && (v_x <= enemy_x + ENEMY_W - 1) && (v_y >= enemy_y) && (v_y <= enemy_y + ENEMY_H - 1);



endmodule
