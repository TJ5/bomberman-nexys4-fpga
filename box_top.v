//This module is a top module for all boxes
//It will instantiate all the box objects and compare the current pixel location with the box objects locations

module box_top(
    input clk,reset,                                    //System Clock, Game Reset
    input [9:0] b_x, b_y,                              //Bomberman location
    input [9:0] v_x, v_y,                              //Current Pixel location
    input [9:0] e_x, e_y,                              //Explosion location
    input explosion_SCEN,                              //Single clock enable pulse for an explosion occuring
    output box_on,                                     //Let top module know if current pixel is inside any box sprite
    output reg [3:0] bomberman_blocked,                     //Blocked directions
    output [11:0] rgb_out                             //RGB output

);
    //Number of walls in the game
    localparam NUM_WALLS = 12;

    //Wall tile width height
    localparam W_W = 16;
    localparam W_H = 16;

    //Explosion dimensions - from the explosion pixel, 48 pixels up and left, or 63 pixels right and down
    localparam E_HP = 48;
    localparam E_WP = 63;
    localparam E_HN = 63;
    localparam E_WN = 48;
    localparam E_Width = 16;

    //Bomberman tile width height (should probably be passed in from top module)
    localparam B_W = 16;
    localparam B_H = 16;

    wire[9:0] box_x[0:NUM_WALLS - 1]; //Array of box x locations
    wire[9:0] box_y[0:NUM_WALLS - 1]; //Array of box y locations
    reg[NUM_WALLS:0] boxes_on; //Array of box on signals
    reg[NUM_WALLS:0] boxes_exploded; //Array of box exploded signals, 0 if box is exploded, 1 if it still exists

    reg exploded_temp_x, exploded_temp_y; //Tempvars to represent the box being exploded 

    reg [9:0] row, col; //Row and column of current pixel in sprite
    integer i;
    
    //Box Locations
    assign box_x[0] = 10'd300;
    assign box_y[0] = 10'd100;

    assign box_x[1] = 10'd316;
    assign box_y[1] = 10'd100;

    assign box_x[2] = 10'd332;
    assign box_y[2] = 10'd100;

    assign box_x[3] = 10'd348;
    assign box_y[3] = 10'd100;

    assign box_x[4] = 10'd300;
    assign box_y[4] = 10'd116;

    assign box_x[5] = 10'd348;
    assign box_y[5] = 10'd116;

    assign box_x[6] = 10'd300;
    assign box_y[6] = 10'd132;

    assign box_x[7] = 10'd348;
    assign box_y[7] = 10'd132;

    assign box_x[8] = 10'd300;
    assign box_y[8] = 10'd148;
    
    assign box_x[9] = 10'd316;
    assign box_y[9] = 10'd148;

    assign box_x[10] = 10'd332;
    assign box_y[10] = 10'd148;

    assign box_x[11] = 10'd348;
    assign box_y[11] = 10'd148;
    //... add more boxes here


    always @ (posedge clk, posedge reset)
    begin
        if (reset)
        begin
            bomberman_blocked <= 4'b0000;
            for (i = 0; i < NUM_WALLS; i = i + 1)
                boxes_exploded[i] <= 1;
        end
        else begin
            bomberman_blocked <= 4'b0000;
            //Loop through all walls and check if current pixel is inside any of them
            for (i = 0; i < NUM_WALLS; i = i + 1)
            begin
                //Calculate if the vga pixel is within the i'th box. If true, assign boxes_on[i] to 1
                boxes_on[i] <= (v_x >= box_x[i]) && (v_x <= box_x[i] + W_W - 1) && (v_y >= box_y[i]) && (v_y <= box_y[i] + W_H - 1);
                //Assign row and column of current pixel in sprite if the vga pixel is in the i'th box
                if (boxes_on[i] == 1)
                begin
                    {row, col} <= {v_x - box_x[i], v_y - box_y[i]};
                end

                //Calculate if the box has exploded
                if (explosion_SCEN) begin
                    //boxes_exploded[i] <= !((box_x[i] >= e_x - E_WN) && (box_x[i] <= e_x + E_WP) && (box_y[i] >= e_y - E_HN) && (box_y[i] <= e_y + E_HP));
                    
                    //Explosion resembles a plus sign - exploded_temp_x represents the horizontal part of the plus sign
                    //exploded_temp_y represents the vertical part
                    exploded_temp_x = ((box_x[i] >= e_x - E_WN) && (box_x[i] <= e_x + E_WP) && 
                        (((box_y[i] >= e_y) && (box_y[i] <= e_y + E_Width)) || ((box_y[i] >= e_y - E_Width) && (box_y[i] <= e_y))));
                    
                    exploded_temp_y = ((box_y[i] >= e_y - E_HN) && (box_y[i] <= e_y + E_HP) && 
                        (((box_x[i] >= e_x) && (box_x[i] <= e_x + E_Width)) || ((box_x[i] >= e_x - E_Width) && (box_x[i] <= e_x))));

                    //Invert result because we want 0 if box is exploded, 1 if it still exists
                    //Or with inverted boxes_exploded[i] so that if the box is already exploded it will not reappear
                    boxes_exploded[i] <= !(exploded_temp_x || exploded_temp_y || ~boxes_exploded[i]);
                end
                
                //Bomberman blocked logic
                if (boxes_exploded[i]) //Box must not have been blown up to block bomberman
                begin
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
        end
    end
    
    //Instantiate box rom
    box_rom box_rom
        (.clk(clk), .row(row), .col(col), .color_data(rgb_out));
    
    
    //Short form for doing a bitwise or on all the boxes_on signals
    assign box_on = |(boxes_on & boxes_exploded);
    
endmodule