module baud
(
	input wire 	clk,
	input wire 	rst_n,
	input wire[3:0]	psc,
	input wire 	start,
	
	output reg	clk_out
);


//分频计数
reg[3:0]	cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
		cnt <= 4'b1111;
	else if(start)
	begin
		if(cnt == (psc/4-1))
			cnt <= 1'b0;
		else
			cnt <= cnt + 1'b1;
	end
	else
		cnt <= 1'b0;
end

//生成SCK
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		clk_out <= 1'b0;
	else if(start && (cnt == (psc/4-1)))
		clk_out <= ~clk_out;
	else
		clk_out <= 1'b0;
end

endmodule