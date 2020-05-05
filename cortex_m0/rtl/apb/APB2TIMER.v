module APB2TIMER
(
	input wire			 PSEL,
	input wire			 PCLK,
	input wire			 PRESETn,

	input wire			 PENABLE,
	input wire			 PWRITE,

	input wire  [31:0] 	 PADDR,
	input wire  [31:0] 	 PWDATA,

	output reg  [31:0] 	 PRDATA,

	output wire 		 TIM_IRQ
);


//定时器寄存器
/*
	SR :0x40100000 
	PSC:0x40100004 bit3-0:psc
	ARR:0x40100008 bit15-0:arr
	CR :0x4010000C bit0:start bit1:irq_en bit3-2:mode
*/

reg [31:0]	TIM_SR;
reg [31:0]	TIM_PSC;
reg [31:0]	TIM_ARR;
reg [31:0]	TIM_CR;

//定时器参数
wire[ 1:0]	mode;
wire[ 3:0]	psc;
wire[15:0] 	arr;
wire 		start;
wire 		irq_en;
wire[15:0] 	tim_cnt;


//写寄存器
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		begin
			TIM_SR[15:1] <= 15'b0;
			TIM_PSC <= 32'b0;
			TIM_ARR <= 32'b0;
			TIM_CR  <= 32'b0;
		end
	else if(PSEL & PWRITE & PENABLE)
		begin
			case(PADDR[3:0])
	//			4'h0:TIM_SR  <= PWDATA;
				4'h4:TIM_PSC <= PWDATA;
				4'h8:TIM_ARR <= PWDATA;
				4'hc:TIM_CR  <= PWDATA;
				default:;
			endcase
		end
end


//读寄存器
always@(posedge PCLK or negedge PRESETn)
begin
	if(!PRESETn)
		PRDATA <= 32'b0; 
	else if(PSEL & !PWRITE & !PENABLE)
		begin
			case(PADDR[3:0])
				4'h0:PRDATA <= TIM_SR ;
				4'h4:PRDATA <= TIM_PSC;
				4'h8:PRDATA <= TIM_ARR;
				4'hc:PRDATA <= TIM_CR ;
				default:;		
			endcase
		end
	else
		PRDATA <= PRDATA;
end


//例化定时器
timer top
(
	.CLK       ( PCLK    ),
	.rst_n     ( PRESETn ),                        
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
assign psc 	   = TIM_PSC[3:0];
assign arr     = TIM_ARR[15:0];

//写状态寄存器
always@(*)
begin
	TIM_SR[31:16] = tim_cnt;
	if(TIM_IRQ)
		TIM_SR[0] = 1'b1;
	else
		TIM_SR[0] = 1'b0;
end

endmodule
