
module BAUDRATE
(
	input wire 	clk,
	input wire 	rst_n,
	input wire 	baud,
	input wire 	start,
	input wire 	finish,

	output reg 	clk_int
);

reg[15:0] 	COUNT;

always@(*)
begin
	case(baud)
		0:COUNT <= 16'd2604; //9600
		1:COUNT <= 16'd217;  //115200
	endcase
end


//计数值
reg[15:0] 	cnt;
reg 	 	clk_start;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		clk_start <= 1'b0;
	else if(start)
		clk_start <= 1'b1;
	else if(finish)
		clk_start <= 1'b0;
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		cnt <= 16'b0;
	else if(!clk_start || (cnt == 2*COUNT))
		cnt <= 16'b0;
	else
		cnt <= cnt + 1'b1;
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		clk_int <= 1'b0;
	else if(cnt == COUNT)
		clk_int <= 1'b1;
	else
		clk_int <= 1'b0;
end

endmodule
