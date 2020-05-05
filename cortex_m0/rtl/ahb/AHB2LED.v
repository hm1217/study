module AHB2LED
(
	input wire			 HSEL,
	input wire			 HCLK,
	input wire			 HRESETn,
				
	input wire			 HREADY,
	input wire			 HWRITE,	
	input wire  [ 1:0]   HTRANS,
	input wire  [ 2:0]   HSIZE,
	
	input wire  [31:0] 	 HADDR,
	input wire  [31:0] 	 HWDATA,
	
	output wire 		 HREADYOUT,
	output wire [31:0] 	 HRDATA,
	
	output wire [ 7:0] 	 LED
);

reg 		rHSEL;
reg 		rHWRITE;
reg [ 1:0] 	rHTRANS;

reg [ 7:0]  rLED;

//地址采样阶段
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		begin
			rHSEL   <= 1'b0;
			rHWRITE <= 1'b0;
			rHTRANS <= 2'b00;
		end
	else if(HREADY)
		begin
			rHSEL   <= HSEL;
			rHWRITE <= HWRITE;
			rHTRANS <= HTRANS;		
		end
end

//数据阶段数据传输
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		rLED <= 8'b0000_0000;
	else if(rHSEL & rHWRITE & rHTRANS[1])
		rLED <= HWDATA[7:0];
end

//传输响应
assign HREADYOUT = 1'b1;

//读数据
assign HRDATA = {24'h0000_00,rLED};
assign LED = rLED;

endmodule
