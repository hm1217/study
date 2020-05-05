`timescale	1ns/1ns

module	top_tb;

reg		clk;
reg		rst_n;
wire[31:0]		HRDATA;

// wire[31:0]	HADDR;
// wire[31:0]	HWDATA;
// wire	HWRITE;

m0_top	m0_top_inst
(
	.CLK_10M(clk	),
	.RST_N	(rst_n	),
	.HRDATA	(HRDATA	)
	
	// .HADDR	(HADDR	),
	// .HWDATA	(HWDATA	),
	// .HWRITE	(HWRITE	)
);

initial begin
clk = 0;
rst_n = 1;
#800;
rst_n = 0;
end

always#50 clk = ~clk;

endmodule