`timescale	1ns/1ns

module pll_tb;

reg		clk_in;
reg		rst;
wire	clk_out;

pll	pll_inst
(
	.areset ( rst 		),
	.inclk0 ( clk_in 	),
	.c0 	( clk_out 	)
);

initial begin
	clk = 0;
	rst = 0;
	#100 rst = 1;
end

endmodule
