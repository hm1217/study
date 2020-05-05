module AHB2SPI
(
	input wire			 HSEL,
	input wire			 HCLK,
	input wire			 HRESETn,
	
	input wire			 MISO,

	input wire			 HREADY,
	input wire			 HWRITE,
	input wire  [ 1:0]   HTRANS,
	input wire  [ 2:0]   HSIZE,

	input wire  [31:0] 	 HADDR,
	input wire  [31:0] 	 HWDATA,

	output wire 		 HREADYOUT,
	output reg  [31:0] 	 HRDATA,

	output wire 		 CS_N,
	output wire 		 SCK,
	output wire 		 MOSI,
	output wire 		 SPI_IRQ
);

reg [31:0]	SPI_SR;
reg [31:0]	SPI_DR;
reg [31:0]	SPI_PSC;
reg [31:0]	SPI_CR;


reg 		rHSEL;
reg 		rHWRITE;
reg [ 1:0] 	rHTRANS;
reg [31:0]  rHADDR;


//鍦板潃闃舵
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


//鏁版嵁闃舵
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		SPI_SR[31:1] <= 31'b0;
		SPI_DR[31:16]<= 16'b0;
		SPI_PSC <= 32'b0;
		SPI_CR  <= 32'b0;
	end
	else if(rHSEL & rHWRITE & rHTRANS[1])
	begin
		case(rHADDR[3:0])
			4'h4:SPI_DR[7:0]  <= HWDATA[7:0];
			4'h8:SPI_PSC <= HWDATA;
			4'hc:SPI_CR  <= HWDATA;
			default:;
		endcase
	end
end

//鎬绘槸鍑嗗濂
assign HREADYOUT = 1'b1;

//璇诲瘎瀛樺櫒
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		HRDATA <= 32'b0; 
	else if(HSEL & (!HWRITE) & HTRANS[1])
	begin
		case(HADDR[3:0])
			4'h0:HRDATA <= SPI_SR ;
			4'h4:HRDATA <= SPI_DR ;
			4'h8:HRDATA <= SPI_PSC;
			4'hc:HRDATA <= SPI_CR ;
			default:;		
		endcase
	end
end

//浜х敓璇诲啓fifo淇″彿
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

//鍐檛xfifo
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

//璇籸xfifo
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		rd <= 1'b0;
	else if(rHSEL & !rHWRITE & rHTRANS[1] & (rHADDR[3:0] == 4'h4))
		rd <= 1'b1;
	else
		rd <= 1'b0;
end

assign RD_RX = rd;


//spi_top
spi_top uut(
	.clk		( HCLK		),
	.rst_n		( HRESETn	),
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

always@(*)
begin
	SPI_DR[15:8] = RX_DATA;
	SPI_SR[0]    = TR_FLAG;
end

endmodule
