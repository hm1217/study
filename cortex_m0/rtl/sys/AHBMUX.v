module AHBMUX
(
	input wire 		    HCLK,
	input wire 		    HRESETn,
	input wire [ 7:0]   MUX_SEL, 
	
	input wire [31:0]   HRDATA_S0, 
	input wire [31:0]   HRDATA_S1, 
	input wire [31:0]   HRDATA_S2, 
	input wire [31:0]   HRDATA_S3, 
	input wire [31:0]   HRDATA_S4, 
	input wire [31:0]   HRDATA_S5, 
	input wire [31:0]   HRDATA_S6, 
	input wire [31:0]   HRDATA_S7, 
	
	input wire 			HREADYOUT_S0,
	input wire 			HREADYOUT_S1,
	input wire 			HREADYOUT_S2,
	input wire 			HREADYOUT_S3,
	input wire 			HREADYOUT_S4,
	input wire 			HREADYOUT_S5,
	input wire 			HREADYOUT_S6,
	input wire 			HREADYOUT_S7,	

	output reg [31:0]	HRDATA,
	output reg 	   		HREADY
);

reg [7:0]	MUX_SEL_r;

always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		MUX_SEL_r <= 8'h0;
	else if(HREADY)
		MUX_SEL_r <= MUX_SEL;
end

always@(*)
begin
	case(MUX_SEL_r)
		8'h01:begin
			HRDATA = HRDATA_S0;
			HREADY = HREADYOUT_S0;
		end

		8'h02:begin
			HRDATA = HRDATA_S1;
			HREADY = HREADYOUT_S1;
		end
		
		8'h04:begin
			HRDATA = HRDATA_S2;
			HREADY = HREADYOUT_S2;
		end
		
		8'h08:begin
			HRDATA = HRDATA_S3;
			HREADY = HREADYOUT_S3;
		end
		
		8'h10:begin
			HRDATA = HRDATA_S4;
			HREADY = HREADYOUT_S4;
		end
		
		8'h20:begin
			HRDATA = HRDATA_S5;
			HREADY = HREADYOUT_S5;
		end
		
		8'h40:begin
			HRDATA = HRDATA_S6;
			HREADY = HREADYOUT_S6;
		end
		
		8'h80:begin
			HRDATA = HRDATA_S7;
			HREADY = HREADYOUT_S7;
		end
		
		default:begin
			HRDATA = 32'hdeadbeef;
			HREADY = 1'b1;
		end
	endcase
end

endmodule