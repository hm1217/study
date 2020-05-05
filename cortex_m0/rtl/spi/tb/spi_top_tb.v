`timescale 1ns/1ps

module spi_top_tb;

reg			clk;
reg			rst_n;

reg			irq_en;
reg		 	spi_en;
reg		 	wr_txfifo;
reg		 	rd_rxfifo;
reg[7:0] 	wrdata;
reg[3:0] 	psc;
reg			cpol;
reg			cpha;
reg			firstbit;
reg			MISO;

wire		MOSI;
wire		SCK;
wire		CS_N;
wire[7:0] 	rddata;
wire		tr_flag;
wire		irq;


spi_top spi_inst
(
	.clk        ( clk      ),
	.rst_n      ( rst_n    ),
                           
	.irq_en     ( irq_en   ),
	.spi_en     ( spi_en   ),
	.wr_txfifo  ( wr_txfifo),
	.rd_rxfifo  ( rd_rxfifo),
	.wrdata     ( wrdata   ),
	.psc        ( psc      ),
	.cpol       ( cpol     ),
	.cpha       ( cpha     ),
	.firstbit   ( firstbit ),
	.MISO       ( MISO     ),
                           
	.MOSI       ( MOSI     ),
	.SCK        ( SCK      ),
	.CS_N       ( CS_N     ),
	.rddata     ( rddata   ),
	.tr_flag	( tr_flag  ),
	.irq		( irq	   )
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
	MISO=1;
	cpol=0;
	cpha=1;
	firstbit=1;
	psc=4'd4;
	spi_en=1'b1;
	irq_en=1'b1;
	wr_txfifo=1'b0;
	reset(10000);
	wrdata=8'h59;
	#1010;
	wr_txfifo=1;
	#20;
	wr_txfifo=1'b0;
	#1000;
	wrdata=8'h39;
	wr_txfifo=1;
	#20;
	wr_txfifo=1'b0;
	#40;
	wrdata=8'h93;
	wr_txfifo=1;
	#20;
	wr_txfifo=1'b0;
end

always #10 clk=~clk;

endmodule

