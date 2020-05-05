`timescale 1ns/1ns

module fifo_tb;

reg			clk;
reg			rst_n;
reg			wr;
reg			rd;
reg[7:0]	wrdata;
wire[7:0]	rddata;
wire		empty;
wire		full;

fifo	fifo_inst
(
	.clk		( clk	 ),
	.rst_n      ( rst_n	 ),
	.wr         ( wr	 ),
	.rd         ( rd	 ),
	.wrdata     ( wrdata ),
	.rddata     ( rddata ),
	.empty      ( empty	 ),
	.full       ( full	 )
);


task send;
integer i;
begin
	for(i=0;i<32;i=i+1)
	begin
		@(negedge clk);
		wrdata <= wrdata + 1'b1;
	end
end
endtask


initial begin
	clk = 0;
	rst_n=0;
	wr=0;
	rd=0;
	wrdata=8'h00;
	#100000;
	rst_n=1;
	#100000;
	wr=1;
	send();
	wr=0;
	rd=1;
	#100;
	rd=0;
	wr=1;
	send();
	wr=0;
end

always#10 clk = ~clk;

endmodule
