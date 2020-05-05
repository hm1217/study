module APB2SPI
(
	input wire			 PSEL,
	input wire			 PCLK,
	input wire			 PRESETn,
	
	input wire			 MISO,

	input wire			 PENABLE,
	input wire			 PWRITE,

	input wire  [31:0] 	 PADDR,
	input wire  [31:0] 	 PWDATA,

	output reg  [31:0] 	 PRDATA,

	output wire 		 CS_N,
	output wire 		 SCK,
	output wire 		 MOSI,
	output wire 		 SPI_IRQ
);

reg [31:0]	SPI_SR;
reg [31:0]	SPI_DR;
reg [31:0]	SPI_PSC;
reg [31:0]	SPI_CR;


//写寄存器
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		begin
			SPI_SR[31:1] <= 31'b0;
			SPI_DR[31:16]<= 16'b0;
			SPI_PSC <= 32'b0;
			SPI_CR  <= 32'b0;
		end
	else if(PSEL & PWRITE & PENABLE)
		begin
			case(PADDR[3:0])
				// 4'h0:SPI_SR[31:1] <= PWDATA;
				4'h4:SPI_DR[7:0]  <= PWDATA[7:0];
				4'h8:SPI_PSC <= PWDATA;
				4'hc:SPI_CR  <= PWDATA;
				default:;
			endcase
		end
end


//读寄存器
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		PRDATA <= 32'b0; 
	else if(PSEL & !PWRITE & !PENABLE)
		begin
			case(PADDR[3:0])
				4'h0:PRDATA <= SPI_SR ;
				4'h4:PRDATA <= SPI_DR ;
				4'h8:PRDATA <= SPI_PSC;
				4'hc:PRDATA <= SPI_CR ;
				default:;		
			endcase
		end
end

//产生读写fifo信号
reg			wr;
reg			rd;
wire 		SPI_EN;
wire 		IRQ_EN;
wire [3:0]	PSC;
wire 		CPOL;
wire 		CPHA;
wire 		FIRSTBIT;
wire		WR_TX,RD_RX;
wire [7:0]	TX_DATA;
wire [7:0]	RX_DATA;
wire 		TR_FLAG;

//写txfifo
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		wr <= 1'b0;
	else if(PSEL & PWRITE & PENABLE & (PADDR[3:0] == 4'h4))
		wr <= 1'b1;
	else
		wr <= 1'b0;
end

assign WR_TX = wr;

//读rxfifo
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		rd <= 1'b0;
	else if(PSEL & !PWRITE & !PENABLE & (PADDR[3:0] == 4'h4))
		rd <= 1'b1;
	else
		rd <= 1'b0;
end

assign RD_RX = rd;


//spi_top
spi_top uut(
	.clk		( PCLK		),
	.rst_n		( PRESETn	),
	.wrdata		( TX_DATA 	),
	.MISO		( MISO		),
	.wr_txfifo	( WR_TX		),
	.rd_rxfifo	( RD_RX		),
	.irq_en		( IRQ_EN	),
	.spi_en		( SPI_EN	),
	.psc		( PSC		),
	.cpol		( CPOL		),
	.cpha		( CPHA		),
	.firstbit	( FIRSTBIT	),

	.CS_N		( CS_N		),
	.SCK		( SCK		),
	.MOSI		( MOSI		),		
	.rddata		( RX_DATA	),
	.tr_flag	( TR_FLAG	),
	.irq		( SPI_IRQ	)
);



assign PSC       = SPI_PSC[3:0];
assign SPI_EN    = SPI_CR[0];
assign IRQ_EN    = SPI_CR[1];
assign CPOL      = SPI_CR[2];
assign CPHA      = SPI_CR[3];
assign FIRSTBIT  = SPI_CR[4];
assign TX_DATA   = SPI_DR[7:0];

always@*
begin
	SPI_DR[15:8] = RX_DATA;
	SPI_SR[0]    = TR_FLAG;
end

endmodule
