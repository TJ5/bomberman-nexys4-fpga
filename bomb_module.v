//Should bomb module also take care of the explosion?

module bomb 
(   input clk,reset,                                    //System Clock, Game Reset
    input [9:0] b_x, b_y,                              //Bomberman location
    input [9:0] v_x, v_y,                              //Current Pixel location
    input  C,                                          // Bomb button input
    output [9:0] bomb_x, bomb_y,                       //Bomb location
    output bomb_on,                                     //Let top module know if current pixel is inside bomb sprite
    output [11:0] rgb_out,       //                       //RGB output
    output [9:0] exploding_bomb_x, exploding_bomb_y    //Exploding bomb location
);
    /* INPUTS */
    wire clk, reset;
    wire [9:0] b_x, b_y, v_x, v_y;
    wire C;

    /* OUTPUTS */     
    wire bomb_on;
    wire [11:0] rgb_out;
    reg [9:0] bomb_x, bomb_y;
    reg [9:0] exploding_bomb_x, exploding_bomb_y;

     //Bomb tile width height
    localparam BOMB_W = 16;
    localparam BOMB_H = 16;
    
    //Time that needs to be reached before Bomberman starts moving
    //For 21 bit counter, the range is 0 to 2097152
    localparam TIME_LIMIT = 1400000;
    
    localparam NUM_BOMBS = 5;
    
 
 

  
// * FSM THAT UPDATES BOMBERMAN'S SPRITE LOCATION *//

// Bomberman sprite location -> pixel location with respect to top left corner
//Assume user will not press multiple buttons at once, if they do then bomberman goes idle

   
   //21 bit counter
   reg[20:0] counter;
   
   //Bomb #1 counter
   reg[31:0] b1_counter;
   
   //holds the current bomb location being used to output RGB values
   wire[9:0] current_bomb_x;  
   wire[9:0] current_bomb_y;
   
   //holds the pixel locations of, Note 11th bit will be used to determine if bomb is active/inactive
   reg [10:0] bomb_x_locations [0:5];
   reg [10:0] bomb_y_locations [0:5];
   
   //counter to iterate through all the bomb locations
 //  reg [0:5] i;
   
   //counter to deactivate the bombs 
   reg [31:0] bomb_timer [0:5];
   
   //states IDLE, Setting BOMB
   reg state;
   
   localparam IDLE = 1'b0;
   localparam SETTING_BOMB = 1'b1;
   
   reg [2:0] active_bombs;
   
   integer k;
   integer i;
   integer found_spot = 1;
   
    always @(posedge clk)
        begin
            if(reset)
            begin
                i <=0;
                state <= IDLE;
                active_bombs <= 0;
                
                bomb_x_locations[0][10] <= 1'b0;
                bomb_y_locations[0][10]  <= 1'b0;
                
                bomb_x_locations[1][10] <= 1'b0;
                bomb_y_locations[1][10]  <= 1'b0;
                
                bomb_x_locations[2][10] <= 1'b0;
                bomb_y_locations[2][10]  <= 1'b0;
                
                bomb_x_locations[3][10] <= 1'b0;
                bomb_y_locations[3][10]  <= 1'b0;
                
                bomb_x_locations[4][10] <= 1'b0;
                bomb_y_locations[4][10]  <= 1'b0;
                
                bomb_x_locations[5][10] <= 1'b0;
                bomb_y_locations[5][10]  <= 1'b0;   
            end
            
            else
            
            for (k = 0; k < 6; k = k + 1) 
            begin
               if ((bomb_x_locations[k][10]) && (bomb_y_locations[k][10])) //if bomb is active add to that bomb's counter
               begin
                     if(bomb_timer[k] == 400000000)
                     begin
                        bomb_timer[k] <= 0;
                        bomb_x_locations[k][10] <= 1'b0;  //Set ith bomb to inactive
                        bomb_y_locations[k][10] <= 1'b0; //Set ith bomb to inactive
                        active_bombs <= active_bombs -1;
                        exploding_bomb_x <= bomb_x_locations[k][9:0];// set the x coordinate for exploding bomb location
                        exploding_bomb_y <= bomb_y_locations[k][9:0];//set the y coordinate for exploding bomb location
                     end
                     else
                        bomb_timer[k] <= bomb_timer[k] + 1;
                end
              end
            
            
                case (state)
     
                   IDLE: 
                   begin
                     if(C)
                     begin
                        state <= SETTING_BOMB;
                        found_spot = 1;
                     end
                   end
                   
                   SETTING_BOMB:
                   begin
                      for (i = 0; i < 6; i = i + 1)
                      begin 
                            if(!(bomb_x_locations[i][10]) && !(bomb_y_locations[i][10]) && found_spot) //check the 11th bit of the ith ele
                            begin
                                bomb_x_locations[i][10] <= 1'b1;  //Set ith bomb to active
                                bomb_y_locations[i][10]  <= 1'b1; //Set ith bomb to active
                                state <= IDLE;
                                bomb_x_locations[i][9:0] <= b_x;  //Set x coordinate for address for ith bomb
                                bomb_y_locations[i][9:0] <= b_y;  //Set y coordinate for address for ith bomb
                                found_spot = 0;
                                active_bombs <= active_bombs + 1;                                  
                            end
                            else
                            begin
                                state <=IDLE;
                                //i = 6;
                            end              
                        end
                        
                    end
                    //default: state <= 1;
                    endcase 
        end
    //reg all_bombs_off;
    integer j;
    always @ (posedge clk)
    
    begin
        for (j = 0; j < 6; j = j + 1)
        
        begin
            if ((bomb_x_locations[j][10]) && (bomb_y_locations[j][10]) && ((v_x >= bomb_x_locations[j][9:0]) && (v_x <= bomb_x_locations[j][9:0] + BOMB_W - 1) && (v_y >= bomb_y_locations[j][9:0]) && (v_y <= bomb_y_locations[j][9:0] + BOMB_H - 1)))
            begin
                            bomb_x <=  bomb_x_locations[j][9:0];
                            bomb_y <=  bomb_y_locations[j][9:0];
                            //all_bombs_off <=0;
            end
           
         end
     end
     

   



                    
// * BOMB RGB OUT *//
assign col = v_x - bomb_x; // column of current pixel within bomb sprite
assign row = v_y - bomb_y; // row of current pixel within bomb sprite

// instantiate bomb ROM, Note color_data_bomb will output the color of the current pixel within the bomb sprite
bomb_rom bomb_rom_unit(.clk(clk), .row(row), .col(col), .color_data(rgb_out));
           
// Notify top_module that current pixel is inside of bomb's sprite, so it should display the rgb_out from the bomb module 
assign bomb_on = (active_bombs > 0)&& ((v_x >= bomb_x) && (v_x <= bomb_x + BOMB_W - 1) && (v_y >= bomb_y) && (v_y <= bomb_y + BOMB_H - 1)); 

// ((v_x >= bomb_x_locations[j][9:0]) && (v_x <= bomb_x_locations[j][9:0] + BOMB_W - 1) && (v_y >= bomb_y_locations[j][9:0]) && (v_y <= bomb_y_locations[j][9:0] + BOMB_H - 1))
// (bomb_x_locations[j][10])


endmodule