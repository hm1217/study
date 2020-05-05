
module AHB2RAM
(
	input wire			 HSEL,
	input wire			 HCLK,
	input wire			 HRESETn,

	input wire			 WRITE,
	input wire	[11:0]	 WRADDRIN,
	input wire	[31:0]	 WRDATAIN,
	
	input wire			 HREADY,	
	input wire  [ 1:0]   HTRANS,
	input wire			 HWRITE,
	input wire  [ 2:0]   HSIZE,	
	input wire  [31:0] 	 HADDR,	
	input wire  [31:0] 	 HWDATA,
		
	output wire 		 HREADYOUT,
	output wire [31:0] 	 HRDATA
);

wire [ 3:0] 	 wen;
// wire [ 3:0] 	 ren;
wire [31:0] 	 datain;
wire [31:0] 	 dataout;
wire [11:0] 	 addrout;


//ahb-ram interface

AHB_if	ahb_slave_if
(
	.hsel			( HSEL		 ),
	.hclk			( HCLK		 ),
	.hresetn        ( HRESETn    ),

	.write			( WRITE		 ),
	.wraddrin		( WRADDRIN	 ),
	.wrdatain		( WRDATAIN	 ),
	
	.hreadyin	    ( HREADY	 ),
	.htrans         ( HTRANS     ),
	.hwrite         ( HWRITE     ),
	.hsize          ( HSIZE      ),
	.haddr	        ( HADDR	     ),
	.hwdata         ( HWDATA     ),

	.datain         ( datain     ),

	.hreadyout    	( HREADYOUT	 ),
	.hrdata         ( HRDATA     ),

	.wen            ( wen        ),
	// .ren            ( ren        ),
	.dataout        ( dataout    ),
	.addrout        ( addrout    )
);


//ram

ram		ram0 
(
	.clock 		( HCLK		 	 ),
	.data 		( dataout[7:0] 	 ),
	.rdaddress	( addrout		 ),
	.rden 		( ~wen[0] 		 ),
	.wraddress	( addrout		 ),
	.wren 		( wen[0] 		 ),
	.q 			( datain[7:0]	 )
);                               

ram		ram1                
(                                
	.clock 		( HCLK		 	 ),
	.data 		( dataout[15:8]  ),
	.rdaddress	( addrout		 ),
	.rden 		( ~wen[1] 		 ),
	.wraddress	( addrout		 ),
	.wren 		( wen[1] 		 ),
	.q 			( datain[15:8]	 )
);                               

ram		ram2                
(	                             
	.clock 		( HCLK		 	 ),
	.data 		( dataout[23:16] ),
	.rdaddress	( addrout		 ),
	.rden 		( ~wen[2] 		 ),
	.wraddress 	( addrout		 ),
	.wren 		( wen[2] 		 ),
	.q 			( datain[23:16]	 )
);                               

ram		ram3                
(                                
	.clock 		( HCLK		 	 ),
	.data 		( dataout[31:24] ),
	.rdaddress	( addrout		 ),
	.rden 		( ~wen[3] 		 ),
	.wraddress	( addrout		 ),
	.wren 		( wen[3] 		 ),
	.q 			( datain[31:24]	 )
);

endmodule
