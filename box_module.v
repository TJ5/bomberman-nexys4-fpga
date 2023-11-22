//Box Module will be used to create a single wall/box object
//Inside this module we can compare the locations of box objects with the current pixel location in order to determine if the current pixel is inside a box object
//Inside this module we can also compare the bomberman location with all the box objects locations we have created in order to determine if bomberman is blocked in any direction
//*Still working on this module*
module box 
(   input clk,reset,                                    //System Clock, Game Reset
    input [9:0] b_x, b_y,                              //Bomberman location
    input [9:0] w_x, w_y,                              //Wall location
    input [9:0] v_x, v_y,                              //Current Pixel location
    output box_on,                                     //Let top module know if current pixel is inside box sprite
    output [3:0] bomberman_blocked,                     //Blocked directions
    output [9:0] row, col                               //Row and col of pixel in the wall sprite
);
    //Wall tile width height
    localparam W_W = 16;
    localparam W_H = 16;

    assign box_on = (v_x >= w_x) && (v_x <= w_x + W_W - 1) && (v_y >= w_y) && (v_y <= w_y + W_H - 1);

    assign col = v_x - w_x; // column of current pixel within wall sprite
    assign row = v_y - w_y; // row of current pixel within wall sprite

endmodule