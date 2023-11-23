//This module is a top module for all boxes
//It will instantiate all the box objects and compare the current pixel location with the box objects locations

module box_top(
    input clk,reset,                                    //System Clock, Game Reset
    input [9:0] b_x, b_y,                              //Bomberman location
    input [9:0] v_x, v_y,                              //Current Pixel location
    output box_on,                                     //Let top module know if current pixel is inside any box sprite
    output [3:0] bomberman_blocked,                     //Blocked directions
    output [11:0] rgb_out                             //RGB output

);
    localparam NUM_WALLS = 2;

    //Wall tile width height
    localparam W_W = 16;
    localparam W_H = 16;

    wire[9:0] box_x[0:NUM_WALLS - 1]; //Array of box x locations
    wire[9:0] box_y[0:NUM_WALLS - 1]; //Array of box y locations
    reg[NUM_WALLS:0] boxes_on; //Array of box on signals

    reg [9:0] row, col; //Row and column of current pixel in sprite
    integer i;

    assign box_x[0] = 10'd159;
    assign box_y[0] = 10'd49;

    assign box_x[1] = 10'd175;
    assign box_y[1] = 10'd65;

    always @ (posedge clk)
    begin
        for (i = 0; i < NUM_WALLS; i = i + 1)
        begin
            boxes_on[i] <= (v_x >= box_x[i]) && (v_x <= box_x[i] + W_W - 1) && (v_y >= box_y[i]) && (v_y <= box_y[i] + W_H - 1);
            if (boxes_on[i] == 1)
            begin
                {row, col} <= {v_x - box_x[i], v_y - box_y[i]};
            end
        end
    end
    
    //Instantiate box rom
    box_rom box_rom
        (.clk(clk), .row(row), .col(col), .color_data(rgb_out));
    
    
    //For now just make blocked 0
    assign bomberman_blocked = 4'b0000;

    //Short form for doing a bitwise or on all the boxes_on signals
    assign box_on = |boxes_on;
    
endmodule