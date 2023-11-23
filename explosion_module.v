//Work in progress

module explosion 
(   input clk,reset,                                    //System Clock, Game Reset
    input [9:0] b_x, b_y,                              //Bomberman location
    input [9:0] v_x, v_y,                              //Current Pixel location
    input [9:0] exploding_bomb_x, exploding_bomb_y,    //Exploding Bomb location

    output [9:0] exploding_x, exploding_y,                       //Exploding Site location
    output bomb_explosion_on,                                    //Let top module know if current pixel is inside explosion sprite
    output [11:0] rgb_out       //                       //RGB output
);
    /* INPUTS */
    wire clk, reset;
    wire [9:0] b_x, b_y, v_x, v_y;
    wire [9:0] exploding_bomb_x, exploding_bomb_y;

    /* OUTPUTS */     
    wire bomb_explosion_on;
    wire [11:0] rgb_out;
    reg [9:0] exploding_x, exploding_y;
    
     //Bomb tile width height
    localparam EXPLOSION_W = 16;
    localparam EXPLOSION_B = 16;
    
    
 
 

  
// * FSM THAT UPDATES BOMBERMAN'S SPRITE LOCATION *//

// Bomberman sprite location -> pixel location with respect to top left corner
//Assume user will not press multiple buttons at once, if they do then bomberman goes idle


   

   //counter to iterate through all the bomb locations
   reg [0:5] i;
   
   //counter to deactivate the bombs 
   reg [31:0] bomb_timer [0:5];
   
   integer k;
   
    always @(posedge clk)
        begin            
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
                     end
                     else
                        bomb_timer[k] <= bomb_timer[k] + 1;
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