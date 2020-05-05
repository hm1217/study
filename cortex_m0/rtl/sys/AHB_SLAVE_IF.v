
module AHB_if
(
	input wire			 hsel,
	input wire			 hclk,
	input wire			 hresetn,

	input wire			 write,
	input wire	[15:0]	 wraddrin,
	input wire	[31:0]	 wrdatain,

	input wire			 hreadyin,	
	input wire  [ 1:0]   htrans,
	input wire			 hwrite,
	input wire  [ 2:0]   hsize,
	input wire  [31:0] 	 haddr,	
	input wire  [31:0] 	 hwdata,

	input wire  [31:0] 	 datain,
	
	output wire [31:0] 	 hrdata,
	output wire 		 hreadyout,
	
	output wire [ 3:0] 	 wen,
	// output wire [ 3:0] 	 ren,
	output wire [31:0] 	 dataout,
	output wire [15:0] 	 addrout
);

wire [15:0] 	 waddrout;
wire [15:0] 	 raddrout;


//总是准备好
assign 	hreadyout = 1'b1;


//判断读写的通道
reg[3:0]	cs;

always@(*)
begin
	if(hsize == 2'b10)
		cs = 4'b1111;
	else if(hsize == 2'b01)
		begin
			if(haddr[1] == 1'b0)
				cs = 4'b0011;
			else
				cs = 4'b1100;
		end
	else if(hsize == 2'b00)
		begin
			case(haddr[1:0])
				2'b00:   cs = 4'b0001;
				2'b01:   cs = 4'b0010;
				2'b10:   cs = 4'b0100;
				2'b11:   cs = 4'b1000;
			endcase
		end
	else
		cs = 4'b0000;
end

//写
reg  [3:0]	wen_r;
reg [15:0]	waddrout_r;

always@(posedge hclk or negedge hresetn)
begin
	if(!hresetn)
		begin
			wen_r <= 4'b0;
			waddrout_r <= 16'b0;
		end
	else if(hsel & hwrite & htrans[1])
		begin
			wen_r <= cs;
			waddrout_r <= haddr[17:2];
		end
	else
		begin
			wen_r <= 4'b0;
			waddrout_r <= 16'b0;
		end
end

assign	wen 	 = (write) ? 4'b1111  : wen_r;
assign	waddrout = (write) ? wraddrin : waddrout_r;
assign 	dataout  = (write) ? wrdatain : hwdata;

//读
assign	raddrout = haddr[17:2];
// assign	ren = (hsel & !hwrite & htrans[1])? cs : 4'b0000;
assign 	hrdata  = datain;

assign	addrout = (hsel & !hwrite & htrans[1]) ? raddrout : waddrout;




endmodule
