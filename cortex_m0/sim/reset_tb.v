`timescale 1ns/1ns

module	reset_tb;

reg		clk;
reg		rst;
wire	rst_n;

reset	reset_inst
(
	.clk	(clk	),
	.rst	(rst	),
	.rst_n	(rst_n	)
);

initial begin
clk = 0;
rst = 0;
#1000	rst = 1;
end

always#10 clk = ~clk;

endmodule
