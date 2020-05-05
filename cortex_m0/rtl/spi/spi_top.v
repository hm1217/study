
`include	"../sys/config.v"

module spi_top
(
	input wire			clk,
	input wire			rst_n,
	
	input wire			irq_en,
	input wire		 	spi_en,
	input wire		 	wr_txfifo,
	input wire		 	rd_rxfifo,
	input wire[7:0] 	wrdata,
	input wire[3:0] 	psc,
	input wire			cpol,
	input wire			cpha,
	input wire			firstbit,
	input wire			MISO,
	
	output wire 		MOSI,
	output wire			SCK,
	output wire			CS_N,
	output wire[7:0] 	rddata,
	output wire			tr_flag,
	output wire			irq
);

wire[7:0]		txdata;
wire[7:0]		rxdata;
reg				rd_txfifo;
wire			tr_flag_p;
wire			txfifo_empty;

//spi鍙戦€佺紦鍐插尯
`ifdef	ISE_IP

fifo	txbuf
(
	.clk		( clk 			),
	.rst		( rst_n			),
	.din		( wrdata		),
	.wr_en		( wr_txfifo		),
	.rd_en		( rd_txfifo		),
	.dout		( txdata		),
	.full		(				),
	.empty		( txfifo_empty	)
);
`endif

`ifdef	ALTEARA_IP

fifo	tx_buf 
(
	.clock 		( clk 		),
	.data 		( wrdata 	),
	.rdreq 		( rd_txfifo ),
	.wrreq 		( wr_txfifo ),
	.empty 		( txfifo_empty 	),
	.full 		(  			),
	.q 			( txdata 	)
);
`endif

`ifdef 	NO_IP
spi_fifo	spi_tx_fifo
(
	.clk		( clk	 	),
	.rst_n      ( rst_n	 	),
	.wr         ( wr_txfifo	),
	.rd         ( rd_txfifo	),
	.wrdata     ( wrdata 	),
	.rddata     ( txdata 	),
	.empty      ( txfifo_empty	 	),
	.full       ( 		 	)
);
`endif

//鍙戦€佺姸鎬
reg 		transfering;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		transfering <= 1'b0;
	else if(tr_flag_p)
		transfering <= 1'b0;
	else if(spi_en & !txfifo_empty)
		transfering <= 1'b1;
end

reg 		tx_start;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		tx_start <= 1'b0;
	else if(tr_flag_p)
		tx_start <= 1'b0;
	else
		tx_start <= transfering;
end



//鑾峰緱璇诲彂閫佺紦瀛樺尯浣胯兘
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rd_txfifo <= 1'b0;
	else if(spi_en & !txfifo_empty & !transfering)
		rd_txfifo <= 1'b1;
	else
		rd_txfifo <= 1'b0;
end


//spi
spi_master spi_master
(
		.clk            ( clk       ),
		.rst_n          ( rst_n     ),

		.txdata         ( txdata    ),
		.tx_start       ( tx_start  ),
		.psc            ( psc       ),
		.cpol           ( cpol      ),
		.cpha           ( cpha      ),
		.firstbit       ( firstbit  ),
		.MISO           ( MISO      ),

		.MOSI           ( MOSI      ),
		.SCK            ( SCK       ),
		.CS_N           ( CS_N      ),
		.rxdata         ( rxdata    ),
		.tr_flag		( tr_flag	)
);

//鑾峰緱鍙戦€佸畬鎴愭爣蹇椾綅
reg 	tr_flag_r0;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tr_flag_r0 <= 1'b0;
    else
		tr_flag_r0 <= tr_flag;
end

assign tr_flag_p = tr_flag & ~tr_flag_r0;  


//rx_fifo
`ifdef	ISE_IP

fifo	rxbuf
(
	.clk		( clk 			),
	.rst		( rst_n			),
	.din		( rxdata		),
	.wr_en		( tr_flag_p		),
	.rd_en		( rd_rxfifo		),
	.dout		( rddata		),
	.full		(				),
	.empty		( 				)
);
`endif

`ifdef	ALTEARA_IP

fifo	rx_buf 
(
	.clock 		( clk 		),
	.data 		( rxdata 	),
	.rdreq 		( rd_rxfifo ),
	.wrreq 		( tr_flag_p ),
	.empty 		(  			),
	.full 		(  			),
	.q 			( rddata 	)
);
`endif

`ifdef 	NO_IP
spi_fifo	spi_rx_fifo
(
	.clk		( clk	 	),
	.rst_n      ( rst_n	 	),
	.wr         ( tr_flag_p	),
	.rd         ( rd_rxfifo	),
	.wrdata     ( rxdata 	),
	.rddata     ( rddata 	),
	.empty      ( 		 	),
	.full       ( 		 	)
);
`endif

//涓柇璇锋眰
assign irq = irq_en & tr_flag_p; 

endmodule
