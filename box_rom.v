module box_rom
	(
		input wire clk,
		input wire [4:0] row,
		input wire [4:0] col,
		output reg [11:0] color_data
	);

	(* rom_style = "block" *)

	//signal declarations
	reg [4:0] row_reg;
	reg [4:0] col_reg;

	always @(posedge clk)
		begin
		row_reg <= row;
		col_reg <= col;
		end

always @*
    case ({row_reg, col_reg})
        
		//1100100001102
		default: color_data = 12'b110010000110; //Just make them red blocks for now
	endcase
endmodule