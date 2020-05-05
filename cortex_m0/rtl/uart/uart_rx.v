module UART_RX
(
	input wire clk,
	input wire rst_n,
	input wire rxd,
	input wire rx_int,
	
	output wire rx_neg,
	output reg[7:0]	rxdata,
	output reg rx_flag	
);

parameter[9:0]  IDLE = 10'b00_0000_0000,
		          S0 = 10'b00_0000_0001,
		          S1 = 10'b00_0000_0010,
		          S2 = 10'b00_0000_0100,
		          S3 = 10'b00_0000_1000,
		          S4 = 10'b00_0001_0000,
		          S5 = 10'b00_0010_0000,
		          S6 = 10'b00_0100_0000,
		          S7 = 10'b00_1000_0000,
		          S8 = 10'b01_0000_0000,
		          S9 = 10'b10_0000_0000;
		         // S10 = 11'b100_0000_0000;

//鎹曟崏rxd涓嬮檷娌
reg  rx_neg_r1;
reg  rx_neg_r2;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			rx_neg_r1 <= 1'b1;
			rx_neg_r2 <= 1'b1;
		end
	else
		begin
			rx_neg_r1 <= rxd;
			rx_neg_r2 <= rx_neg_r1;
		end
end

assign rx_neg = (~rx_neg_r1) & rx_neg_r2;

//鍚姩鎺ユ敹杩囩▼鐘舵€佹満
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
		IDLE:next_state = (rx_int)? S0:current_state;
		  S0:next_state = (rx_int)? S1:current_state;
		  S1:next_state = (rx_int)? S2:current_state;
		  S2:next_state = (rx_int)? S3:current_state;
		  S3:next_state = (rx_int)? S4:current_state;
		  S4:next_state = (rx_int)? S5:current_state;
		  S5:next_state = (rx_int)? S6:current_state;
		  S6:next_state = (rx_int)? S7:current_state;
		  S7:next_state = (rx_int)? S8:current_state;
		  S8:next_state = (rx_int)? S9:current_state;
		  S9:next_state = IDLE;
		  // S10:next_state = IDLE;
		  default:next_state = IDLE;
	endcase
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
			rxdata  <= 8'h0;
			rx_flag <= 1'b0;
		end
	else begin
		case(next_state)
			IDLE:;
			  S0:rx_flag <= 1'b0;
			  S1:begin if(rx_int) rxdata  <= {rxd,rxdata[7:1]}; end
			  S2:begin if(rx_int) rxdata  <= {rxd,rxdata[7:1]}; end
			  S3:begin if(rx_int) rxdata  <= {rxd,rxdata[7:1]}; end
			  S4:begin if(rx_int) rxdata  <= {rxd,rxdata[7:1]}; end
			  S5:begin if(rx_int) rxdata  <= {rxd,rxdata[7:1]}; end
			  S6:begin if(rx_int) rxdata  <= {rxd,rxdata[7:1]}; end
			  S7:begin if(rx_int) rxdata  <= {rxd,rxdata[7:1]}; end
			  S8:begin if(rx_int) rxdata  <= {rxd,rxdata[7:1]}; end
			  S9:begin if(rx_int) rx_flag <= 1'b1; end
			  // S10:;
		      default:;
		endcase
	end
end

endmodule
