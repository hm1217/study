module AHB2UART
(
	input wire			 HSEL,
	input wire			 HCLK,
	input wire			 HRESETn,

	input wire			 RXD,

	input wire			 BOOT,
		
	input wire			 HREADY,
	input wire			 HWRITE,
	input wire  [ 1:0]   HTRANS,
	input wire  [ 2:0]   HSIZE,

	input wire  [31:0] 	 HADDR,
	input wire  [31:0] 	 HWDATA,

	output wire 		 HREADYOUT,
	output reg  [31:0] 	 HRDATA,

	output wire [ 7:0]	 DATAOUT,
	output reg		 	 RX_FLAG_P,
	
	output wire 		 TXD,
	output wire 		 IRQ
);

//address of uart reg
/*
	SR: 0x40000000
	DR: 0x40000004
	BRR:0x40000008
	CR: 0x4000000C
*/

reg [31:0]	USART_SR;
reg [31:0]	USART_DR;
reg [31:0]	USART_BRR;
reg [31:0]	USART_CR;

reg 		rHSEL;
reg 		rHWRITE;
reg [ 1:0] 	rHTRANS;
reg [31:0]  rHADDR;


//get ahb control or address signal 
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		rHSEL   <= 1'b0;
		rHWRITE <= 1'b0;
		rHTRANS <= 2'b00;
		rHADDR  <= 32'h0;
	end
	else if(HREADY)
	begin
		rHSEL   <= HSEL;
		rHWRITE <= HWRITE;
		rHTRANS <= HTRANS;
		rHADDR  <= HADDR;			
	end
end


//ahb write value to uart reg
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		USART_SR[31:4] <= 28'b0;
		{USART_DR[31:16],USART_DR[7:0]}  <= 24'b0;
		USART_BRR <= 32'b0;
		USART_CR  <= 32'b0;
	end
	else if(rHSEL & rHWRITE & rHTRANS[1])
	begin
		case(rHADDR[3:0])
			4'h4:USART_DR[7:0]  <= HWDATA[7:0];
			4'h8:USART_BRR <= HWDATA;
			4'hc:USART_CR  <= HWDATA;
			default:;
		endcase
	end
end

//always ready
assign HREADYOUT = 1'b1;

//read value of uart reg to ahb
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		HRDATA <= 32'b0; 
	else if(HSEL & (!HWRITE) & HTRANS[1])
	begin
		case(HADDR[3:0])
			4'h0:HRDATA <= USART_SR ;
			4'h4:HRDATA <= USART_DR ;
			4'h8:HRDATA <= USART_BRR;
			4'hc:HRDATA <= USART_CR ;
			default:;		
		endcase
	end
end


//signal about uart
reg			wr;
reg			rd;
wire 		UART_EN;
wire[3:0] 	IRQ_EN;
wire 		BAUD;
wire		WR_TX,RD_RX;
wire [7:0]	TX_DATA;
wire [7:0]	RX_DATA;
wire 		TX_FLAG;
wire 		RX_FLAG;
wire 		TXFIFO_EMPTY;
wire 		RXFIFO_EMPTY;

//write txfifo enable
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		wr <= 1'b0;
	else if(rHSEL & rHWRITE & rHTRANS[1] & (rHADDR[3:0] == 4'h4))
		wr <= 1'b1;
	else
		wr <= 1'b0;
end

assign WR_TX = wr;

//read rxfifo enable
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		rd <= 1'b0;
	else if(rHSEL & !rHWRITE & rHTRANS[1] & (rHADDR[3:0] == 4'h4))
		rd <= 1'b1;
	else if(BOOT && !RXFIFO_EMPTY)
		rd <= 1'b1;
	else
		rd <= 1'b0;
end

assign RD_RX = rd;

//write ram enable
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		RX_FLAG_P <= 1'b0;
	else
		RX_FLAG_P <= rd;
end

assign		DATAOUT = (BOOT) ? RX_DATA : 8'b0;

//uart_top
uart_top uart_tb
(
	.clk 			( HCLK    ),
	.rst_n 			( HRESETn ),
	.rxd 			( RXD 	  ),
	.uart_en 		( UART_EN ),
	.irq_en 		( IRQ_EN  ),
	.rxbaud	 		( BAUD	  ),
	.txbaud	 		( BAUD	  ),
	.wr_txfifo		( WR_TX	  ),
	.rd_rxfifo		( RD_RX	  ),
	.wrdata			( TX_DATA ),

	.txd 			( TXD 	  ),
	.tx_flag		( TX_FLAG ),
	.rddata			( RX_DATA ),	
	.rx_flag		( RX_FLAG ),
	.uart_irq		( IRQ	  ),
	.txfifo_empty	( TXFIFO_EMPTY	  ),
	.rxfifo_empty	( RXFIFO_EMPTY	  )
);


//read uart reg
assign BAUD    = (BOOT)? 1'b1:USART_CR[1];
assign UART_EN = USART_CR[0];
assign IRQ_EN  = USART_CR[7:4];
assign TX_DATA = USART_DR[7:0];

//write uart reg
always@*
begin
	USART_DR[15:8] = RX_DATA;
	USART_SR[3]    = TXFIFO_EMPTY;
	USART_SR[2]    = RXFIFO_EMPTY;
	USART_SR[1]    = TX_FLAG;
	USART_SR[0]    = RX_FLAG;
end

endmodule
