`include	"../sys/config.v"

module ARM_SOC
(
	input wire			 CLK,
	input wire			 RESET,

`ifdef	UART
	input wire			 RXD,
	input wire			 ISPEN,
	output wire 	 	 TXD,
`endif
`ifdef	SPI	
	input wire			 MISO,
	output wire 	 	 CS_N,	
	output wire 	 	 SCK,	
	output wire 	 	 MOSI,	
`endif
`ifdef	LED
	output wire [7:0] 	 LED,
`endif
`ifdef	GPIO
	inout  wire [15:0]	 GPIO
`endif		
);

wire [7:0] 		DATAOUT;
wire		RX_FLAG_P;
wire		CORE_RESET;
wire		  WRITE;
wire [15:0]	  WRADDRIN;
wire [31:0]	  WRDATAIN;


wire          HCLK;            
wire          HRESETn;           

wire [31:0]   HADDR;           
wire [ 2:0]   HBURST;            
wire          HMASTLOCK;         
wire [ 3:0]   HPROT;         
wire [ 2:0]   HSIZE;             
wire [ 1:0]   HTRANS;            
wire [31:0]   HWDATA;            
wire          HWRITE;            
wire [31:0]   HRDATA;            
wire          HREADY;            
wire          HRESP;            

wire [15:0]   IRQ;                        
wire		  UART_IRQ,TIM_IRQ,SPI_IRQ;
wire [3:0]	  EXTI_IRQ;

assign		  IRQ = {9'b0,EXTI_IRQ[3],EXTI_IRQ[2],EXTI_IRQ[1],EXTI_IRQ[0],SPI_IRQ,TIM_IRQ,UART_IRQ};

`ifndef	UART
assign		  UART_IRQ = 1'b0;
`endif

`ifndef	TIMER
assign		  TIM_IRQ = 1'b0;
`endif

`ifndef	SPI
assign		  SPI_IRQ = 1'b0;
`endif


assign 		  HCLK = CLK;
assign 		  HRESETn = RESET;
assign 		  HRESP = 1'b0;


//DCD
wire  [7:0]	  HSEL;
wire  		  HSEL_MEM = HSEL[0];

`ifdef	GPIO
wire  		  HSEL_GPIO  = HSEL[1];
wire   [31:0] HRDATA_GPIO;
wire  		  HREADYOUT_GPIO;
`endif

`ifdef	UART
wire  		  HSEL_UART = HSEL[2];
wire   [31:0] HRDATA_UART;
wire  		  HREADYOUT_UART;
`endif

`ifdef	TIMER
wire  		  HSEL_TIMER = HSEL[3];
wire   [31:0] HRDATA_TIMER;
wire  		  HREADYOUT_TIMER;
`endif

`ifdef	SPI
wire  		  HSEL_SPI  = HSEL[4];
wire   [31:0] HRDATA_SPI;
wire  		  HREADYOUT_SPI;
`endif

`ifdef	LED
wire  		  HSEL_LED  = HSEL[5];
wire   [31:0] HRDATA_LED;
wire  		  HREADYOUT_LED;
`endif


//MUX      
wire   [31:0] HRDATA_MEM;
wire 		  HREADYOUT_MEM;


//CM0
CORTEXM0DS cortexm0ds
(
	.HCLK       	( HCLK  	),
	.HRESETn    	( CORE_RESET),

	.HADDR      	( HADDR  	),
	.HBURST     	( HBURST  	),
	.HMASTLOCK  	( HMASTLOCK ),
	.HPROT      	( HPROT  	),
	.HSIZE      	( HSIZE  	),
	.HTRANS     	( HTRANS  	),
	.HWDATA     	( HWDATA  	),
	.HWRITE     	( HWRITE  	),
	.HRDATA     	( HRDATA  	),
	.HREADY     	( HREADY  	),
	.HRESP      	( HRESP  	),

	.NMI        	( 1'b0  	),
	.IRQ        	( IRQ  		),
	.TXEV       	(   		),
	.RXEV       	( 1'b0  	),
	.LOCKUP     	( 		 	),
	.SYSRESETREQ	(   		),

	.SLEEPING   	(   		)
);


//AHBDCD
AHBDCD Decoder
(
	.HADDR      	( HADDR		),
	.HSEL			( HSEL		)
);	

//ISP
isp		isp
(
	.clk			( CLK	),
	.rst_n			( RESET	),
	.en				( ISPEN),
	.rxdata			( DATAOUT),
	.rx_flag_p		( RX_FLAG_P),

	.dl_flag		( CORE_RESET),
	.write			( WRITE),
	.wraddr			( WRADDRIN),
	.wrdata			( WRDATAIN)
);

//MEM
`ifdef	ROM_IP

AHB2RAM 		MEM
(
	.HSEL			( HSEL_MEM		),
	.HCLK			( HCLK			),
	.HRESETn		( HRESETn		),

	.WRITE			( WRITE		 	),
	.WRADDRIN		( WRADDRIN[11:0]	 	),
	.WRDATAIN		( WRDATAIN	 	),
	
	.HREADY			( 1'b1			),
	.HWRITE			( HWRITE		),	
	.HTRANS			( HTRANS		),
	.HSIZE			( HSIZE			),

	.HADDR			( HADDR			),
	.HWDATA			( HWDATA		),

	.HREADYOUT		( HREADYOUT_MEM	),
	.HRDATA			( HRDATA_MEM	)
);	
`else
AHB2MEM		MEM
(
	.HSEL			( HSEL_MEM		),
	.HCLK			( HCLK			),
	.HRESETn		( HRESETn		),

	.WR				( WRITE		 	),
	.WRADDR			( WRADDRIN[11:0]	 	),
	.WRDATA			( WRDATAIN	 	),
	
	.HREADY			( 1'b1			),
	.HWRITE			( HWRITE		),	
	.HTRANS			( HTRANS		),
	.HSIZE			( HSIZE			),

	.HADDR			( HADDR			),
	.HWDATA			( HWDATA		),

	.HREADYOUT		( HREADYOUT_MEM	),
	.HRDATA			( HRDATA_MEM	)
);	
`endif
	
//LED
`ifdef	LED	
	
AHB2LED led	
(	
	.HSEL			( HSEL_LED 		),
	.HCLK			( CLK	   		),
	.HRESETn		( RESET	   		),

	.HREADY			( 1'b1	   		),
	.HWRITE			( HWRITE   		),	
	.HTRANS			( HTRANS   		),
	.HSIZE			( HSIZE    		),

	.HADDR			( HRDATA   		),
	.HWDATA			( HWDATA   		),
	
	.HREADYOUT		( HREADYOUT_LED	),
	.HRDATA			( HRDATA_LED	),

	.LED			( LED			)
);
`endif

//UART
`ifdef	UART

AHB2UART uart
(
	.HSEL				( HSEL_UART	),
	.HCLK           ( CLK       ),
	.HRESETn        ( RESET     ),

	.BOOT           ( ISPEN      ),
	.RXD            ( RXD       ),

	.HREADY         ( 1'b1      ),
	.HWRITE         ( HWRITE   ),
	.HTRANS         ( HTRANS   ),
	.HSIZE          ( HSIZE    ),

	.HADDR          ( HADDR    ),
	.HWDATA         ( HWDATA   ),

	.HREADYOUT      ( HREADYOUT_UART ),
	.HRDATA         ( HRDATA_UART    ),
	
	.DATAOUT        ( DATAOUT    ),
	.RX_FLAG_P      ( RX_FLAG_P  ),

	.TXD            ( TXD       ),
	.IRQ            ( UART_IRQ  )
);
`endif

//TIMER
`ifdef	TIMER

AHB2TIMER timer
(
	.HSEL           ( HSEL_TIMER	),
	.HCLK           ( CLK       	),
	.HRESETn        ( RESET    		),

	.HREADY         ( 1'b1     		),
	.HWRITE         ( HWRITE    	),
	.HTRANS         ( HTRANS    	),
	.HSIZE          ( HSIZE     	),

	.HADDR          ( HADDR    	),
	.HWDATA         ( HWDATA    	),

	.HREADYOUT      ( HREADYOUT_TIMER  ),
	.HRDATA         ( HRDATA_TIMER     ),

	.TIM_IRQ		( TIM_IRQ	)
);
`endif

//SPI
`ifdef	SPI

AHB2SPI	spi
(
	.HSEL			( HSEL_SPI	),
	.HCLK           ( CLK     	),
	.HRESETn        ( RESET  	),

	.MISO           ( MISO     	),

	.HREADY         ( 1'b1     	),
	.HWRITE         ( HWRITE    ),
	.HTRANS         ( HTRANS    ),
	.HSIZE          ( HSIZE     ),

	.HADDR          ( HADDR    ),
	.HWDATA         ( HWDATA    ),

	.HREADYOUT      ( HREADYOUT_SPI),
	.HRDATA         ( HRDATA_SPI   ),

	.CS_N           ( CS_N     ),
	.SCK            ( SCK      ),
	.MOSI           ( MOSI     ),
	.SPI_IRQ        ( SPI_IRQ  )
);
`endif

`ifdef	GPIO
//GPIO	
AHB2GPIO gpio	
(	
	.HSEL			( HSEL_GPIO	),
	.HCLK           ( CLK     	),
	.HRESETn        ( RESET  	),

	.HREADY         ( 1'b1     	),
	.HWRITE         ( HWRITE    ),
	.HTRANS         ( HTRANS    ),
	.HSIZE          ( HSIZE     ),

	.HADDR          ( HADDR    ),
	.HWDATA         ( HWDATA    ),

	.HREADYOUT      ( HREADYOUT_GPIO),
	.HRDATA         ( HRDATA_GPIO   ),
	.GPIO			( GPIO	   ),
	.IRQ			( EXTI_IRQ )
);
`endif


//AHB MUX
AHBMUX AHBMUX
(
	.HCLK		 	( CLK		 	),
	.HRESETn	 	( RESET		 	),
	.MUX_SEL	 	( HSEL	 		), 

	.HRDATA_S0   	( HRDATA_MEM	), 
`ifdef	GPIO	
	.HRDATA_S1   	( HRDATA_GPIO	),
`else
	.HRDATA_S1   	( 				),
`endif
`ifdef	UART	
	.HRDATA_S2   	( HRDATA_UART	),
`else
	.HRDATA_S2   	( 				),	
`endif
`ifdef	TIMER	
	.HRDATA_S3   	( HRDATA_TIMER	),
`else
	.HRDATA_S3   	( 				),	
`endif
`ifdef	SPI	
	.HRDATA_S4   	( HRDATA_SPI	),
`else
	.HRDATA_S4   	( 				),	
`endif
`ifdef	LED	
	.HRDATA_S5   	( HRDATA_LED	),
`else
	.HRDATA_S5   	( 				),	
`endif
	.HRDATA_S6   	(			 	), 
	.HRDATA_S7   	(			 	), 


	.HREADYOUT_S0	( HREADYOUT_MEM	), 
`ifdef	GPIO	
	.HREADYOUT_S1   ( HREADYOUT_GPIO),
`else
	.HREADYOUT_S1   ( 1'b1			),
`endif
`ifdef	UART	
	.HREADYOUT_S2   ( HREADYOUT_UART),
`else
	.HREADYOUT_S2   ( 1'b1			),	
`endif
`ifdef	TIMER	
	.HREADYOUT_S3   ( HREADYOUT_TIMER),
`else
	.HREADYOUT_S3   ( 1'b1			),	
`endif
`ifdef	SPI	
	.HREADYOUT_S4   ( HREADYOUT_SPI	),
`else
	.HREADYOUT_S4   ( 1'b1			),
`endif
`ifdef	LED
	.HREADYOUT_S5   ( HREADYOUT_LED ),
`else
	.HREADYOUT_S5   ( 1'b1			),
`endif
	.HREADYOUT_S6	( 1'b1			),
	.HREADYOUT_S7	( 1'b1			),
	
	.HRDATA			( HRDATA	 	),
	.HREADY			( HREADY	 	)
);




endmodule
