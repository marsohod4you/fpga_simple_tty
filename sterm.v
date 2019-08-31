
//simple terminal
module sterm(
	input wire clk,
	input wire [7:0]rdata,
	input wire rdempty,
	input wire [15:0]q,
	
	output wire [15:0]wdata,
	output wire [12:0]wadr,
	output wire wr,
	output wire [12:0]radr,
	output wire ack
);

parameter SCR_STRIDE = 128;	/* number of chars in line*/
parameter SCR_WIDTH = 80;		/* number of visible chars in line */
parameter SCR_HEIGHT = 56;		/* number of screen lines */

localparam STATE_WAIT_CHAR = 0;	/* wait until char appear from FIFO */
localparam STATE_WRITE_CHAR = 1;	/* write received char into screen */
localparam STATE_SCROLL = 2;		/* scroll whole screen */

reg [1:0]state = STATE_WAIT_CHAR;

//catch received byte from fifo
reg [7:0]rbyte;
assign ack = (rdempty==0 && state==STATE_WAIT_CHAR);
always @(posedge clk)
	if(ack)
		rbyte <= rdata;

wire wr_single_byte;
assign wr_single_byte = ( state==STATE_WRITE_CHAR && rbyte!=8'h0D && rbyte!=8'h0A );

wire scrolled;
assign scrolled = (scroll_rd_adr == ((SCR_HEIGHT+1)*SCR_STRIDE) );

wire wr_scroll;
assign wr_scroll = ( state==STATE_SCROLL && ~scrolled );

reg [7:0]line_addr = 0;
always @(posedge clk)
	if( state==STATE_SCROLL )
		line_addr <= 0;
	else
	if( wr_single_byte )
	begin
		if(tab_char)
			line_addr <= ( line_addr + 5) & 8'hFC;
		else
			line_addr <= ( line_addr + 1);
	end

//in case of TAB char write SPACE char
wire tab_char;
assign tab_char = (rbyte==8'h09);

wire [7:0]rbyte_;
assign rbyte_ = tab_char ? 8'h20 : rbyte;

assign wdata = 
	wr_single_byte ? { 8'h1F, rbyte_ } : q;
	
assign wr = wr_single_byte || scroll_wr_cycle;
assign wadr = wr_scroll ? scroll_wr_adr : (line_addr+(SCR_HEIGHT-1)*SCR_STRIDE);

reg [12:0]scroll_rd_adr;
reg [12:0]scroll_wr_adr;
reg scroll_rd_cycle;
wire scroll_wr_cycle; assign scroll_wr_cycle = ~scroll_rd_cycle;
assign radr = scroll_rd_adr;

always @(posedge clk)
begin
	if(state==STATE_SCROLL)
	begin
		scroll_rd_cycle <= scroll_rd_cycle ^ 1;
		scroll_rd_adr <= scroll_rd_adr + scroll_rd_cycle;
		scroll_wr_adr <= scroll_wr_adr + scroll_wr_cycle;
	end
	else
	begin
		scroll_rd_adr <= SCR_STRIDE;
		scroll_wr_adr <= 0;
		scroll_rd_cycle <= 1;
	end
end

always @(posedge clk)
begin
	case(state)
	STATE_WAIT_CHAR:
		begin
			//wait for received byte
			if(rdempty==0)
				state <= STATE_WRITE_CHAR;
		end
	STATE_WRITE_CHAR:
		begin
			if(rbyte==8'h0D)
				state <= STATE_SCROLL; //should scroll
			else
				state <= STATE_WAIT_CHAR; //should write byte and wait next
		end
	STATE_SCROLL:
		begin
			//scroll screen
			if(scrolled)
				state <= STATE_WAIT_CHAR;
		end
	
	endcase
end

endmodule
