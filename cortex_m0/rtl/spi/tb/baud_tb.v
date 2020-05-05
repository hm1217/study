`timescale 1ns/1ps

module baud_tb;

reg 		clk;
reg 		rst_n;
reg[3:0]	psc;
reg 		start;
wire		clk_out;


baud uut
(
	.clk		( clk	  ),
	.rst_n		( rst_n	  ),
	.psc		( psc	  ),
	.start		( start	  ),
	.clk_out	( clk_out )
);


//复位
task reset;
	input[31:0] rst_time;
	begin
		rst_n=0;
		#rst_time;
		rst_n=1;
	end
endtask


initial begin
	clk=0;
	psc=4'd4;
	start=1'b0;

	reset(10000);
	#10000;
	start=1'b1;
	#200;
	start=1'b0;
end

always #10 clk=~clk;

endmodule

