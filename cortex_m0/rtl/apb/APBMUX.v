module APBMUX
(
	input wire 		    PCLK,
	input wire 		    PRESETn,
	input wire [15:0]   MUX_SEL, 
	
	input wire [31:0]   PRDATA_S0, 
	input wire [31:0]   PRDATA_S1, 
	input wire [31:0]   PRDATA_S2, 
	input wire [31:0]   PRDATA_S3, 
	input wire [31:0]   PRDATA_S4, 
	input wire [31:0]   PRDATA_S5, 
	input wire [31:0]   PRDATA_S6, 
	input wire [31:0]   PRDATA_S7, 
	input wire [31:0]   PRDATA_S8, 
	input wire [31:0]   PRDATA_S9, 
	input wire [31:0]   PRDATA_S10, 
	input wire [31:0]   PRDATA_S11, 
	input wire [31:0]   PRDATA_S12, 
	input wire [31:0]   PRDATA_S13, 
	input wire [31:0]   PRDATA_S14, 
	input wire [31:0]   PRDATA_S15, 
	input wire [31:0]   PRDATA_NOMAP, 	

	output reg [31:0]	PRDATA
);

reg [15:0]	rMUX_SEL;

always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		rMUX_SEL <= 15'h0;
	else
		rMUX_SEL <= MUX_SEL;
end

always@(*)
begin
	case(rMUX_SEL)
		16'h0001:PRDATA = PRDATA_S0;

		16'h0002:PRDATA = PRDATA_S1;

		16'h0004:PRDATA = PRDATA_S2;

		16'h0008:PRDATA = PRDATA_S3;

		16'h0010:PRDATA = PRDATA_S4;

		16'h0020:PRDATA = PRDATA_S5;

		16'h0040:PRDATA = PRDATA_S6;

		16'h0080:PRDATA = PRDATA_S7;

		16'h0100:PRDATA = PRDATA_S8;

		16'h0200:PRDATA = PRDATA_S9;
		
		16'h0400:PRDATA = PRDATA_S10;
		
		16'h0800:PRDATA = PRDATA_S11;
		
		16'h1000:PRDATA = PRDATA_S12;
		
		16'h2000:PRDATA = PRDATA_S13;
		
		16'h4000:PRDATA = PRDATA_S14;
		
		16'h8000:PRDATA = PRDATA_S15;

		default: PRDATA = PRDATA_NOMAP;
	endcase
end

endmodule
