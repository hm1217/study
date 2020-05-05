module APB2UART
(
	input wire			 PSEL,
	input wire			 PCLK,
	input wire			 PRESETn,

	input wire			 RXD,
//  input wire			 BOOT,
//  input wire			 REN_FIFO,

	input wire			 PENABLE,
	input wire			 PWRITE,

	input wire  [31:0] 	 PADDR,
	input wire  [31:0] 	 PWDATA,

	output reg  [31:0] 	 PRDATA,

//  output wire [ 7:0]	 DATAOUT,
//  output reg 		 	 WRITE_E2PROM,
	output wire 		 TXD,
	output wire 		 UART_IRQ
);

//串口寄存器
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


//写串口寄存器
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		begin
			USART_SR[31:4]  <= 28'b0;
			{USART_DR[31:16],USART_DR[7:0]}  <= 24'b0;
			USART_BRR <= 32'b0;
			USART_CR  <= 32'b0;
		end
	else if(PSEL & PWRITE & PENABLE)
		begin
			case(PADDR[3:0])
	// 			4'h0:USART_SR  <= PWDATA;
				4'h4:USART_DR[7:0]  <= PWDATA[7:0];
				4'h8:USART_BRR <= PWDATA;
				4'hc:USART_CR  <= PWDATA;
				default:;
			endcase
		end
	else
		begin
			USART_SR[31:4]  <= 28'b0;
			USART_DR[31:16] <= 16'b0;
			USART_BRR <= USART_BRR;
			USART_CR  <= USART_CR;
		end
end


//读串口寄存器
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		PRDATA <= 32'b0; 
	else if(PSEL & !PWRITE & !PENABLE)
		begin
			case(PADDR[3:0])
				4'h0:PRDATA <= USART_SR ;
				4'h4:PRDATA <= USART_DR ;
				4'h8:PRDATA <= USART_BRR;
				4'hc:PRDATA <= USART_CR ;
				default:;		
			endcase
		end
end


//产生读写fifo信号
reg			WR;
reg			RD;
wire 		UART_EN;
wire [3:0] 	IRQ_EN;
wire 		BAUD;
wire		WR_TXFIFO,RD_RXFIFO;
wire [7:0]	TX_DATA;
wire [7:0]	RX_DATA;
wire 		TX_FLAG;
wire 		RX_FLAG;
wire 		TXFIFO_EMPTY;
wire 		RXFIFO_EMPTY;

//写txfifo
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		WR <= 1'b0;
	else if(PSEL & PWRITE & PENABLE & (PADDR[3:0] == 4'h4))
		WR <= 1'b1;
	else
		WR <= 1'b0;
end

assign WR_TXFIFO = WR;

//读rxfifo
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		RD <= 1'b0;
	else if(PSEL & !PWRITE & !PENABLE & (PADDR[3:0] == 4'h4))
		RD <= 1'b1;
	// else if(BOOT)
		// RD <= REN_FIFO;
	else
		RD <= 1'b0;
end

assign RD_RXFIFO = RD;

//用于导出接收到的数据，以便存入rom中
/*always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		WRITE_E2PROM <= 1'b0;
	else if(BOOT)
		WRITE_E2PROM <= RD;
	else
		WRITE_E2PROM <= 1'b0;
end
*/
// assign		DATAOUT = (BOOT) ? RX_DATA : 8'b0;

//uart_top
uart_top uart_tb
(
	.clk			( PCLK    		),
	.rst_n          ( PRESETn 		),
	.rxd            ( RXD 	  		),
	.uart_en        ( UART_EN 		),
	.irq_en         ( IRQ_EN  		),
	.rxbaud         ( BAUD	  		),
	.txbaud         ( BAUD	  		),
	.wr_txfifo      ( WR_TXFIFO	  	),
	.rd_rxfifo      ( RD_RXFIFO	  	),
	.wrdata         ( TX_DATA 		),

	.rddata         ( RX_DATA 		),
	.txd            ( TXD 	  		),
	.tx_flag        ( TX_FLAG 		),
	.rx_flag        ( RX_FLAG 		),
	.uart_irq       ( UART_IRQ	  	),
	.txfifo_empty   ( TXFIFO_EMPTY	),
	.rxfifo_empty   ( RXFIFO_EMPTY	)
);


//由寄存器获得控制信号
assign BAUD    = USART_CR[1];
assign UART_EN = USART_CR[0];
assign IRQ_EN  = USART_CR[7:4];
assign TX_DATA = USART_DR[7:0];

//写状态位
always@(*)
begin
	USART_DR[15:8] = RX_DATA;
	USART_SR[3]    = TXFIFO_EMPTY;
	USART_SR[2]    = RXFIFO_EMPTY;
	USART_SR[1]    = TX_FLAG;
	USART_SR[0]    = RX_FLAG;
end

endmodule
