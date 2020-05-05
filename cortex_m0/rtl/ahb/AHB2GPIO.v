module AHB2GPIO
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
	output reg  [31:0] 	 HRDATA,
	
	inout wire  [15:0] 	 GPIO,
	output wire	[3:0]	 IRQ
);

assign HREADYOUT = 1'b1;

//15bit-0bit:0:output 1:input
//19bit-16bit:0:negedge 1:posedge

//GPIO_MR:0x40000000
//GPIO_DR:0x40000004

reg[31:0]		GPIO_MR;
reg[31:0]		GPIO_DR;

reg 			rHSEL;
reg 			rHWRITE;
reg [ 1:0] 		rHTRANS;
reg [31:0] 		rHADDR;


//地址阶段
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		rHSEL   <= 1'b0;
		rHWRITE <= 1'b0;
		rHTRANS <= 2'b00;
		rHADDR  <= 32'b0;
	end
	else if(HREADY)
	begin
		rHSEL   <= HSEL;
		rHWRITE <= HWRITE;
		rHTRANS <= HTRANS;
		rHADDR  <= HADDR;		
	end
end

//写数据
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		begin
			GPIO_MR <= 32'd0;
			GPIO_DR[15:0] <= 16'd0;
		end
	else if(rHSEL & rHWRITE & rHTRANS[1])
		begin
			case(rHADDR[3:0])
				4'h0:GPIO_MR  <= HWDATA;
				4'h4:GPIO_DR[15:0]  <= HWDATA[15:0];
				default:;
			endcase
		end
end

//读数据
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		HRDATA <= 32'd0;
	else if(HSEL & !HWRITE & HTRANS[1])
		begin
			case(HADDR[3:0])
				4'h0:HRDATA <= GPIO_MR;
				4'h4:HRDATA <= GPIO_DR;
				default:;
			endcase
		end
end

//输入模式下，GPIO相应位为高阻态
//输出模式下，GPIO相应位来源于GPIO_DR

// assign 	GPIO = (GPIO_MR[15:0] & 16'hzzzz) | (~GPIO_MR[15:0] & GPIO_DR[15:0]);
assign	GPIO[0]  = (GPIO_MR[0] ) ? 1'bz : GPIO_DR[0] ;
assign	GPIO[1]  = (GPIO_MR[1] ) ? 1'bz : GPIO_DR[1] ;
assign	GPIO[2]  = (GPIO_MR[2] ) ? 1'bz : GPIO_DR[2] ;
assign	GPIO[3]  = (GPIO_MR[3] ) ? 1'bz : GPIO_DR[3] ;
assign	GPIO[4]  = (GPIO_MR[4] ) ? 1'bz : GPIO_DR[4] ;
assign	GPIO[5]  = (GPIO_MR[5] ) ? 1'bz : GPIO_DR[5] ;
assign	GPIO[6]  = (GPIO_MR[6] ) ? 1'bz : GPIO_DR[6] ;
assign	GPIO[7]  = (GPIO_MR[7] ) ? 1'bz : GPIO_DR[7] ;
assign	GPIO[8]  = (GPIO_MR[8] ) ? 1'bz : GPIO_DR[8] ;
assign	GPIO[9]  = (GPIO_MR[9] ) ? 1'bz : GPIO_DR[9] ;
assign	GPIO[10] = (GPIO_MR[10]) ? 1'bz : GPIO_DR[10];
assign	GPIO[11] = (GPIO_MR[11]) ? 1'bz : GPIO_DR[11];
assign	GPIO[12] = (GPIO_MR[12]) ? 1'bz : GPIO_DR[12];
assign	GPIO[13] = (GPIO_MR[13]) ? 1'bz : GPIO_DR[13];
assign	GPIO[14] = (GPIO_MR[14]) ? 1'bz : GPIO_DR[14];
assign	GPIO[15] = (GPIO_MR[15]) ? 1'bz : GPIO_DR[15];

//输入模式下，GPIO赋值给GPIO_DR
/*
always@(*)
begin
	if(GPIO_MR)
		GPIO_DR[31:16] = GPIO & GPIO_MR[15:0];
	else
		GPIO_DR[31:16] = 16'd0;
end
*/

always@*
begin
	GPIO_DR[16] = (GPIO[0] ) ? 1'b1 : 1'b0;
	GPIO_DR[17] = (GPIO[1] ) ? 1'b1 : 1'b0;
	GPIO_DR[18] = (GPIO[2] ) ? 1'b1 : 1'b0;
	GPIO_DR[19] = (GPIO[3] ) ? 1'b1 : 1'b0;
	GPIO_DR[20] = (GPIO[4] ) ? 1'b1 : 1'b0;
	GPIO_DR[21] = (GPIO[5] ) ? 1'b1 : 1'b0;
	GPIO_DR[22] = (GPIO[6] ) ? 1'b1 : 1'b0;
	GPIO_DR[23] = (GPIO[7] ) ? 1'b1 : 1'b0;
	GPIO_DR[24] = (GPIO[8] ) ? 1'b1 : 1'b0;
	GPIO_DR[25] = (GPIO[9] ) ? 1'b1 : 1'b0;
	GPIO_DR[26] = (GPIO[10]) ? 1'b1 : 1'b0;
	GPIO_DR[27] = (GPIO[11]) ? 1'b1 : 1'b0;
	GPIO_DR[28] = (GPIO[12]) ? 1'b1 : 1'b0;
	GPIO_DR[29] = (GPIO[13]) ? 1'b1 : 1'b0;
	GPIO_DR[30] = (GPIO[14]) ? 1'b1 : 1'b0;
	GPIO_DR[31] = (GPIO[15]) ? 1'b1 : 1'b0;
end
reg[3:0]		gpio1,gpio2;

always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		begin
			gpio1 <= 4'd0;
			gpio2 <= 4'd0;
		end
	else
		begin
			gpio1 <= GPIO_MR[3:0] & GPIO[3:0];
			gpio2 <= gpio1;
		end
end

wire[3:0] 	POS_IRQ = !gpio2 & gpio1;
wire[3:0] 	NEG_IRQ = !gpio1 & gpio2;

assign	IRQ[0]  = (GPIO_MR[16]) ? POS_IRQ[0]  : NEG_IRQ[0] ;
assign	IRQ[1]  = (GPIO_MR[17]) ? POS_IRQ[1]  : NEG_IRQ[1] ;
assign	IRQ[2]  = (GPIO_MR[18]) ? POS_IRQ[2]  : NEG_IRQ[2] ;
assign	IRQ[3]  = (GPIO_MR[19]) ? POS_IRQ[3]  : NEG_IRQ[3] ;


endmodule
