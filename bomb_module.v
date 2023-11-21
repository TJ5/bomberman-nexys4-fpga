//Should bomb module also take care of the explosion?

module bomb_module 
(   input clk,reset,                                    //System Clock, Game Reset
    input [9:0] b_x, b_y,                              //Bomberman location
    input [9:0] v_x, v_y,                              //Current Pixel location
    input  C,                                        // Bomb button input
    output bomb_on,                                     //Let top module know if current pixel is inside bomb sprite
    output [11:0] rgb_out,                              //RGB output
);


    /* INPUTS */
    wire clk, reset;
    wire [9:0] b_x, b_y, v_x, v_y;
    wire C;

    /* OUTPUTS */     
    wire bomb_on;
    wire [11:0] rgb_out;

endmodule