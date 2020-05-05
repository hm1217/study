module AHB2TIMER
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

	output wire 		 TIM_IRQ
);


//定时器寄存器
/*
	SR :0x41000000 
	PSC:0x41000004 bit7-0:psc
	ARR:0x41000008 bit15-0:arr
	CR :0x4100000C bit0:start bit1:irq_en bit3-2:mode
*/

reg [31:0]	TIM_SR;
reg [31:0]	TIM_PSC;
reg [31:0]	TIM_ARR;
reg [31:0]	TIM_CR;

//定时器参数
wire[ 1:0]	mode;
wire[ 7:0]	psc;
wire[15:0] 	arr;
wire 		start;
wire 		irq_en;
wire[15:0] 	tim_cnt;

reg 		rHSEL;
reg 		rHWRITE;
reg [ 1:0] 	rHTRANS;
reg [31:0]  rHADDR;


//地址阶段
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		rHSEL   <= 1'b0;
		rHWRITE <= 1'b0;
		rHTRANS <= 2'b00;
		rHADDR  <= 32'h0;
	end
	else if(HREADY)
	begin
		rHSEL   <= HSEL;
		rHWRITE <= HWRITE;
		rHTRANS <= HTRANS;
		rHADDR  <= HADDR;			
	end
end


//数据阶段
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		TIM_SR[15:1] <= 15'b0;
		TIM_PSC <= 32'b0;
		TIM_ARR <= 32'b0;
		TIM_CR  <= 32'b0;
	end
	else if(rHSEL & rHWRITE & rHTRANS[1])
	begin
		case(rHADDR[3:0])
//			4'h0:TIM_SR  <= HWDATA;
			4'h4:TIM_PSC <= HWDATA;
			4'h8:TIM_ARR <= HWDATA;
			4'hc:TIM_CR  <= HWDATA;
			default:;
		endcase
	end
end

//总是准备好
assign HREADYOUT = 1'b1;

//读寄存器
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		HRDATA <= 32'b0; 
	else if(HSEL & (!HWRITE) & HTRANS[1])
	begin
		case(HADDR[3:0])
			4'h0:HRDATA <= TIM_SR ;
			4'h4:HRDATA <= TIM_PSC;
			4'h8:HRDATA <= TIM_ARR;
			4'hc:HRDATA <= TIM_CR ;
			default:;		
		endcase
	end
end


//例化定时器
timer top
(
	.CLK       ( HCLK    ),
	.rst_n     ( HRESETn ),                        
	.start     ( start   ),
	.irq_en    ( irq_en  ),
	.mode      ( mode    ),
	.psc       ( psc     ),
	.arr       ( arr     ),
                         
	.tim_cnt   ( tim_cnt ),
	.tim_irq   ( TIM_IRQ )
);


//写寄存器
assign start   = TIM_CR[0];
assign irq_en  = TIM_CR[1];
assign mode    = TIM_CR[3:2];
assign psc 	   = TIM_PSC[7:0];
assign arr     = TIM_ARR[15:0];

//写状态寄存器
always@*
begin
	TIM_SR[31:16] = tim_cnt;
	if(TIM_IRQ)
		TIM_SR[0] = 1'b1;
end


endmodule
