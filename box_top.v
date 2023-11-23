//This module is a top module for all boxes
//It will instantiate all the box objects and compare the current pixel location with the box objects locations

module box_top(
    input clk,reset,                                    //System Clock, Game Reset
    input [9:0] b_x, b_y,                              //Bomberman location
    input [9:0] v_x, v_y,                              //Current Pixel location
    output box_on,                                     //Let top module know if current pixel is inside any box sprite
    output reg [3:0] bomberman_blocked,                     //Blocked directions
    output [11:0] rgb_out                             //RGB output

);
    localparam NUM_WALLS = 2;

    //Wall tile width height
    localparam W_W = 16;
    localparam W_H = 16;

    localparam B_W = 16;
    localparam B_H = 16;

    wire[9:0] box_x[0:NUM_WALLS - 1]; //Array of box x locations
    wire[9:0] box_y[0:NUM_WALLS - 1]; //Array of box y locations
    reg[NUM_WALLS:0] boxes_on; //Array of box on signals

    reg [9:0] row, col; //Row and column of current pixel in sprite
    integer i;

    assign box_x[0] = 10'd160;
    assign box_y[0] = 10'd50;

    assign box_x[1] = 10'd177;
    assign box_y[1] = 10'd67;
    //... add more boxes here


    always @ (posedge clk)
    begin
        bomberman_blocked <= 4'b0000;
        for (i = 0; i < NUM_WALLS; i = i + 1)
        begin
            boxes_on[i] <= (v_x >= box_x[i]) && (v_x <= box_x[i] + W_W - 1) && (v_y >= box_y[i]) && (v_y <= box_y[i] + W_H - 1);
            if (boxes_on[i] == 1)
            begin
                {row, col} <= {v_x - box_x[i], v_y - box_y[i]};
            end

            //Bomberman blocked logic

            //Left
            if ((b_x >= box_x[i]) && (b_x <= box_x[i] + W_W))
            begin
                if (((b_y + B_H > box_y[i]) && (b_y + B_H) <= box_y[i] + W_H) || ((b_y >= box_y[i]) && (b_y < box_y[i] + W_H)))
                    bomberman_blocked[0] <= 1;
            end
            //Right
            if ((b_x <= box_x[i]) && (b_x >= box_x[i] - B_W))
            begin
                if (((b_y + B_H > box_y[i]) && (b_y + B_H) <= box_y[i] + W_H) || ((b_y >= box_y[i]) && (b_y < box_y[i] + W_H)))
                    bomberman_blocked[1] <= 1;
            end
            //Up
            if ((b_y >= box_y[i]) && (b_y <= box_y[i] + W_H))
            begin
                if (((b_x + B_W > box_x[i]) && (b_x + B_W <= box_x[i] + W_W)) || ((b_x >= box_x[i]) && (b_x < box_x[i] + W_W)))
                    bomberman_blocked[2] <= 1;
            end
            //Down
            if ((b_y <= box_y[i]) && (b_y + B_H >= box_y[i]))
            begin
                if (((b_x + B_W > box_x[i]) && (b_x + B_W <= box_x[i] + W_W)) || ((b_x >= box_x[i]) && (b_x < box_x[i] + W_W)))
                bomberman_blocked[3] <= 1;
            end
        end
    end
    
    //Instantiate box rom
    box_rom box_rom
        (.clk(clk), .row(row), .col(col), .color_data(rgb_out));
    
    
    //Short form for doing a bitwise or on all the boxes_on signals
    assign box_on = |boxes_on;
    
endmodule