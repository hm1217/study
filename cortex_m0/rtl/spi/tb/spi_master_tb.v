`timescale 1ns/1ps

module spi_master_tb;

reg			clk;
reg			rst_n;
reg		 	tx_start;
reg[7:0] 	txdata;
reg[3:0] 	psc;
reg			cpol;
reg			cpha;
reg			firstbit;
reg			MISO;
wire		CS_N;
wire		SCK;
wire 		MOSI;
wire[7:0] 	rxdata;
wire		tr_flag;


spi_master uut(
	.clk		( clk	  ),
	.rst_n      ( rst_n   ),
                          
	.tx_start   ( tx_start),
	.txdata     ( txdata  ),
	.psc        ( psc     ),
	.cpol       ( cpol    ),
	.cpha       ( cpha    ),
	.firstbit   ( firstbit),
	.MISO       ( MISO    ),

	.CS_N       ( CS_N    ),
	.SCK        ( SCK     ),
	.MOSI       ( MOSI    ),
	
	.rxdata     ( rxdata  ),
	.tr_flag    ( tr_flag )
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
	cpha=0;
	firstbit=1;
	psc=4'd4;
	tx_start=0;
	reset(10000);
	txdata=8'h66;
	#10000;
	tx_start=1;
	#1100;
	tx_start=0;
	#1000;
	tx_start=1;
	#1100;
	tx_start=0;
end

always #10 clk=~clk;

endmodule

