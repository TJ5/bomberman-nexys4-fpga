//Work in progress

module explosion 
(   input clk,reset,                                    //System Clock, Game Reset
    input [9:0] b_x, b_y,                              //Bomberman location
    input [9:0] v_x, v_y,                              //Current Pixel location
    input [9:0] exploding_bomb_x, exploding_bomb_y,    //Exploding Bomb location
    input C, //User placed bomb
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
    localparam EXPLOSION_H = 16;
  
   
   //Iterate through all the exploding sites 0 to 12 -> Up to k <13
   integer k;

   //Explosion Radius
   /*
                   3
                   2
                   1
           12 11 10 0 7 8 9
                   4 
                   5
                   6
   */
   
   //1D array contains all exploding site locations caused by a bomb explosion
   reg [9:0] explosion_x_sites [0:12];
   reg [9:0] explosion_y_sites [0:12];

    

    always @(posedge clk, posedge reset)
    begin    
        if (reset)
        begin
            //Initialize all exploding sites to zero
            for (k = 0; k < 13; k = k + 1) 
            begin
                //NOTE: We will need to add an if condition to check if the radius is within the screen
                explosion_x_sites[k] <= 0;
                explosion_y_sites[k] <= 0;
            end
        end
        else
        begin
            //In the current clock, we need to update the 1D array that has all the exploding sites...
            //using the exploding bomb location
            //NOTE: This means that the 1D array is updated after 1 clock when bomb has exploded
            for (k = 0; k < 13; k = k + 1) 
            begin
                //NOTE: We will need to add an if condition to check if the radius is within the screen
                if(k==0)
                begin
                    explosion_x_sites[k] <= exploding_bomb_x;
                    explosion_y_sites[k] <= exploding_bomb_y;
                end
                else if(k<4)
                begin
                    explosion_x_sites[k] <= exploding_bomb_x;
                    explosion_y_sites[k] <= exploding_bomb_y - (16*k);
                end
                else if(k<7)
                begin
                    explosion_x_sites[k] <= exploding_bomb_x;
                    explosion_y_sites[k] <= exploding_bomb_y + (16*(k-3));
                end
                else if(k<10)
                begin
                    explosion_x_sites[k] <= exploding_bomb_x + (16*(k-6));
                    explosion_y_sites[k] <= exploding_bomb_y;
                end
                else if(k<13)
                begin
                    explosion_x_sites[k] <= exploding_bomb_x - (16*(k-9));
                    explosion_y_sites[k] <= exploding_bomb_y;
                end
            end
        end
                
    end

   
    integer j;
    
    //Similar idea to bomb module where this always block is used update the registers that ...
    //used to determine RGB out value
    always @ (posedge clk)
    begin
        for (j = 0; j < 13; j = j + 1)
        begin
            if (((v_x >= explosion_x_sites[j][9:0]) && (v_x <= explosion_x_sites[j][9:0] + EXPLOSION_W - 1) && (v_y >= explosion_y_sites[j][9:0]) && (v_y <= explosion_y_sites[j][9:0] + EXPLOSION_H - 1)))
            begin
                exploding_x <=  explosion_x_sites[j][9:0];
                exploding_y <=  explosion_y_sites[j][9:0];
            end
        end
    end
     

                    
// * BOMB RGB OUT *//
assign col = v_x - exploding_x; // column of current pixel within bomb sprite
assign row = v_y - exploding_y; // row of current pixel within bomb sprite

// instantiate bomb ROM, Note color_data_bomb will output the color of the current pixel within the bomb sprite
explosion_rom explosion_rom_unit(.clk(clk), .row(row), .col(col), .color_data(rgb_out));



           
// Notify top_module that current pixel is inside of bomb's sprite, so it should display the rgb_out from the bomb module 
assign bomb_explosion_on =  ((v_x >= exploding_x) && (v_x <= exploding_x + EXPLOSION_W - 1) && (v_y >= exploding_y) && (v_y <= exploding_y + EXPLOSION_H - 1)); 



endmodule

/*
NOTE: 
    reg last_explosion;
     //Perhaps a timer that is sensitive to changes, if after 40000000 clock etc..., no new input then we explosion_off = 0

//reg [31:0] last_explosion_timer;

//reg active; */