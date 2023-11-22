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

    wire[9:0] box_x[0:1]; //Array of box x locations
    wire[9:0] box_y[0:1]; //Array of box y locations

    assign box_x[0] = 10'd159;
    assign box_y[0] = 10'd49;

    assign box_x[1] = 10'd175;
    assign box_y[1] = 10'd65;

    wire box0_on, box1_on;
    wire [9:0] box0_row, box0_col, box1_row, box1_col;
    wire[3:0] box0_blocked, box1_blocked;
    //Instantiate box objects
    box box_0
        (.clk(clk), .b_x(b_x), .b_y(b_y), .v_x(v_x), .v_y(v_y), 
        .w_x(box_x[0]), .w_y(box_y[0]), .box_on(box0_on), .bomberman_blocked(box0_blocked), 
        .row(box0_row), .col(box0_col));

    box box_1
        (.clk(clk), .b_x(b_x), .b_y(b_y), .v_x(v_x), .v_y(v_y), 
        .w_x(box_x[1]), .w_y(box_y[1]), .box_on(box1_on), .bomberman_blocked(box1_blocked),
        .row(box1_row), .col(box1_col));

    reg [9:0] row, col;
    box_rom box_rom
        (.clk(clk), .row(row), .col(col), .color_data(rgb_out));
    
    always @ (posedge clk)
    begin
        case ({box1_on, box0_on})
            2'b01: {row, col} <= {box0_row, box0_col};
            2'b10: {row, col} <= {box1_row, box1_col};
            default: {row, col} <= {10'b1111111111, 10'b1111111111}; //Out of bounds value
        endcase
    end
    
    //For now just make blocked 0
    assign bomberman_blocked = 4'b0000;

    assign box_on = box0_on || box1_on;
endmodule