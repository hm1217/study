module	uart2ram
(
	input wire 			clk,
	input wire 			rst_n,
	
	input wire [7:0]	rddata,
	input wire			rdflag,

	output reg			wren,
	output reg [15:0]	wraddr,
	output reg [31:0]	wrdata
);

//---------------------------------------------
reg		rdflag_r;
wire 	rdflag_p;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		rdflag_r <= 1'b0;
	else
		rdflag_r <= rdflag;
end

assign	rdflag_p = ~rdflag_r & rdflag;

//---------------------------------------------
reg[1:0]	num;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			wraddr <= 16'hffff;
			wrdata <= 32'b0;
			wren <= 1'b0;
			num <= 2'd0;
		end
	else if(rdflag_p)
		begin
			num <= num + 1'b1;
			wrdata <= ((num == 0)? 32'b0 : wrdata) | (rddata << (8*num));
		
			if(num == 2'd3)begin
				wren <= 1'b1;
				wraddr <= wraddr + 1'b1;
			end
		end
	else
		wren <= 1'b0;
end

endmodule
