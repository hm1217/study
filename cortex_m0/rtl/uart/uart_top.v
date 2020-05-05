
`include	"../sys/config.v"


module	uart_top
(
	input  wire 	  clk,
	input  wire 	  rst_n,
	input  wire 	  rxd,

	input  wire		  uart_en,
	input  wire[3:0]  irq_en,

	input  wire 	  rxbaud,
	input  wire 	  txbaud,

	input  wire 	  wr_txfifo,
	input  wire 	  rd_rxfifo,
	input  wire[7:0]  wrdata,

	output wire[7:0]  rddata,
	output wire 	  txd,
	output wire 	  tx_flag,
	output wire 	  rx_flag,
	output wire 	  uart_irq,
	output wire 	  txfifo_empty,
	output wire 	  rxfifo_empty
);


/*******************************************************/
reg 		rd_txfifo;
wire[7:0]	txdata;


//发送状态
reg		transfering;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		transfering <= 1'b0;
	else if(tx_flag)
		transfering <= 1'b0;
	else if(uart_en && !txfifo_empty)
		transfering <= 1'b1;	
end


//读发送缓冲区标志
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		rd_txfifo <= 1'b0;
	else if(uart_en && !txfifo_empty && !transfering)
		rd_txfifo <= 1'b1;
	else
		rd_txfifo <= 1'b0;
end


//tx_buf
//`ifdef	ISE_IP
//
////ise ip
//fifo	txbuf
//(
//	.clk		( clk 			),
//	.rst		( rst_n			),
//	.din		( wrdata		),
//	.wr_en		( wr_txfifo		),
//	.rd_en		( rd_txfifo		),
//	.dout		( txdata		),
//	.full		(				),
//	.empty		( txfifo_empty	)
//);
//`endif
//
//`ifdef	ALTEARA_IP
//
////atera ip
//fifo	txbuf 
//(
//	.clock 		( clk 			),
//	.data 		( wrdata 		),
//	.rdreq 		( rd_txfifo 	),
//	.wrreq 		( wr_txfifo 	),
//	.empty 		( txfifo_empty 	),
//	.full 		(  				),
//	.q 			( txdata 		)
//);
//`endif
//
//`ifdef	NO_IP

fifo	tx_buf
(
	.clk		( clk	  		),
	.rst_n      ( rst_n 	  	),
	.wr         ( wr_txfifo	  	),
	.rd         ( rd_txfifo	  	),
	.wrdata     ( wrdata  		),
	.rddata     ( txdata  		),
	.empty      ( txfifo_empty 	),
	.full       ( 	  	  		)
);
//`endif

//发送缓冲区空标志
reg		txfifo_empty1;
wire	txfifo_empty_p;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		txfifo_empty1 <= 1'b1;
	else
		txfifo_empty1 <= txfifo_empty;
end

assign txfifo_empty_p = ~txfifo_empty1 & txfifo_empty;


//开始发送标志
reg		tx_start_r;
wire	tx_start;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		tx_start_r <= 1'b0;
	else
		tx_start_r <= rd_txfifo;
end

assign tx_start = tx_start_r;

//发送完成标志
reg		tx_flag1,tx_flag2;
wire	tx_flag_p;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		tx_flag1 <= 1'b0; 
		tx_flag2 <= 1'b0; 
	end
	else begin
		tx_flag1 <= tx_flag; 
		tx_flag2 <= tx_flag1; 
	end
end

assign tx_flag_p = tx_flag1 & ~tx_flag2;

//发送波特率模块
wire 	clk_tx;

BAUDRATE tx_baudrate
(
	.clk	 ( clk	    ), 
	.rst_n	 ( rst_n	),
	.baud	 ( txbaud	),
	.start	 ( tx_start	), 
	.finish	 ( tx_flag_p 	), 
	
	.clk_int ( clk_tx   )
);  

//发送模块
UART_TX uart_tx
(
	.clk     ( clk      ),
	.rst_n   ( rst_n    ),
	.txdata  ( txdata   ),
	.tx_int  ( clk_tx   ),
	.tx_start( tx_start ),

	.txd     ( txd      ),
	.tx_flag ( tx_flag  )
 );




/*******************************************************/

wire 		clk_rx;
wire 		rx_start;
wire[7:0] 	rxdata;

//接收缓完成标志
reg		rx_flag1,rx_flag2;
wire	rx_flag_p;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		rx_flag1 <= 1'b0;
		rx_flag2 <= 1'b0;
	end
	else begin
		rx_flag1 <= rx_flag;
		rx_flag2 <= rx_flag1;
	end
end

assign rx_flag_p = rx_flag1 & ~rx_flag2;

//接收波特率模块
BAUDRATE rx_baudrate
(
	.clk	 ( clk	    ), 
	.rst_n	 ( rst_n	),
	.baud	 ( rxbaud	),	
	.start	 ( rx_start ),
	.finish	 ( rx_flag_p  ),
	
	.clk_int ( clk_rx   )
); 

//接收模块
UART_RX uart_rx
(
	.clk     ( clk      ),
	.rst_n   ( rst_n    ),
	.rxd     ( rxd      ),
	.rx_int  ( clk_rx   ),

	.rx_neg  ( rx_start ),
	.rx_flag ( rx_flag  ),
	.rxdata  ( rxdata  )
);



//rx_buf
//`ifdef	ISE_IP
//
//fifo	rxbuf
//(
//	.clk		( clk 			),
//	.rst		( rst_n			),
//	.din		( rxdata		),
//	.wr_en		( rx_flag_p		),
//	.rd_en		( rd_rxfifo		),
//	.dout		( rddata		),
//	.full		(				),
//	.empty		( rxfifo_empty	)
//);
//
//`endif
//
//`ifdef	ALTEARA_IP
//
//fifo	rx_buf 
//(
//	.clock 		( clk 			),
//	.data 		( rxdata 		),
//	.rdreq 		( rd_rxfifo 	),
//	.wrreq 		( rx_flag_p 	),
//	.empty 		( rxfifo_empty 	),
//	.full 		(  				),
//	.q 			( rddata 		)
//);
//
//`endif
//
//`ifdef	NO_IP

fifo	rx_buf
(
	.clk		( clk	  		),
	.rst_n      ( rst_n 	  	),
	.wr         ( rx_flag_p 	),
	.rd         ( rd_rxfifo	  	),
	.wrdata     ( rxdata 		),
	.rddata     ( rddata  		),
	.empty      ( rxfifo_empty 	),
	.full       ( 	  	  		)
);
//`endif

//接收缓冲区空标志
reg		rx_empty_r;
wire	rx_empty_p;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		rx_empty_r <= 1'b1;
	else
		rx_empty_r <= rxfifo_empty;
end

assign rx_empty_p = rx_empty_r & ~rxfifo_empty;


//中断
wire	tx_irq,rx_irq,txe_irq,rxne_irq;

assign 	txe_irq  = (irq_en[3]) & txfifo_empty_p;
assign 	rxne_irq = (irq_en[2]) & rx_empty_p;
assign 	tx_irq   = (irq_en[1]) & tx_flag_p;
assign 	rx_irq   = (irq_en[0]) & rx_flag_p;

assign 	uart_irq = tx_irq | rx_irq | txe_irq | rxne_irq;

endmodule
