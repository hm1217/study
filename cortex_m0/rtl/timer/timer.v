module timer
(
	input wire 			CLK,
	input wire 			rst_n,
	
	input wire[ 7:0]	psc,
	input wire[15:0] 	arr,
	input wire[ 1:0]	mode,
	input wire 			irq_en,
	input wire 			start,
	
	output reg[15:0] 	tim_cnt,
	output reg 		 	tim_irq
);

wire clk;

/*
mode
		00:从0向上计数
		01:从arr向上计数
		10:
*/
//定时器装载值
reg[15:0] value;
reg[15:0] reload;

always@*
begin
	case(mode)
		2'b00:  begin value = 16'd0; reload = 16'd0;end
		2'b01:  begin value = arr ;  reload = arr  ;end
		default:begin value = 16'd0; reload = 16'd0;end
	endcase
end

//定时器计数
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		tim_cnt <= 16'd0;
	else if(start)
	begin
		if(tim_cnt == 16'hffff)
			tim_cnt <= reload;
		else
			tim_cnt <= tim_cnt + 1'b1;
	end
	else 
		tim_cnt <= value;
end

//中断信号产生
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		tim_irq <= 1'b0;
	else if(tim_cnt == 16'hffff && irq_en == 1'b1)
		tim_irq <= 1'b1;
	else
		tim_irq <= 1'b0;
end

 prescale psc_inst
(
	.clk_in     ( CLK    ),
	.rst_n		( rst_n	 ),
	.psc        ( psc    ),
	.clk_out	( clk	 )
);


endmodule
