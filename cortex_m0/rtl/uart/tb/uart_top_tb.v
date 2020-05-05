`timescale 1ns/1ns

module uart_top_tb;

reg  	  CLK;
reg  	  RST;
reg  	  RXD;
reg  	  UART_EN;
reg[1:0]  IRQ_EN;
reg  	  RXBAUD;
reg  	  TXBAUD;
reg 	  WR;
reg 	  RD;
reg[7:0]  WRDATA;

wire[7:0] RXDATA;
wire 	  TXD;
wire 	  TX_FLAG;
wire 	  RX_FLAG;
wire 	  UART_IRQ;
wire 	  TXFIFO_EMPTY;
wire 	  RXFIFO_EMPTY;

uart_top top
(
	.CLK 			( CLK 	  	   ),
	.RST 			( RST 	  	   ),
	.RXD 			( RXD 	  	   ),
	.UART_EN 		( UART_EN 	   ),
	.IRQ_EN 		( IRQ_EN  	   ),
	.RXBAUD	 		( RXBAUD  	   ),
	.TXBAUD	 		( TXBAUD  	   ),
	.WR_TX			( WR	  	   ),
	.RD_RX			( RD	  	   ),
	.WRDATA			( WRDATA  	   ),
			                       
	.RXDATA			( RXDATA  	   ),
	.TXD 			( TXD 	  	   ),
	.TX_FLAG		( TX_FLAG 	   ),
	.RX_FLAG		( RX_FLAG 	   ),
	.UART_IRQ		( UART_IRQ	   ),
	.TXFIFO_EMPTY	( TXFIFO_EMPTY ),
	.RXFIFO_EMPTY	( RXFIFO_EMPTY )
);


task send;
	input[7:0] txdata;
	integer i;
	begin
		RXD <= 0;
		#104160;
		for(i=0;i<8;i=i+1)
		begin
			RXD <= txdata[i];
			#104160;
		end
		RXD <= 1;
		#104160;
	end
endtask

initial begin
	CLK = 1'b0;
	RST = 1'b0;
	RXD = 1'b1;
	UART_EN = 1'b1;
	IRQ_EN = 2'b11;
	RXBAUD = 1'b0;
	TXBAUD = 1'b1;
	WR = 1'b0;
	RD = 1'b0;
	WRDATA=8'h00;
	#1000000;
	RST = 1'b1;
	#1000000;
	// WR=1'b1;
	// WRDATA=8'h13;
	// #20;
	// WRDATA=8'h24;
	// #20;
	// WR=1'b0;
	
	send(8'h69);
	#1000000;
	send(8'h96);
	#1000000;
	send(8'h13);
	#1000000;
	send(8'h24);
	#1000000;
	send(8'h57);
	#1000000;
	
	RD = 1;
	#20;
	RD = 0;
	#1000;
	RD = 1;
	#20;
	RD = 0;
	#1000;
	RD = 1;
	#20;
	RD = 0;
	#1000;
	RD = 1;
	#20;
	RD = 0;
	#1000;
	RD = 1;
	#20;
	RD = 1;
	#20;
	RD = 0;
	#1000;

end

always #10 CLK = ~CLK;

endmodule
