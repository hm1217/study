module prescale
(
	input wire 		clk_in,
	input wire 		rst_n,
	input wire[7:0] psc,
	output reg 		clk_out
);

reg[7:0]	cnt;

//偶数分频器
always@(posedge clk_in or negedge rst_n)
begin
	if(!rst_n)
	begin
		cnt <= 8'b0;
		clk_out <= 1'b0;
	end
	else if(cnt == (psc/2-1))
	begin
		cnt <= 8'b0;
		clk_out <= ~clk_out;
	end
	else
		cnt <= cnt + 1'b1;
end


endmodule
