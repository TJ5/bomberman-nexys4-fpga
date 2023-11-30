//This module is a top module for all boxes
//It will instantiate all the box objects and compare the current pixel location with the box objects locations

module box_top(
    input clk,reset,                                    //System Clock, Game Reset
    input [9:0] b_x, b_y,                               //Bomberman location
    input [9:0] v_x, v_y,                               //Current Pixel location
    input [9:0] e_x, e_y,                               //Explosion location
    input [9:0] enemy_x0, enemy_y0,                     //Enemy 0 location
    input [9:0] enemy_x1, enemy_y1,                     //Enemy 1 location
    input [9:0] enemy_x2, enemy_y2,                     //Enemy 2 location
    input [9:0] enemy_x3, enemy_y3,                     //Enemy 3 location
    input [9:0] enemy_x4, enemy_y4,                     //Enemy 4 location
    input [9:0] enemy_x5, enemy_y5,                     //Enemy 5 location

    input explosion_SCEN,                               //Single clock enable pulse for an explosion occuring
    output box_on,                                      //Let top module know if current pixel is inside any box sprite
    output reg [3:0] bomberman_blocked,                 //Blocked directions
    output reg [3:0] enemy_blocked0,                    //Blocked directions for enemies
    output reg [3:0] enemy_blocked1,                    //Blocked directions for enemies
    output reg [3:0] enemy_blocked2,                    //Blocked directions for enemies
    output reg [3:0] enemy_blocked3,                    //Blocked directions for enemies
    output reg [3:0] enemy_blocked4,                    //Blocked directions for enemies
    output reg [3:0] enemy_blocked5,                    //Blocked directions for enemies
    output [11:0] rgb_out                               //RGB output

);
    //Number of walls in the game
    localparam NUM_WALLS = 479;

    localparam NUM_ENEMIES = 6;
    //Wall tile width height
    localparam W_W = 16;
    localparam W_H = 16;

    //Explosion dimensions - from the explosion pixel, 48 pixels up and left, or 63 pixels right and down
    localparam E_HP = 48;
    localparam E_WP = 63;
    localparam E_HN = 63;
    localparam E_WN = 48;
    localparam E_Width = 16;

    //Enemy tile width height
    localparam ENEMY_W = 16;
    localparam ENEMY_H = 16;

    //Bomberman tile width height (should probably be passed in from top module)
    localparam B_W = 16;
    localparam B_H = 16;

    wire[9:0] box_x[0:NUM_WALLS - 1]; //Array of box x locations
    wire[9:0] box_y[0:NUM_WALLS - 1]; //Array of box y locations
    reg[NUM_WALLS:0] boxes_on; //Array of box on signals
    reg[NUM_WALLS:0] boxes_exploded; //Array of box exploded signals, 0 if box is exploded, 1 if it still exists

    reg exploded_temp_x, exploded_temp_y; //Tempvars to represent the box being exploded 

    wire[9:0] enemies_x[0:NUM_ENEMIES - 1]; //Array of enemy x locations
    wire[9:0] enemies_y[0:NUM_ENEMIES - 1]; //Array of enemy y locations

    assign enemies_x[0] = enemy_x0;
    assign enemies_y[0] = enemy_y0;
    assign enemies_x[1] = enemy_x1;
    assign enemies_y[1] = enemy_y1;
    assign enemies_x[2] = enemy_x2;
    assign enemies_y[2] = enemy_y2;
    assign enemies_x[3] = enemy_x3;
    assign enemies_y[3] = enemy_y3;
    assign enemies_x[4] = enemy_x4;
    assign enemies_y[4] = enemy_y4;
    assign enemies_x[5] = enemy_x5;
    assign enemies_y[5] = enemy_y5;

    reg [3:0] enemies_blocked[0:NUM_ENEMIES - 1]; //Array of enemy blocked signals
    

    reg [9:0] row, col; //Row and column of current pixel in sprite
    integer i, j;
    
//Box Locations
assign box_x[0] = 10'd143;
assign box_y[0] = 10'd34;
assign box_x[1] = 10'd143;
assign box_y[1] = 10'd50;
assign box_x[2] = 10'd143;
assign box_y[2] = 10'd66;
assign box_x[3] = 10'd143;
assign box_y[3] = 10'd82;
assign box_x[4] = 10'd143;
assign box_y[4] = 10'd98;
assign box_x[5] = 10'd143;
assign box_y[5] = 10'd114;
assign box_x[6] = 10'd143;
assign box_y[6] = 10'd130;
assign box_x[7] = 10'd143;
assign box_y[7] = 10'd146;
assign box_x[8] = 10'd143;
assign box_y[8] = 10'd162;
assign box_x[9] = 10'd143;
assign box_y[9] = 10'd178;
assign box_x[10] = 10'd143;
assign box_y[10] = 10'd194;
assign box_x[11] = 10'd143;
assign box_y[11] = 10'd210;
assign box_x[12] = 10'd143;
assign box_y[12] = 10'd226;
assign box_x[13] = 10'd143;
assign box_y[13] = 10'd242;
assign box_x[14] = 10'd143;
assign box_y[14] = 10'd258;
assign box_x[15] = 10'd143;
assign box_y[15] = 10'd274;
assign box_x[16] = 10'd143;
assign box_y[16] = 10'd290;
assign box_x[17] = 10'd143;
assign box_y[17] = 10'd306;
assign box_x[18] = 10'd143;
assign box_y[18] = 10'd322;
assign box_x[19] = 10'd143;
assign box_y[19] = 10'd338;
assign box_x[20] = 10'd143;
assign box_y[20] = 10'd354;
assign box_x[21] = 10'd143;
assign box_y[21] = 10'd370;
assign box_x[22] = 10'd143;
assign box_y[22] = 10'd386;
assign box_x[23] = 10'd143;
assign box_y[23] = 10'd402;
assign box_x[24] = 10'd143;
assign box_y[24] = 10'd418;
assign box_x[25] = 10'd143;
assign box_y[25] = 10'd434;
assign box_x[26] = 10'd143;
assign box_y[26] = 10'd450;
assign box_x[27] = 10'd143;
assign box_y[27] = 10'd466;
assign box_x[28] = 10'd143;
assign box_y[28] = 10'd482;
assign box_x[29] = 10'd143;
assign box_y[29] = 10'd498;
assign box_x[30] = 10'd159;
assign box_y[30] = 10'd34;
assign box_x[31] = 10'd175;
assign box_y[31] = 10'd34;
assign box_x[32] = 10'd191;
assign box_y[32] = 10'd34;
assign box_x[33] = 10'd207;
assign box_y[33] = 10'd34;
assign box_x[34] = 10'd223;
assign box_y[34] = 10'd34;
assign box_x[35] = 10'd239;
assign box_y[35] = 10'd34;
assign box_x[36] = 10'd255;
assign box_y[36] = 10'd34;
assign box_x[37] = 10'd271;
assign box_y[37] = 10'd34;
assign box_x[38] = 10'd287;
assign box_y[38] = 10'd34;
assign box_x[39] = 10'd303;
assign box_y[39] = 10'd34;
assign box_x[40] = 10'd319;
assign box_y[40] = 10'd34;
assign box_x[41] = 10'd335;
assign box_y[41] = 10'd34;
assign box_x[42] = 10'd351;
assign box_y[42] = 10'd34;
assign box_x[43] = 10'd367;
assign box_y[43] = 10'd34;
assign box_x[44] = 10'd383;
assign box_y[44] = 10'd34;
assign box_x[45] = 10'd399;
assign box_y[45] = 10'd34;
assign box_x[46] = 10'd415;
assign box_y[46] = 10'd34;
assign box_x[47] = 10'd431;
assign box_y[47] = 10'd34;
assign box_x[48] = 10'd447;
assign box_y[48] = 10'd34;
assign box_x[49] = 10'd463;
assign box_y[49] = 10'd34;
assign box_x[50] = 10'd479;
assign box_y[50] = 10'd34;
assign box_x[51] = 10'd495;
assign box_y[51] = 10'd34;
assign box_x[52] = 10'd511;
assign box_y[52] = 10'd34;
assign box_x[53] = 10'd527;
assign box_y[53] = 10'd34;
assign box_x[54] = 10'd543;
assign box_y[54] = 10'd34;
assign box_x[55] = 10'd559;
assign box_y[55] = 10'd34;
assign box_x[56] = 10'd575;
assign box_y[56] = 10'd34;
assign box_x[57] = 10'd591;
assign box_y[57] = 10'd34;
assign box_x[58] = 10'd607;
assign box_y[58] = 10'd34;
assign box_x[59] = 10'd623;
assign box_y[59] = 10'd34;
assign box_x[60] = 10'd639;
assign box_y[60] = 10'd34;
assign box_x[61] = 10'd655;
assign box_y[61] = 10'd34;
assign box_x[62] = 10'd671;
assign box_y[62] = 10'd34;
assign box_x[63] = 10'd687;
assign box_y[63] = 10'd34;
assign box_x[64] = 10'd703;
assign box_y[64] = 10'd34;
assign box_x[65] = 10'd719;
assign box_y[65] = 10'd34;
assign box_x[66] = 10'd735;
assign box_y[66] = 10'd34;
assign box_x[67] = 10'd751;
assign box_y[67] = 10'd34;
assign box_x[68] = 10'd767;
assign box_y[68] = 10'd34;
assign box_x[69] = 10'd768;
assign box_y[69] = 10'd50;
assign box_x[70] = 10'd768;
assign box_y[70] = 10'd66;
assign box_x[71] = 10'd768;
assign box_y[71] = 10'd82;
assign box_x[72] = 10'd768;
assign box_y[72] = 10'd98;
assign box_x[73] = 10'd768;
assign box_y[73] = 10'd114;
assign box_x[74] = 10'd768;
assign box_y[74] = 10'd130;
assign box_x[75] = 10'd768;
assign box_y[75] = 10'd146;
assign box_x[76] = 10'd768;
assign box_y[76] = 10'd162;
assign box_x[77] = 10'd768;
assign box_y[77] = 10'd178;
assign box_x[78] = 10'd768;
assign box_y[78] = 10'd194;
assign box_x[79] = 10'd768;
assign box_y[79] = 10'd210;
assign box_x[80] = 10'd768;
assign box_y[80] = 10'd226;
assign box_x[81] = 10'd768;
assign box_y[81] = 10'd242;
assign box_x[82] = 10'd768;
assign box_y[82] = 10'd258;
assign box_x[83] = 10'd768;
assign box_y[83] = 10'd274;
assign box_x[84] = 10'd768;
assign box_y[84] = 10'd290;
assign box_x[85] = 10'd768;
assign box_y[85] = 10'd306;
assign box_x[86] = 10'd768;
assign box_y[86] = 10'd322;
assign box_x[87] = 10'd768;
assign box_y[87] = 10'd338;
assign box_x[88] = 10'd768;
assign box_y[88] = 10'd354;
assign box_x[89] = 10'd768;
assign box_y[89] = 10'd370;
assign box_x[90] = 10'd768;
assign box_y[90] = 10'd386;
assign box_x[91] = 10'd768;
assign box_y[91] = 10'd402;
assign box_x[92] = 10'd768;
assign box_y[92] = 10'd418;
assign box_x[93] = 10'd768;
assign box_y[93] = 10'd434;
assign box_x[94] = 10'd768;
assign box_y[94] = 10'd450;
assign box_x[95] = 10'd768;
assign box_y[95] = 10'd466;
assign box_x[96] = 10'd768;
assign box_y[96] = 10'd482;
assign box_x[97] = 10'd768;
assign box_y[97] = 10'd498;
assign box_x[98] = 10'd159;
assign box_y[98] = 10'd500;
assign box_x[99] = 10'd175;
assign box_y[99] = 10'd500;
assign box_x[100] = 10'd191;
assign box_y[100] = 10'd500;
assign box_x[101] = 10'd207;
assign box_y[101] = 10'd500;
assign box_x[102] = 10'd223;
assign box_y[102] = 10'd500;
assign box_x[103] = 10'd239;
assign box_y[103] = 10'd500;
assign box_x[104] = 10'd255;
assign box_y[104] = 10'd500;
assign box_x[105] = 10'd271;
assign box_y[105] = 10'd500;
assign box_x[106] = 10'd287;
assign box_y[106] = 10'd500;
assign box_x[107] = 10'd303;
assign box_y[107] = 10'd500;
assign box_x[108] = 10'd319;
assign box_y[108] = 10'd500;
assign box_x[109] = 10'd335;
assign box_y[109] = 10'd500;
assign box_x[110] = 10'd351;
assign box_y[110] = 10'd500;
assign box_x[111] = 10'd367;
assign box_y[111] = 10'd500;
assign box_x[112] = 10'd383;
assign box_y[112] = 10'd500;
assign box_x[113] = 10'd399;
assign box_y[113] = 10'd500;
assign box_x[114] = 10'd415;
assign box_y[114] = 10'd500;
assign box_x[115] = 10'd431;
assign box_y[115] = 10'd500;
assign box_x[116] = 10'd447;
assign box_y[116] = 10'd500;
assign box_x[117] = 10'd463;
assign box_y[117] = 10'd500;
assign box_x[118] = 10'd479;
assign box_y[118] = 10'd500;
assign box_x[119] = 10'd495;
assign box_y[119] = 10'd500;
assign box_x[120] = 10'd511;
assign box_y[120] = 10'd500;
assign box_x[121] = 10'd527;
assign box_y[121] = 10'd500;
assign box_x[122] = 10'd543;
assign box_y[122] = 10'd500;
assign box_x[123] = 10'd559;
assign box_y[123] = 10'd500;
assign box_x[124] = 10'd575;
assign box_y[124] = 10'd500;
assign box_x[125] = 10'd591;
assign box_y[125] = 10'd500;
assign box_x[126] = 10'd607;
assign box_y[126] = 10'd500;
assign box_x[127] = 10'd623;
assign box_y[127] = 10'd500;
assign box_x[128] = 10'd639;
assign box_y[128] = 10'd500;
assign box_x[129] = 10'd655;
assign box_y[129] = 10'd500;
assign box_x[130] = 10'd671;
assign box_y[130] = 10'd500;
assign box_x[131] = 10'd687;
assign box_y[131] = 10'd500;
assign box_x[132] = 10'd703;
assign box_y[132] = 10'd500;
assign box_x[133] = 10'd719;
assign box_y[133] = 10'd500;
assign box_x[134] = 10'd735;
assign box_y[134] = 10'd500;
assign box_x[135] = 10'd751;
assign box_y[135] = 10'd500;
assign box_x[136] = 10'd767;
assign box_y[136] = 10'd500;
assign box_x[137] = 10'd175;
assign box_y[137] = 10'd66;
assign box_x[138] = 10'd175;
assign box_y[138] = 10'd82;
assign box_x[139] = 10'd175;
assign box_y[139] = 10'd98;
assign box_x[140] = 10'd175;
assign box_y[140] = 10'd114;
assign box_x[141] = 10'd175;
assign box_y[141] = 10'd130;
assign box_x[142] = 10'd175;
assign box_y[142] = 10'd146;
assign box_x[143] = 10'd175;
assign box_y[143] = 10'd162;
assign box_x[144] = 10'd175;
assign box_y[144] = 10'd178;
assign box_x[145] = 10'd175;
assign box_y[145] = 10'd194;
assign box_x[146] = 10'd175;
assign box_y[146] = 10'd210;
assign box_x[147] = 10'd175;
assign box_y[147] = 10'd226;
assign box_x[148] = 10'd175;
assign box_y[148] = 10'd242;
assign box_x[149] = 10'd175;
assign box_y[149] = 10'd258;
assign box_x[150] = 10'd175;
assign box_y[150] = 10'd274;
assign box_x[151] = 10'd175;
assign box_y[151] = 10'd290;
assign box_x[152] = 10'd175;
assign box_y[152] = 10'd306;
assign box_x[153] = 10'd175;
assign box_y[153] = 10'd322;
assign box_x[154] = 10'd175;
assign box_y[154] = 10'd338;
assign box_x[155] = 10'd175;
assign box_y[155] = 10'd354;
assign box_x[156] = 10'd175;
assign box_y[156] = 10'd370;
assign box_x[157] = 10'd175;
assign box_y[157] = 10'd386;
assign box_x[158] = 10'd175;
assign box_y[158] = 10'd402;
assign box_x[159] = 10'd175;
assign box_y[159] = 10'd418;
assign box_x[160] = 10'd175;
assign box_y[160] = 10'd434;
assign box_x[161] = 10'd175;
assign box_y[161] = 10'd450;
assign box_x[162] = 10'd175;
assign box_y[162] = 10'd466;
assign box_x[163] = 10'd191;
assign box_y[163] = 10'd66;
assign box_x[164] = 10'd207;
assign box_y[164] = 10'd66;
assign box_x[165] = 10'd223;
assign box_y[165] = 10'd66;
assign box_x[166] = 10'd239;
assign box_y[166] = 10'd66;
assign box_x[167] = 10'd255;
assign box_y[167] = 10'd66;
assign box_x[168] = 10'd271;
assign box_y[168] = 10'd66;
assign box_x[169] = 10'd287;
assign box_y[169] = 10'd66;
assign box_x[170] = 10'd303;
assign box_y[170] = 10'd66;
assign box_x[171] = 10'd319;
assign box_y[171] = 10'd66;
assign box_x[172] = 10'd335;
assign box_y[172] = 10'd66;
assign box_x[173] = 10'd351;
assign box_y[173] = 10'd66;
assign box_x[174] = 10'd367;
assign box_y[174] = 10'd66;
assign box_x[175] = 10'd383;
assign box_y[175] = 10'd66;
assign box_x[176] = 10'd399;
assign box_y[176] = 10'd66;
assign box_x[177] = 10'd415;
assign box_y[177] = 10'd66;
assign box_x[178] = 10'd431;
assign box_y[178] = 10'd66;
assign box_x[179] = 10'd447;
assign box_y[179] = 10'd66;
assign box_x[180] = 10'd463;
assign box_y[180] = 10'd66;
assign box_x[181] = 10'd479;
assign box_y[181] = 10'd66;
assign box_x[182] = 10'd495;
assign box_y[182] = 10'd66;
assign box_x[183] = 10'd511;
assign box_y[183] = 10'd66;
assign box_x[184] = 10'd527;
assign box_y[184] = 10'd66;
assign box_x[185] = 10'd543;
assign box_y[185] = 10'd66;
assign box_x[186] = 10'd559;
assign box_y[186] = 10'd66;
assign box_x[187] = 10'd575;
assign box_y[187] = 10'd66;
assign box_x[188] = 10'd591;
assign box_y[188] = 10'd66;
assign box_x[189] = 10'd607;
assign box_y[189] = 10'd66;
assign box_x[190] = 10'd623;
assign box_y[190] = 10'd66;
assign box_x[191] = 10'd639;
assign box_y[191] = 10'd66;
assign box_x[192] = 10'd655;
assign box_y[192] = 10'd66;
assign box_x[193] = 10'd671;
assign box_y[193] = 10'd66;
assign box_x[194] = 10'd687;
assign box_y[194] = 10'd66;
assign box_x[195] = 10'd703;
assign box_y[195] = 10'd66;
assign box_x[196] = 10'd719;
assign box_y[196] = 10'd66;
assign box_x[197] = 10'd735;
assign box_y[197] = 10'd66;
assign box_x[198] = 10'd736;
assign box_y[198] = 10'd82;
assign box_x[199] = 10'd736;
assign box_y[199] = 10'd98;
assign box_x[200] = 10'd736;
assign box_y[200] = 10'd114;
assign box_x[201] = 10'd736;
assign box_y[201] = 10'd130;
assign box_x[202] = 10'd736;
assign box_y[202] = 10'd146;
assign box_x[203] = 10'd736;
assign box_y[203] = 10'd162;
assign box_x[204] = 10'd736;
assign box_y[204] = 10'd178;
assign box_x[205] = 10'd736;
assign box_y[205] = 10'd194;
assign box_x[206] = 10'd736;
assign box_y[206] = 10'd210;
assign box_x[207] = 10'd736;
assign box_y[207] = 10'd226;
assign box_x[208] = 10'd736;
assign box_y[208] = 10'd242;
assign box_x[209] = 10'd736;
assign box_y[209] = 10'd258;
assign box_x[210] = 10'd736;
assign box_y[210] = 10'd274;
assign box_x[211] = 10'd736;
assign box_y[211] = 10'd290;
assign box_x[212] = 10'd736;
assign box_y[212] = 10'd306;
assign box_x[213] = 10'd736;
assign box_y[213] = 10'd322;
assign box_x[214] = 10'd736;
assign box_y[214] = 10'd338;
assign box_x[215] = 10'd736;
assign box_y[215] = 10'd354;
assign box_x[216] = 10'd736;
assign box_y[216] = 10'd370;
assign box_x[217] = 10'd736;
assign box_y[217] = 10'd386;
assign box_x[218] = 10'd736;
assign box_y[218] = 10'd402;
assign box_x[219] = 10'd736;
assign box_y[219] = 10'd418;
assign box_x[220] = 10'd736;
assign box_y[220] = 10'd434;
assign box_x[221] = 10'd736;
assign box_y[221] = 10'd450;
assign box_x[222] = 10'd736;
assign box_y[222] = 10'd466;
assign box_x[223] = 10'd191;
assign box_y[223] = 10'd468;
assign box_x[224] = 10'd207;
assign box_y[224] = 10'd468;
assign box_x[225] = 10'd223;
assign box_y[225] = 10'd468;
assign box_x[226] = 10'd239;
assign box_y[226] = 10'd468;
assign box_x[227] = 10'd255;
assign box_y[227] = 10'd468;
assign box_x[228] = 10'd271;
assign box_y[228] = 10'd468;
assign box_x[229] = 10'd287;
assign box_y[229] = 10'd468;
assign box_x[230] = 10'd303;
assign box_y[230] = 10'd468;
assign box_x[231] = 10'd319;
assign box_y[231] = 10'd468;
assign box_x[232] = 10'd335;
assign box_y[232] = 10'd468;
assign box_x[233] = 10'd351;
assign box_y[233] = 10'd468;
assign box_x[234] = 10'd367;
assign box_y[234] = 10'd468;
assign box_x[235] = 10'd383;
assign box_y[235] = 10'd468;
assign box_x[236] = 10'd399;
assign box_y[236] = 10'd468;
assign box_x[237] = 10'd415;
assign box_y[237] = 10'd468;
assign box_x[238] = 10'd431;
assign box_y[238] = 10'd468;
assign box_x[239] = 10'd447;
assign box_y[239] = 10'd468;
assign box_x[240] = 10'd463;
assign box_y[240] = 10'd468;
assign box_x[241] = 10'd479;
assign box_y[241] = 10'd468;
assign box_x[242] = 10'd495;
assign box_y[242] = 10'd468;
assign box_x[243] = 10'd511;
assign box_y[243] = 10'd468;
assign box_x[244] = 10'd527;
assign box_y[244] = 10'd468;
assign box_x[245] = 10'd543;
assign box_y[245] = 10'd468;
assign box_x[246] = 10'd559;
assign box_y[246] = 10'd468;
assign box_x[247] = 10'd575;
assign box_y[247] = 10'd468;
assign box_x[248] = 10'd591;
assign box_y[248] = 10'd468;
assign box_x[249] = 10'd607;
assign box_y[249] = 10'd468;
assign box_x[250] = 10'd623;
assign box_y[250] = 10'd468;
assign box_x[251] = 10'd639;
assign box_y[251] = 10'd468;
assign box_x[252] = 10'd655;
assign box_y[252] = 10'd468;
assign box_x[253] = 10'd671;
assign box_y[253] = 10'd468;
assign box_x[254] = 10'd687;
assign box_y[254] = 10'd468;
assign box_x[255] = 10'd703;
assign box_y[255] = 10'd468;
assign box_x[256] = 10'd719;
assign box_y[256] = 10'd468;
assign box_x[257] = 10'd735;
assign box_y[257] = 10'd468;
assign box_x[258] = 10'd207;
assign box_y[258] = 10'd98;
assign box_x[259] = 10'd207;
assign box_y[259] = 10'd114;
assign box_x[260] = 10'd207;
assign box_y[260] = 10'd130;
assign box_x[261] = 10'd207;
assign box_y[261] = 10'd146;
assign box_x[262] = 10'd207;
assign box_y[262] = 10'd162;
assign box_x[263] = 10'd207;
assign box_y[263] = 10'd178;
assign box_x[264] = 10'd207;
assign box_y[264] = 10'd194;
assign box_x[265] = 10'd207;
assign box_y[265] = 10'd210;
assign box_x[266] = 10'd207;
assign box_y[266] = 10'd226;
assign box_x[267] = 10'd207;
assign box_y[267] = 10'd242;
assign box_x[268] = 10'd207;
assign box_y[268] = 10'd258;
assign box_x[269] = 10'd207;
assign box_y[269] = 10'd274;
assign box_x[270] = 10'd207;
assign box_y[270] = 10'd290;
assign box_x[271] = 10'd207;
assign box_y[271] = 10'd306;
assign box_x[272] = 10'd207;
assign box_y[272] = 10'd322;
assign box_x[273] = 10'd207;
assign box_y[273] = 10'd338;
assign box_x[274] = 10'd207;
assign box_y[274] = 10'd354;
assign box_x[275] = 10'd207;
assign box_y[275] = 10'd370;
assign box_x[276] = 10'd207;
assign box_y[276] = 10'd386;
assign box_x[277] = 10'd207;
assign box_y[277] = 10'd402;
assign box_x[278] = 10'd207;
assign box_y[278] = 10'd418;
assign box_x[279] = 10'd207;
assign box_y[279] = 10'd434;
assign box_x[280] = 10'd223;
assign box_y[280] = 10'd98;
assign box_x[281] = 10'd287;
assign box_y[281] = 10'd98;
assign box_x[282] = 10'd351;
assign box_y[282] = 10'd98;
assign box_x[283] = 10'd415;
assign box_y[283] = 10'd98;
assign box_x[284] = 10'd479;
assign box_y[284] = 10'd98;
assign box_x[285] = 10'd543;
assign box_y[285] = 10'd98;
assign box_x[286] = 10'd607;
assign box_y[286] = 10'd98;
assign box_x[287] = 10'd671;
assign box_y[287] = 10'd98;
assign box_x[288] = 10'd704;
assign box_y[288] = 10'd114;
assign box_x[289] = 10'd704;
assign box_y[289] = 10'd130;
assign box_x[290] = 10'd704;
assign box_y[290] = 10'd146;
assign box_x[291] = 10'd704;
assign box_y[291] = 10'd162;
assign box_x[292] = 10'd704;
assign box_y[292] = 10'd178;
assign box_x[293] = 10'd704;
assign box_y[293] = 10'd194;
assign box_x[294] = 10'd704;
assign box_y[294] = 10'd210;
assign box_x[295] = 10'd704;
assign box_y[295] = 10'd226;
assign box_x[296] = 10'd704;
assign box_y[296] = 10'd242;
assign box_x[297] = 10'd704;
assign box_y[297] = 10'd258;
assign box_x[298] = 10'd704;
assign box_y[298] = 10'd274;
assign box_x[299] = 10'd704;
assign box_y[299] = 10'd290;
assign box_x[300] = 10'd704;
assign box_y[300] = 10'd306;
assign box_x[301] = 10'd704;
assign box_y[301] = 10'd322;
assign box_x[302] = 10'd704;
assign box_y[302] = 10'd338;
assign box_x[303] = 10'd704;
assign box_y[303] = 10'd354;
assign box_x[304] = 10'd704;
assign box_y[304] = 10'd370;
assign box_x[305] = 10'd704;
assign box_y[305] = 10'd386;
assign box_x[306] = 10'd704;
assign box_y[306] = 10'd402;
assign box_x[307] = 10'd704;
assign box_y[307] = 10'd418;
assign box_x[308] = 10'd704;
assign box_y[308] = 10'd434;
assign box_x[309] = 10'd223;
assign box_y[309] = 10'd436;
assign box_x[310] = 10'd287;
assign box_y[310] = 10'd436;
assign box_x[311] = 10'd351;
assign box_y[311] = 10'd436;
assign box_x[312] = 10'd415;
assign box_y[312] = 10'd436;
assign box_x[313] = 10'd479;
assign box_y[313] = 10'd436;
assign box_x[314] = 10'd543;
assign box_y[314] = 10'd436;
assign box_x[315] = 10'd607;
assign box_y[315] = 10'd436;
assign box_x[316] = 10'd671;
assign box_y[316] = 10'd436;
assign box_x[317] = 10'd239;
assign box_y[317] = 10'd130;
assign box_x[318] = 10'd239;
assign box_y[318] = 10'd146;
assign box_x[319] = 10'd239;
assign box_y[319] = 10'd162;
assign box_x[320] = 10'd239;
assign box_y[320] = 10'd178;
assign box_x[321] = 10'd239;
assign box_y[321] = 10'd194;
assign box_x[322] = 10'd239;
assign box_y[322] = 10'd210;
assign box_x[323] = 10'd239;
assign box_y[323] = 10'd226;
assign box_x[324] = 10'd239;
assign box_y[324] = 10'd242;
assign box_x[325] = 10'd239;
assign box_y[325] = 10'd258;
assign box_x[326] = 10'd239;
assign box_y[326] = 10'd274;
assign box_x[327] = 10'd239;
assign box_y[327] = 10'd290;
assign box_x[328] = 10'd239;
assign box_y[328] = 10'd306;
assign box_x[329] = 10'd239;
assign box_y[329] = 10'd322;
assign box_x[330] = 10'd239;
assign box_y[330] = 10'd338;
assign box_x[331] = 10'd239;
assign box_y[331] = 10'd354;
assign box_x[332] = 10'd239;
assign box_y[332] = 10'd370;
assign box_x[333] = 10'd239;
assign box_y[333] = 10'd386;
assign box_x[334] = 10'd239;
assign box_y[334] = 10'd402;
assign box_x[335] = 10'd255;
assign box_y[335] = 10'd130;
assign box_x[336] = 10'd271;
assign box_y[336] = 10'd130;
assign box_x[337] = 10'd287;
assign box_y[337] = 10'd130;
assign box_x[338] = 10'd303;
assign box_y[338] = 10'd130;
assign box_x[339] = 10'd319;
assign box_y[339] = 10'd130;
assign box_x[340] = 10'd335;
assign box_y[340] = 10'd130;
assign box_x[341] = 10'd351;
assign box_y[341] = 10'd130;
assign box_x[342] = 10'd367;
assign box_y[342] = 10'd130;
assign box_x[343] = 10'd383;
assign box_y[343] = 10'd130;
assign box_x[344] = 10'd399;
assign box_y[344] = 10'd130;
assign box_x[345] = 10'd415;
assign box_y[345] = 10'd130;
assign box_x[346] = 10'd431;
assign box_y[346] = 10'd130;
assign box_x[347] = 10'd447;
assign box_y[347] = 10'd130;
assign box_x[348] = 10'd463;
assign box_y[348] = 10'd130;
assign box_x[349] = 10'd479;
assign box_y[349] = 10'd130;
assign box_x[350] = 10'd495;
assign box_y[350] = 10'd130;
assign box_x[351] = 10'd511;
assign box_y[351] = 10'd130;
assign box_x[352] = 10'd527;
assign box_y[352] = 10'd130;
assign box_x[353] = 10'd543;
assign box_y[353] = 10'd130;
assign box_x[354] = 10'd559;
assign box_y[354] = 10'd130;
assign box_x[355] = 10'd575;
assign box_y[355] = 10'd130;
assign box_x[356] = 10'd591;
assign box_y[356] = 10'd130;
assign box_x[357] = 10'd607;
assign box_y[357] = 10'd130;
assign box_x[358] = 10'd623;
assign box_y[358] = 10'd130;
assign box_x[359] = 10'd639;
assign box_y[359] = 10'd130;
assign box_x[360] = 10'd655;
assign box_y[360] = 10'd130;
assign box_x[361] = 10'd671;
assign box_y[361] = 10'd130;
assign box_x[362] = 10'd672;
assign box_y[362] = 10'd146;
assign box_x[363] = 10'd672;
assign box_y[363] = 10'd162;
assign box_x[364] = 10'd672;
assign box_y[364] = 10'd178;
assign box_x[365] = 10'd672;
assign box_y[365] = 10'd194;
assign box_x[366] = 10'd672;
assign box_y[366] = 10'd210;
assign box_x[367] = 10'd672;
assign box_y[367] = 10'd226;
assign box_x[368] = 10'd672;
assign box_y[368] = 10'd242;
assign box_x[369] = 10'd672;
assign box_y[369] = 10'd258;
assign box_x[370] = 10'd672;
assign box_y[370] = 10'd274;
assign box_x[371] = 10'd672;
assign box_y[371] = 10'd290;
assign box_x[372] = 10'd672;
assign box_y[372] = 10'd306;
assign box_x[373] = 10'd672;
assign box_y[373] = 10'd322;
assign box_x[374] = 10'd672;
assign box_y[374] = 10'd338;
assign box_x[375] = 10'd672;
assign box_y[375] = 10'd354;
assign box_x[376] = 10'd672;
assign box_y[376] = 10'd370;
assign box_x[377] = 10'd672;
assign box_y[377] = 10'd386;
assign box_x[378] = 10'd672;
assign box_y[378] = 10'd402;
assign box_x[379] = 10'd255;
assign box_y[379] = 10'd404;
assign box_x[380] = 10'd271;
assign box_y[380] = 10'd404;
assign box_x[381] = 10'd287;
assign box_y[381] = 10'd404;
assign box_x[382] = 10'd303;
assign box_y[382] = 10'd404;
assign box_x[383] = 10'd319;
assign box_y[383] = 10'd404;
assign box_x[384] = 10'd335;
assign box_y[384] = 10'd404;
assign box_x[385] = 10'd351;
assign box_y[385] = 10'd404;
assign box_x[386] = 10'd367;
assign box_y[386] = 10'd404;
assign box_x[387] = 10'd383;
assign box_y[387] = 10'd404;
assign box_x[388] = 10'd399;
assign box_y[388] = 10'd404;
assign box_x[389] = 10'd415;
assign box_y[389] = 10'd404;
assign box_x[390] = 10'd431;
assign box_y[390] = 10'd404;
assign box_x[391] = 10'd447;
assign box_y[391] = 10'd404;
assign box_x[392] = 10'd463;
assign box_y[392] = 10'd404;
assign box_x[393] = 10'd479;
assign box_y[393] = 10'd404;
assign box_x[394] = 10'd495;
assign box_y[394] = 10'd404;
assign box_x[395] = 10'd511;
assign box_y[395] = 10'd404;
assign box_x[396] = 10'd527;
assign box_y[396] = 10'd404;
assign box_x[397] = 10'd543;
assign box_y[397] = 10'd404;
assign box_x[398] = 10'd559;
assign box_y[398] = 10'd404;
assign box_x[399] = 10'd575;
assign box_y[399] = 10'd404;
assign box_x[400] = 10'd591;
assign box_y[400] = 10'd404;
assign box_x[401] = 10'd607;
assign box_y[401] = 10'd404;
assign box_x[402] = 10'd623;
assign box_y[402] = 10'd404;
assign box_x[403] = 10'd639;
assign box_y[403] = 10'd404;
assign box_x[404] = 10'd655;
assign box_y[404] = 10'd404;
assign box_x[405] = 10'd671;
assign box_y[405] = 10'd404;
assign box_x[406] = 10'd271;
assign box_y[406] = 10'd162;
assign box_x[407] = 10'd271;
assign box_y[407] = 10'd178;
assign box_x[408] = 10'd271;
assign box_y[408] = 10'd194;
assign box_x[409] = 10'd271;
assign box_y[409] = 10'd210;
assign box_x[410] = 10'd271;
assign box_y[410] = 10'd226;
assign box_x[411] = 10'd271;
assign box_y[411] = 10'd242;
assign box_x[412] = 10'd271;
assign box_y[412] = 10'd258;
assign box_x[413] = 10'd271;
assign box_y[413] = 10'd274;
assign box_x[414] = 10'd271;
assign box_y[414] = 10'd290;
assign box_x[415] = 10'd271;
assign box_y[415] = 10'd306;
assign box_x[416] = 10'd271;
assign box_y[416] = 10'd322;
assign box_x[417] = 10'd271;
assign box_y[417] = 10'd338;
assign box_x[418] = 10'd271;
assign box_y[418] = 10'd354;
assign box_x[419] = 10'd271;
assign box_y[419] = 10'd370;
assign box_x[420] = 10'd287;
assign box_y[420] = 10'd162;
assign box_x[421] = 10'd303;
assign box_y[421] = 10'd162;
assign box_x[422] = 10'd319;
assign box_y[422] = 10'd162;
assign box_x[423] = 10'd335;
assign box_y[423] = 10'd162;
assign box_x[424] = 10'd351;
assign box_y[424] = 10'd162;
assign box_x[425] = 10'd367;
assign box_y[425] = 10'd162;
assign box_x[426] = 10'd383;
assign box_y[426] = 10'd162;
assign box_x[427] = 10'd399;
assign box_y[427] = 10'd162;
assign box_x[428] = 10'd415;
assign box_y[428] = 10'd162;
assign box_x[429] = 10'd431;
assign box_y[429] = 10'd162;
assign box_x[430] = 10'd447;
assign box_y[430] = 10'd162;
assign box_x[431] = 10'd463;
assign box_y[431] = 10'd162;
assign box_x[432] = 10'd479;
assign box_y[432] = 10'd162;
assign box_x[433] = 10'd495;
assign box_y[433] = 10'd162;
assign box_x[434] = 10'd511;
assign box_y[434] = 10'd162;
assign box_x[435] = 10'd527;
assign box_y[435] = 10'd162;
assign box_x[436] = 10'd543;
assign box_y[436] = 10'd162;
assign box_x[437] = 10'd559;
assign box_y[437] = 10'd162;
assign box_x[438] = 10'd575;
assign box_y[438] = 10'd162;
assign box_x[439] = 10'd591;
assign box_y[439] = 10'd162;
assign box_x[440] = 10'd607;
assign box_y[440] = 10'd162;
assign box_x[441] = 10'd623;
assign box_y[441] = 10'd162;
assign box_x[442] = 10'd639;
assign box_y[442] = 10'd162;
assign box_x[443] = 10'd640;
assign box_y[443] = 10'd178;
assign box_x[444] = 10'd640;
assign box_y[444] = 10'd194;
assign box_x[445] = 10'd640;
assign box_y[445] = 10'd210;
assign box_x[446] = 10'd640;
assign box_y[446] = 10'd226;
assign box_x[447] = 10'd640;
assign box_y[447] = 10'd242;
assign box_x[448] = 10'd640;
assign box_y[448] = 10'd258;
assign box_x[449] = 10'd640;
assign box_y[449] = 10'd274;
assign box_x[450] = 10'd640;
assign box_y[450] = 10'd290;
assign box_x[451] = 10'd640;
assign box_y[451] = 10'd306;
assign box_x[452] = 10'd640;
assign box_y[452] = 10'd322;
assign box_x[453] = 10'd640;
assign box_y[453] = 10'd338;
assign box_x[454] = 10'd640;
assign box_y[454] = 10'd354;
assign box_x[455] = 10'd640;
assign box_y[455] = 10'd370;
assign box_x[456] = 10'd287;
assign box_y[456] = 10'd372;
assign box_x[457] = 10'd303;
assign box_y[457] = 10'd372;
assign box_x[458] = 10'd319;
assign box_y[458] = 10'd372;
assign box_x[459] = 10'd335;
assign box_y[459] = 10'd372;
assign box_x[460] = 10'd351;
assign box_y[460] = 10'd372;
assign box_x[461] = 10'd367;
assign box_y[461] = 10'd372;
assign box_x[462] = 10'd383;
assign box_y[462] = 10'd372;
assign box_x[463] = 10'd399;
assign box_y[463] = 10'd372;
assign box_x[464] = 10'd415;
assign box_y[464] = 10'd372;
assign box_x[465] = 10'd431;
assign box_y[465] = 10'd372;
assign box_x[466] = 10'd447;
assign box_y[466] = 10'd372;
assign box_x[467] = 10'd463;
assign box_y[467] = 10'd372;
assign box_x[468] = 10'd479;
assign box_y[468] = 10'd372;
assign box_x[469] = 10'd495;
assign box_y[469] = 10'd372;
assign box_x[470] = 10'd511;
assign box_y[470] = 10'd372;
assign box_x[471] = 10'd527;
assign box_y[471] = 10'd372;
assign box_x[472] = 10'd543;
assign box_y[472] = 10'd372;
assign box_x[473] = 10'd559;
assign box_y[473] = 10'd372;
assign box_x[474] = 10'd575;
assign box_y[474] = 10'd372;
assign box_x[475] = 10'd591;
assign box_y[475] = 10'd372;
assign box_x[476] = 10'd607;
assign box_y[476] = 10'd372;
assign box_x[477] = 10'd623;
assign box_y[477] = 10'd372;
assign box_x[478] = 10'd639;
assign box_y[478] = 10'd372;


    //... add more boxes here
  

 


    always @ (posedge clk, posedge reset)
    begin
        if (reset)
        begin
            bomberman_blocked <= 4'b0000;
            for (i = 0; i < NUM_WALLS; i = i + 1)
                boxes_exploded[i] <= 1;
            for (j = 0; j < NUM_ENEMIES; j = j + 1)
                enemies_blocked[j] <= 4'b0000;
        end
        else begin
            bomberman_blocked <= 4'b0000;
            for (j = 0; j < NUM_ENEMIES; j = j + 1)
                enemies_blocked[j] <= 4'b0000;
            
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
                    
                    //Explosion resembles a plus sign - exploded_temp_x represents the horizontal part of the plus sign
                    //exploded_temp_y represents the vertical part
                    /*
                    exploded_temp_x = ((box_x[i] >= e_x - E_WN - W_W) && (box_x[i] <= e_x + E_WP) && 
                        (((box_y[i] >= e_y) && (box_y[i] <= e_y + E_Width)) || ((box_y[i] >= e_y - E_Width) && (box_y[i] <= e_y))));
                    
                    exploded_temp_y = ((box_y[i] >= e_y - E_HN) && (box_y[i] <= e_y + E_HP - W_H) && 
                        (((box_x[i] >= e_x) && (box_x[i] <= e_x + E_Width)) || ((box_x[i] >= e_x - E_Width) && (box_x[i] <= e_x))));
                    */
                    //Invert result because we want 0 if box is exploded, 1 if it still exists
                    //Or with inverted boxes_exploded[i] so that if the box is already exploded it will not reappear

                    exploded_temp_x = ((box_x[i] + W_W >= e_x - E_WN) && (box_x[i] <= e_x + E_WP) && 
                        (((box_y[i] > e_y) && (box_y[i] < e_y + E_Width)) || ((box_y[i] + W_H < e_y + E_Width) && (box_y[i] + W_H > e_y))));
                    
                    exploded_temp_y = ((box_y[i] <= e_y + E_HN) && (box_y[i] + W_H >= box_y[i] - E_HP) && 
                        (((box_x[i] > e_x) && (box_x[i] < e_x + E_Width)) || ((box_x[i] + W_W > e_x) && (box_x[i] + W_W < e_x + E_Width))));

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

                    for (j = 0; j < NUM_ENEMIES; j = j + 1) begin
                        //Left
                        if ((enemies_x[j] >= box_x[i]) && (enemies_x[j] <= box_x[i] + W_W))
                        begin
                            if (((enemies_y[j] + ENEMY_H > box_y[i]) && (enemies_y[j] + ENEMY_H) <= box_y[i] + W_H) || ((enemies_y[j] >= box_y[i]) && (enemies_y[j] < box_y[i] + W_H)))
                                enemies_blocked[j][0] <= 1;
                        end
                        //Right
                        if ((enemies_x[j] <= box_x[i]) && (enemies_x[j] >= box_x[i] - ENEMY_W))
                        begin
                            if (((enemies_y[j] + ENEMY_H > box_y[i]) && (enemies_y[j] + ENEMY_H) <= box_y[i] + W_H) || ((enemies_y[j] >= box_y[i]) && (enemies_y[j] < box_y[i] + W_H)))
                                enemies_blocked[j][1] <= 1;
                        end
                        //Up
                        if ((enemies_y[j] >= box_y[i]) && (enemies_y[j] <= box_y[i] + W_H))
                        begin
                            if (((enemies_x[j] + ENEMY_W > box_x[i]) && (enemies_x[j] + ENEMY_W <= box_x[i] + W_W)) || ((enemies_x[j] >= box_x[i]) && (enemies_x[j] < box_x[i] + W_W)))
                                enemies_blocked[j][2] <= 1;
                        end
                        //Down
                        if ((enemies_y[j] <= box_y[i]) && (enemies_y[j] + ENEMY_H >= box_y[i]))
                        begin
                            if (((enemies_x[j] + ENEMY_W > box_x[i]) && (enemies_x[j] + ENEMY_W <= box_x[i] + W_W)) || ((enemies_x[j] >= box_x[i]) && (enemies_x[j] < box_x[i] + W_W)))
                                enemies_blocked[j][3] <= 1;
                        end
                    end
                    enemy_blocked0 = enemies_blocked[0];
                    enemy_blocked1 = enemies_blocked[1];
                    enemy_blocked2 = enemies_blocked[2];
                    enemy_blocked3 = enemies_blocked[3];
                    enemy_blocked4 = enemies_blocked[4];
                    enemy_blocked5 = enemies_blocked[5];

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