module APB2GPIO
(
	input wire			 PCLK,
	input wire			 PRESETn,

	input wire			 PSEL,
	input wire			 PWRITE,
	input wire  [31:0] 	 PADDR,
	input wire  [31:0] 	 PWDATA,
	input wire			 PENABLE,
	
	output reg [31:0] 	 PRDATA,
	
	inout wire  [15:0] 	 GPIO
);

//0:output 1:input
reg[31:0]		GPIO_MR;
reg[31:0]		GPIO_DR;

//写数据
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		begin
			GPIO_MR <= 32'd0;
			GPIO_DR[15:0] <= 16'd0;
		end
	else if(PSEL & PWRITE & PENABLE)
		begin
			case(PADDR[3:0])
				4'h0:GPIO_MR  <= PWDATA;
				4'h4:GPIO_DR[15:0]  <= PWDATA[15:0];
				default:;
			endcase
		end
end

//读数据
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		PRDATA <= 32'd0;
	else if(PSEL & !PWRITE & !PENABLE)
		begin
			case(PADDR[3:0])
				4'h0:PRDATA <= GPIO_MR;
				4'h4:PRDATA <= GPIO_DR;
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
always@(*)
begin
	if(GPIO_MR)
		GPIO_DR[31:16] = GPIO & GPIO_MR[15:0];
	else
		GPIO_DR[31:16] = 16'd0;
end

endmodule
