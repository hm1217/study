
`include	"../sys/config.v"


module ARMSOC_TOP
(
	input wire			 CLK,
	input wire			 RESET

`ifdef	ISP
	,
	output wire			 SCL,
	inout wire			 SDA
`endif

`ifdef	ROM_IP
	,
	input wire			 WRITE,
	input wire [15:0]	 WRADDRIN,
	input wire [31:0]	 WRDATAIN
`endif

`ifdef	UART
	,	
// input wire			 BOOT,
	input wire			 RXD,
	output wire 	 	 TXD
`endif

`ifdef	SPI
	,
	input wire			 MISO,	
	output wire 	 	 CS_N,	
	output wire 	 	 SCK,	
	output wire 	 	 MOSI	
`endif

`ifdef	LED
	,
	output wire [7:0] 	 LED
`endif

`ifdef	GPIO
	,
	inout  wire [15:0]	 GPIO
`endif
);

// Code (instruction & literal) bus
wire    [1:0] HTRANSI;            // ICode-bus transfer type
wire    [2:0] HSIZEI;             // ICode-bus transfer size
wire   [31:0] HADDRI;             // ICode-bus address

wire    [1:0] HTRANSD;            // DCode-bus transfer type
wire    [2:0] HSIZED;             // DCode-bus transfer size
wire   [31:0] HADDRD;             // DCode-bus address
wire          HWRITED;            // DCode-bus write not read
wire   [31:0] HWDATAD;            // DCode-bus write data

// System Bus
wire   [31:0] HRDATAS;            // System-bus read data
wire          HREADYS;            // System-bus ready
wire    [1:0] HTRANSS;            // System-bus transfer type
wire          HWRITES;            // System-bus write not read
wire    [2:0] HSIZES;             // System-bus transfer size
wire   [31:0] HADDRS;             // System-bus address
wire   [31:0] HWDATAS;            // System-bus write data

//Interrupt
wire  [239:0] INTISR;
wire		  UART_IRQ;
wire		  TIM_IRQ;
wire		  SPI_IRQ;

assign		  INTISR = {237'b0,SPI_IRQ,TIM_IRQ,UART_IRQ};

`ifndef	SPI
assign		  SPI_IRQ = 1'b0;
`endif

`ifndef	TIMER
assign		  TIM_IRQ = 1'b0;
`endif

`ifndef	UART
assign		  UART_IRQ = 1'b0;
`endif


//Decoder
wire	[7:0] HSEL;
wire  		  HSEL_RAM = HSEL[0];

`ifdef	AHB2APB
//APB
wire  		  HSEL_APB = HSEL[1];

//SEL
wire   [15:0] PSEL;
wire   		  PCLK;
wire   		  PRESETn;
wire   [31:0] PADDR;
wire   		  PWRITE;
wire   		  PENABLE;
wire   [31:0] PWDATA;
wire   [31:0] PRDATA;
wire   [31:0] HRDATA_APB;
wire  		  HREADYOUT_APB;
`endif

`ifdef	UART
wire  		  PSEL_UART = PSEL[0];
wire   [31:0] PRDATA_UART;
// wire		  WRITE_E2PROM;
// wire	[7:0] WDATA_E2PROM;
`endif

`ifdef	TIMER
wire  		  PSEL_TIMER = PSEL[1];
wire   [31:0] PRDATA_TIMER;
`endif

`ifdef	SPI
wire  		  PSEL_SPI = PSEL[2];
wire   [31:0] PRDATA_SPI;
`endif

`ifdef	LED
wire  		  PSEL_LED = PSEL[3];
wire   [31:0] PRDATA_LED;
`endif

`ifdef	GPIO
wire  		  PSEL_GPIO = PSEL[4];
wire   [31:0] PRDATA_GPIO;
`endif

`ifdef	ISP
wire		  WRITEROM;
wire   [15:0] WRADDRIN;
wire   [31:0] WRDATAIN;
`endif
 

//AHBMUX
wire   [31:0] HRDATAI_ROM;
wire   [31:0] HRDATAD_ROM;

wire  		  HREADYOUTI_ROM;
wire  		  HREADYOUTD_ROM;

wire   [31:0] HRDATA_RAM;
wire  		  HREADYOUT_RAM;


//reset_module
// wire		RST;

// RESET	reset_module
// (
	// .clk			( CLK	  ),
	// .rst_n			( RESET	  ),
	// .rst			( RST	  )
// );


//CM3-CORE
CORTEXM3INTEGRATIONDS CORTEX_M3
(
//input
	.ISOLATEn       ( 1'b1	  ),
	.RETAINn        ( 1'b1	  ),
	// Miscellaneous          
	.PORESETn       ( RESET	  ),
	.SYSRESETn      ( 1'b1	  ),
	.RSTBYPASS      ( 1'b1	  ),
	.CGBYPASS       ( 1'b0	  ),
	.FCLK           ( CLK	  ),
	.HCLK           ( CLK	  ),
	.TRACECLKIN     ( 1'b0	  ),
	.STCLK          ( 1'b0	  ),
	.STCALIB        ( 26'h0	  ),
	.AUXFAULT       ( 32'b0	  ),
	.BIGEND         ( 1'b0	  ),
                              
	// Debug                  
	.nTRST          ( 1'b1	  ),
	.SWCLKTCK       ( 1'b0	  ),
	.SWDITMS        ( 1'b0	  ),
	.TDI            ( 1'b0	  ),
	.CDBGPWRUPACK   ( 1'b0	  ),
                              
	.INTISR         ( INTISR  ),
	.INTNMI         ( 1'b0	  ),
	.HREADYI        ( HREADYOUTI_ROM	),
	.HRDATAI        ( HRDATAI_ROM		),
	.HRESPI         ( 2'b0	  ),
	.IFLUSH         ( 1'b0	  ),
	.HREADYD        ( HREADYOUTD_ROM 	),
	.HRDATAD        ( HRDATAD_ROM 	),
	.HRESPD         ( 2'b0	  ),
	.EXRESPD        ( 1'b0	  ),
	.HREADYS        ( HREADYS ),
	.HRDATAS        ( HRDATAS ),
	.HRESPS         ( 2'b0	  ),
	.EXRESPS        ( 1'b0	  ),
	
	.RXEV           ( 1'b0	  ),
	.SLEEPHOLDREQn  ( 1'b0	  ),
	.EDBGRQ         ( 1'b0	  ),
	.DBGRESTART     ( 1'b0	  ),
	.FIXMASTERTYPE  ( 1'b0	  ),
	.WICENREQ       ( 1'b0	  ),
	.TSVALUEB       ( 48'b0	  ),
	.SE             ( 1'b0	  ),
                              
	.DBGEN          ( 1'b0	  ),
	.NIDEN          ( 1'b0	  ),
	.MPUDISABLE     ( 1'b1	  ),
	.DNOTITRANS     ( 1'b0	  ),
	
//output
	.TDO  			(		  ),    
	.nTDOEN         (		  ),
	.CDBGPWRUPREQ   (		  ),
	.SWDO           (		  ),
	.SWDOEN         (		  ),
	.JTAGNSW        (		  ),
	.SWV            (		  ),
	.TRACECLK       (		  ),
	.TRACEDATA      (		  ),
	.HTMDHADDR      (		  ),
	.HTMDHTRANS     (		  ),
	.HTMDHSIZE      (		  ),
	.HTMDHBURST     (		  ),
	.HTMDHPROT      (		  ),
	.HTMDHWDATA     (		  ),
	.HTMDHWRITE     (		  ),
	.HTMDHRDATA     (		  ),
	.HTMDHREADY     (		  ),
	.HTMDHRESP      (		  ),
	.BRCHSTAT       (		  ),
	.HALTED       	(		  ),
	.DBGRESTARTED 	(		  ),
	.LOCKUP       	(		  ),
	.SLEEPING     	(		  ),
	.SLEEPDEEP    	(		  ),
	.SLEEPHOLDACKn	(		  ),
	.ETMINTNUM    	(		  ),
	.ETMINTSTAT   	(		  ),
	.TRCENA       	(		  ),
	.CURRPRI      	(		  ),
	.SYSRESETREQ  	(		  ),
	.TXEV         	(		  ),
	.GATEHCLK     	(		  ),
	.WICENACK     	(		  ),
	.WAKEUP       	(		  ),		

	.HADDRI         ( HADDRI  ),
	.HTRANSI        ( HTRANSI ),
	.HSIZEI         ( HSIZEI  ),
	.HBURSTI        ( 		  ),
	.HPROTI         ( 		  ),
	.MEMATTRI       ( 		  ),
	.HADDRD         ( HADDRD  ),
	.HTRANSD        ( HTRANSD ),
	.HSIZED         ( HSIZED  ),
	.HWRITED        ( HWRITED ),
	.HBURSTD        ( 		  ),
	.HPROTD         ( 		  ),
	.MEMATTRD       ( 		  ),
	.HMASTERD       ( 		  ),
	.HWDATAD        ( HWDATAD ),
	.EXREQD         ( 		  ),
	.HADDRS         ( HADDRS  ),
	.HTRANSS        ( HTRANSS ),
	.HSIZES         ( HSIZES  ),
	.HWRITES        ( HWRITES ),
	.HBURSTS        ( 		  ),
	.HPROTS         ( 		  ),
	.HMASTLOCKS     ( 		  ),
	.MEMATTRS       ( 		  ),
	.HMASTERS       ( 		  ),
	.HWDATAS        ( HWDATAS ),
	.EXREQS         ( 		  )  	
);

`ifdef	ISP

ISP	isp_inst
(
	.clk			( CLK	  ),			
	.rst_n          ( RESET	  ),

	.wr_e2prom      ( WRITE_E2PROM	),
	.wrdata_e2prom  ( WDATA_E2PROM	),
	.rd_e2prom		( ~RST	  ),

	.wr_rom         ( WRITEROM),
	.wraddr_rom     ( WRADDRIN),
	.wrdata_rom     ( WRDATAIN),
	.scl            ( SCL	  ),
	.sda            ( SDA	  )
);

`endif

`ifdef	ROM_IP
//CODE_MEM
AHB2ROM ROM
(
	.HSEL			( 1'b1	  ),
	.HCLK			( CLK	  ),
	.HRESETn		( RESET	  ),

	.WRITE			( WRITE	  ),
	.WRADDRIN		( WRADDRIN),
	.WRDATAIN		( WRDATAIN),

	.HREADYI		( 1'b1	  ),
	.HTRANSI		( HTRANSI ),
	.HSIZEI			( HSIZEI  ),	
	.HADDRI			( HADDRI  ),

	.HREADYD		( 1'b1	  ),	
	.HTRANSD		( HTRANSD ),
	.HWRITED		( HWRITED ),
	.HSIZED			( HSIZED  ),
	.HADDRD			( HADDRD  ),

	.HWDATAD		( HWDATAD ),
	
	.HREADYOUTI		( HREADYOUTI_ROM 	),	
	.HRDATAI		( HRDATAI_ROM		), 	
	.HREADYOUTD		( HREADYOUTD_ROM 	),	
	.HRDATAD		( HRDATAD_ROM		) 					
);

`else
//CODE_MEM
AHB2FLASH ROM
(
	.HCLK			( CLK	  ),
	.HRESETn		( RESET	  ),

	.HREADYI		( 1'b1	  ),
	.HADDRI			( HADDRI  ),

	.HREADYD		( 1'b1	  ),	
	.HTRANSD		( HTRANSD ),
	.HWRITED		( HWRITED ),
	.HSIZED			( HSIZED  ),

	.HADDRD			( HADDRD  ),
	.HWDATAD		( HWDATAD ),
	
	.HREADYOUTI		( HREADYOUTI_FLASH 	),	
	.HRDATAI		( HRDATAI_FLASH		), 	
	.HREADYOUTD		( HREADYOUTD_FLASH 	),	
	.HRDATAD		( HRDATAD_FLASH		) 					
);

`endif


//AHB_Decoder
AHBDCD Decoder
(
	.HADDR      	( HADDRS	),
	.HSEL			( HSEL		)
);	

//SRAM
AHB2RAM	RAM
(
	.HSEL			( HSEL_RAM	),
	.HCLK			( CLK		),
	.HRESETn		( RESET		),

	.HREADY			( 1'b1		),
	.HWRITE			( HWRITES	),	
	.HTRANS			( HTRANSS	),
	.HSIZE			( HSIZES	),

	.HADDR			( HADDRS	),
	.HWDATA			( HWDATAS	),

	.HREADYOUT		( HREADYOUT_RAM ),
	.HRDATA			( HRDATA_RAM	 )
);



`ifdef	AHB2APB

//AHB-APB
AHB2APB	Bridge
(
	.HSEL			( HSEL_APB ),
	.HCLK           ( CLK      ),
	.HRESETn        ( RESET    ),
	.HREADY         ( 1'b1	   ),
	.HWRITE         ( HWRITES  ),
	.HTRANS         ( HTRANSS  ),
	.HSIZE          ( HSIZES   ),
	.HADDR          ( HADDRS   ),
	.HWDATA         ( HWDATAS  ),

	.PRDATA	        ( PRDATA   ),

	.HREADYOUT      ( HREADYOUT_APB  ),
	.HRDATA         ( HRDATA_APB     ),

	.PSEL           ( PSEL     ),
	.PCLK           ( PCLK     ),
	.PRESETn	    ( PRESETn  ),
	.PADDR          ( PADDR    ),
	.PWRITE         ( PWRITE   ),
	.PWDATA         ( PWDATA   ),
	.PENABLE        ( PENABLE  )
);
`endif


`ifdef	UART
//UART
APB2UART uart
(
	.PSEL			( PSEL_UART	),
	.PCLK           ( PCLK      ),
	.PRESETn        ( PRESETn   ),

//  .BOOT			( BOOT		),
//  .REN_FIFO		( REN_FIFO	),
	.RXD            ( RXD       ),
	.PENABLE        ( PENABLE   ),
	.PWRITE         ( PWRITE    ),
	.PADDR          ( PADDR     ),
	.PWDATA         ( PWDATA    ),

	.PRDATA         ( PRDATA_UART ),
//	.WRITE_E2PROM	( WRITE_E2PROM),
//  .DATAOUT		( WDATA_E2PROM),
	.TXD            ( TXD       ),
	.UART_IRQ       ( UART_IRQ  )
);
`endif

`ifdef	TIMER
//TIMER
APB2TIMER timer
(
	.PSEL           ( PSEL_TIMER),
	.PCLK           ( PCLK      ),
	.PRESETn        ( PRESETn   ),

	.PENABLE        ( PENABLE   ),
	.PWRITE         ( PWRITE    ),
	.PADDR          ( PADDR     ),
	.PWDATA         ( PWDATA    ),

	.PRDATA         ( PRDATA_TIMER ),
	.TIM_IRQ		( TIM_IRQ	)
);
`endif

`ifdef	SPI
//SPI
APB2SPI	spi
(
	.PSEL			( PSEL_SPI ),
	.PCLK           ( PCLK     ),
	.PRESETn        ( PRESETn  ),

	.MISO           ( MISO     ),

	.PENABLE        ( PENABLE  ),
	.PWRITE         ( PWRITE   ),
	.PADDR          ( PADDR    ),
	.PWDATA         ( PWDATA   ),

	.PRDATA         ( PRDATA_SPI),
	.CS_N           ( CS_N     ),
	.SCK            ( SCK      ),
	.MOSI           ( MOSI     ),
	.SPI_IRQ        ( SPI_IRQ  )
);
`endif

`ifdef	LED
//LED	
APB2LED led	
(	
	.PSEL			( PSEL_LED ),
	.PCLK			( PCLK	   ),
	.PRESETn		( PRESETn  ),
	
	.PENABLE        ( PENABLE  ),
	.PWRITE			( PWRITE   ),
	.PADDR			( PADDR    ),
	.PWDATA			( PWDATA   ),

	.PRDATA			( PRDATA_LED),
	.LED			( LED	   )
);

`endif



`ifdef	GPIO
//GPIO	
APB2GPIO gpio	
(	
	.PSEL			( PSEL_GPIO),
	.PCLK			( PCLK	   ),
	.PRESETn		( PRESETn  ),
	
	.PENABLE        ( PENABLE  ),
	.PWRITE			( PWRITE   ),
	.PADDR			( PADDR    ),
	.PWDATA			( PWDATA   ),

	.PRDATA			( PRDATA_GPIO),
	.GPIO			( GPIO	   )
);
`endif

`ifdef	AHB2APB

//APB RESPONSE MUX
APBMUX APBMUX
(
	.PCLK		 	( PCLK		 	),
	.PRESETn	 	( PRESETn		),
	.MUX_SEL	 	( PSEL		 	), 

`ifdef	UART
	.PRDATA_S0   	( PRDATA_UART	),
`else
	.PRDATA_S0   	( 				),
`endif
`ifdef	TIMER	
	.PRDATA_S1   	( PRDATA_TIMER	), 
`else
	.PRDATA_S1   	( 				),
`endif
`ifdef	SPI
	.PRDATA_S2   	( PRDATA_SPI	), 
`else
	.PRDATA_S2   	( 				),
`endif
`ifdef	LED
	.PRDATA_S3   	( PRDATA_LED	), 
`else
	.PRDATA_S3   	( 				),
`endif
`ifdef	GPIO
	.PRDATA_S4   	( PRDATA_GPIO	),
`else
	.PRDATA_S4   	( 				),	
`endif
	
	.PRDATA_S5   	( 				), 
	.PRDATA_S6   	(			 	), 
	.PRDATA_S7   	(			 	), 
	.PRDATA_S8   	( 				), 
	.PRDATA_S9   	( 				), 
	.PRDATA_S10   	( 				), 
	.PRDATA_S11   	( 				), 
	.PRDATA_S12   	( 				), 
	.PRDATA_S13   	( 				), 
	.PRDATA_S14   	( 				), 
	.PRDATA_S15   	( 				), 
	.PRDATA_NOMAP	( 32'hDEADBEEF	), 		

	.PRDATA			( PRDATA	 	)
);
`endif

//AHB RESPONSE MUX
AHBMUX AHBMUX
(
	.HCLK		 	( CLK		 	),
	.HRESETn	 	( RESET		 	),
	.MUX_SEL	 	( HSEL		 	), 

	.HRDATA_S0   	( HRDATA_RAM	),

`ifdef	AHB2APB	
	.HRDATA_S1   	( HRDATA_APB	),
`else
	.HRDATA_S1   	( 				),
`endif	
	.HRDATA_S2   	( 				), 
	.HRDATA_S3   	(				), 
	.HRDATA_S4   	( 			 	), 
	.HRDATA_S5   	(			 	), 
	.HRDATA_S6   	(			 	), 
	.HRDATA_S7   	(			 	), 
		
	.HREADYOUT_S0	( HREADYOUT_RAM),
`ifdef	AHB2APB	
	.HREADYOUT_S1	( HREADYOUT_APB ), 
`else
	.HREADYOUT_S1	( 1'b1			), 
`endif
	.HREADYOUT_S2	( 1'b1		    ), 
	.HREADYOUT_S3	( 1'b1			), 
	.HREADYOUT_S4	( 1'b1			), 
	.HREADYOUT_S5	( 1'b1			), 
	.HREADYOUT_S6	( 1'b1			), 
	.HREADYOUT_S7	( 1'b1			), 	

	.HRDATA			( HRDATAS	 	),
	.HREADY			( HREADYS	 	)
);

endmodule
