`timescale 1ns/1ns

module timer_tb;

reg 			CLK;
reg 			rst_n;

reg [ 1:0]		mode;
reg [ 3:0]		psc;
reg [15:0] 		load;
reg 			start;
reg 			irq_en;

wire[15:0] 		tim_cnt;
wire 		 	tim_irq;


timer top
(
	.CLK       ( CLK     ),
	.rst_n     ( rst_n   ),
                         
	.start     ( start   ),
	.irq_en    ( irq_en  ),
	.mode      ( mode    ),
	.psc       ( psc     ),
	.load      ( load    ),
                         
	.tim_cnt   ( tim_cnt ),
	.tim_irq   ( tim_irq )
);


initial begin
	CLK = 1'b0;
	rst_n = 1'b0;
	mode = 2'b00;
	load = 16'd0;
	psc = 4'd0;
	start = 1'b0;
	
	#1000000;
	rst_n = 1'b1;
	#1000000;
	mode = 2'b01;
	load = 16'd10000;
	psc = 4'd2;
	#1000000;
	start = 1'b1;
	#3000000;
	start = 1'b0;
	
end

always #10 CLK = ~CLK;

endmodule
