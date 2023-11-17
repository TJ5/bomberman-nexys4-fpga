//Box Module will be used to create the box objects in the game
//Inside this module we can compare the locations of box objects with the current pixel location in order to determine if the current pixel is inside a box object
//Inside this module we can also compare the bomberman location with all the box objects locations we have created in order to determine if bomberman is blocked in any direction
//*Still working on this module*
module box_module 
(   input clk,reset,                                    //System Clock, Game Reset
    input [9:0] b_x, b_y,                              //Bomberman location
    input [9:0] v_x, v_y,                              //Current Pixel location
    output box_on,                                     //Let top module know if current pixel is inside box sprite
    output [3:0] bomberman_blocked,                     //Blocked directions
    output [11:0] rgb_out,                              //RGB output
);


    /* INPUTS */
    wire clk, reset;
    wire [9:0] b_x, b_y, v_x, v_y;
   
    /* OUTPUTS */     
    wire [3:0] bomberman_blocked;
    wire [11:0] rgb_out;
    wire box_on;

endmodule