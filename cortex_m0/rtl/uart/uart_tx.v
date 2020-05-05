module UART_TX
(
	input wire clk,
	input wire rst_n,
	input wire[7:0] txdata,
	input wire tx_int,
	input wire tx_start,
	
	output reg txd,
	output reg tx_flag	
);

parameter[10:0] IDLE = 11'b000_0000_0000,
			      S0 = 11'b000_0000_0001,
			      S1 = 11'b000_0000_0010,
			      S2 = 11'b000_0000_0100,
			      S3 = 11'b000_0000_1000,
			      S4 = 11'b000_0001_0000,
			      S5 = 11'b000_0010_0000,
			      S6 = 11'b000_0100_0000,
			      S7 = 11'b000_1000_0000,
			      S8 = 11'b001_0000_0000,
			      S9 = 11'b010_0000_0000,
			     S10 = 11'b100_0000_0000;


reg[7:0]	txdata_r;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		txdata_r <= 8'h0;
	else if(tx_start)
		txdata_r <= txdata;
end


//启动接收过程状态机
reg[10:0]	 current_state;
reg[10:0]	 next_state;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		current_state <= IDLE;
	else
		current_state <= next_state;
end

always@(*)
begin
	case(current_state)
		IDLE:next_state = (tx_int)?S0:current_state;
		  S0:next_state = (tx_int)?S1:current_state;
		  S1:next_state = (tx_int)?S2:current_state;
		  S2:next_state = (tx_int)?S3:current_state;
		  S3:next_state = (tx_int)?S4:current_state;
		  S4:next_state = (tx_int)?S5:current_state;
		  S5:next_state = (tx_int)?S6:current_state;
		  S6:next_state = (tx_int)?S7:current_state;
		  S7:next_state = (tx_int)?S8:current_state;
		  S8:next_state = (tx_int)?S9:current_state;
		  S9:next_state = (tx_int)?S10:current_state;
		 S10:next_state = IDLE;
		 default:next_state = IDLE;
	endcase
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			txd  <= 1'b1;
			tx_flag <= 1'b0;
		end
	else begin
		case(next_state)
		  IDLE:tx_flag <= 1'b0;
		    S0:begin if(tx_int) txd <= 1'b0; end
		    S1:begin if(tx_int) txd <= txdata_r[0]; end
		    S2:begin if(tx_int) txd <= txdata_r[1]; end
		    S3:begin if(tx_int) txd <= txdata_r[2]; end
		    S4:begin if(tx_int) txd <= txdata_r[3]; end
		    S5:begin if(tx_int) txd <= txdata_r[4]; end
		    S6:begin if(tx_int) txd <= txdata_r[5]; end
		    S7:begin if(tx_int) txd <= txdata_r[6]; end
		    S8:begin if(tx_int) txd <= txdata_r[7]; end
		    S9:begin if(tx_int) txd <= 1'b1; end
		   S10:begin if(tx_int) tx_flag <= 1'b1; end
		    default:;
		endcase
	end
end

endmodule

