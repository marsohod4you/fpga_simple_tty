module conv(
	input wire [15:0] a16,
	input wire [8:0] b9,
	output wire [8:0] a9,
	output wire [15:0] b16
);

assign a9  = { |a16[15:8], a16[7:0]};

wire [7:0]char_color;
assign char_color = b9[8] ? 8'h1F : 8'h00;

assign b16 = { char_color, b9[7:0]};

endmodule
