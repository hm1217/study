module APB2LED
(
	input wire			 PSEL,
	input wire			 PCLK,
	input wire			 PRESETn,

	input wire			 PENABLE,
	input wire			 PWRITE,	

	input wire  [31:0] 	 PADDR,
	input wire  [31:0] 	 PWDATA,

	output wire [31:0] 	 PRDATA,
	
	output wire [ 7:0] 	 LED
);

reg [ 7:0]  rLED;


//数据阶段数据传输
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		rLED <= 8'b0000_0000;
	else if(PSEL & PWRITE & PENABLE)
		rLED <= PWDATA[7:0];
end

//读数据
assign PRDATA = {24'h0000_00,rLED};
assign LED = rLED;

endmodule
