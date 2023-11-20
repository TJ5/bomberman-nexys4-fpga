module bomberman_rom
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
        10'b0000000000: color_data = 12'b011011001100;
        10'b0000000001: color_data = 12'b011011001100;
        10'b0000000010: color_data = 12'b011011001100;
        10'b0000000011: color_data = 12'b011011001100;
        10'b0000000100: color_data = 12'b011011001100;
        10'b0000000101: color_data = 12'b011011001100;
        10'b0000000110: color_data = 12'b011011001100;
        10'b0000000111: color_data = 12'b011011001100;
        10'b0000001000: color_data = 12'b011011001100;
        10'b0000001001: color_data = 12'b000000000000;
        10'b0000001010: color_data = 12'b000000000000;
        10'b0000001011: color_data = 12'b011011001100;
        10'b0000001100: color_data = 12'b011011001100;
        10'b0000001101: color_data = 12'b011011001100;
        10'b0000001110: color_data = 12'b011011001100;
        10'b0000001111: color_data = 12'b011011001100;
        10'b0000010000: color_data = 12'b011011001100;
		
		default: color_data = 12'b111100000000;
	endcase
endmodule