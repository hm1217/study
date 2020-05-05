module AHBDCD
(
	input  wire [31:0] HADDR,             
	output reg  [ 7:0] HSEL
);


always@(*) 
begin
	case(HADDR[31:20])
		12'h000:HSEL = 8'b0000_0001;
		12'h400:HSEL = 8'b0000_0010;
		12'h401:HSEL = 8'b0000_0100;
		12'h402:HSEL = 8'b0000_1000;
		12'h403:HSEL = 8'b0001_0000;
		12'h404:HSEL = 8'b0010_0000;
		12'h900:HSEL = 8'b0100_0000;
		12'ha00:HSEL = 8'b1000_0010;		
		default:HSEL  = 8'b0;
	endcase
end

endmodule