module isp
(
	input  wire 	  	clk,
	input  wire 	  	rst_n,
	input  wire 	  	en,
	input  wire[7:0]   	rxdata,
	input  wire 	  	rx_flag_p,

	output reg			dl_flag,
	output wire			write,
	output wire	[15:0]	wraddr,
	output wire	[31:0]	wrdata
);

uart2ram	uart2ram
(
	.clk		(clk),
	.rst_n		(rst_n),

	.rddata		(rxdata),
	.rdflag		(rx_flag_p),

	.wren		(write),
	.wraddr		(wraddr),
	.wrdata		(wrdata)
);

//
reg[19:0]	cnt_20ms;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		cnt_20ms <= 20'd0;
	else if(rx_flag_p ||(cnt_20ms == 20'hf4240))
		cnt_20ms <= 20'd0;
	else
		cnt_20ms <= cnt_20ms + 1'b1;
end

reg[1:0]	state;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) begin
		state <= 2'b00;
		dl_flag <= 1'b0;
	end
	else begin
		case (state)
			2'd0: if(!rx_flag_p && en) state <= 2'd0;
				else state <= 2'd1;
			2'd1: if(cnt_20ms == 20'hf4240) state <= 2'd2;
				else state <= 2'd1;
			2'd2: dl_flag <= 1'b1;
		endcase
	end
end


endmodule
