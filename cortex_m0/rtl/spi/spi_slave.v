module spi_slave
(
	input wire			clk,
	input wire			rst_n,
	input wire			CS_N,
	input wire			SCK,
	input wire[7:0] 	txd_data,
	input wire			MOSI,
	output reg 			MISO,
	output reg[7:0] 	rxd_data,
	output 				rxd_flag 
);


/*--------------------------捕捉sck的上升沿和下降沿----------------------------*/
 
reg sck_r0,sck_r1;
wire sck_n,sck_p;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            sck_r0 <= 1'b1;   
            sck_r1 <= 1'b1;
        end
    else
        begin
            sck_r0 <= SCK;
            sck_r1 <= sck_r0;
        end
end

assign sck_n = (~sck_r0 & sck_r1)? 1'b1:1'b0;   //捕捉下降沿
assign sck_p = (~sck_r1 & sck_r0)? 1'b1:1'b0;   //捕捉上升沿


/*------------------------------spi从机读数据----------------------------------*/

reg rxd_flag_r;
reg [2:0] rxd_state;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            rxd_data <= 1'b0;
            rxd_flag_r <= 1'b0;
            rxd_state <= 3'd0;
        end
    else if(sck_p && !CS_N)   
        begin
            case(rxd_state)
                3'd0:begin
                        rxd_data[7] <= MOSI;
                        rxd_flag_r <= 1'b0;  
                        rxd_state <= 3'd1;
                      end
                3'd1:begin
                        rxd_data[6] <= MOSI;
                        rxd_state <= 3'd2;
                      end
                3'd2:begin
                        rxd_data[5] <= MOSI;
                        rxd_state <= 3'd3;
                      end
                3'd3:begin
                        rxd_data[4] <= MOSI;
                        rxd_state <= 3'd4;
                      end
                3'd4:begin
                        rxd_data[3] <= MOSI;
                        rxd_state <= 3'd5;
                      end
                3'd5:begin
                        rxd_data[2] <= MOSI;
                        rxd_state <= 3'd6;
                      end
                3'd6:begin
                        rxd_data[1] <= MOSI;
                        rxd_state <= 3'd7;
                      end
                3'd7:begin
                        rxd_data[0] <= MOSI;
                        rxd_flag_r <= 1'b1;  
                        rxd_state <= 3'd0;
                      end
                default: ;
            endcase
        end
end


/*-----------------------------获得发送完成标志位------------------------------*/

reg rxd_flag_r0,rxd_flag_r1;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            rxd_flag_r0 <= 1'b0;
            rxd_flag_r1 <= 1'b0;
        end
    else
        begin
            rxd_flag_r0 <= rxd_flag_r;
            rxd_flag_r1 <= rxd_flag_r0;
        end
end

assign rxd_flag = (~rxd_flag_r1 & rxd_flag_r0)? 1'b1:1'b0;   


/*------------------------------spi从机发送数据--------------------------------*/

reg [2:0] txd_state;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            txd_state <= 3'd0;
        end
    else if(sck_n && !CS_N)
        begin
            case(txd_state)
                3'd0:begin
                        MISO <= txd_data[7];
                        txd_state <= 3'd1;
                      end
                3'd1:begin
                        MISO <= txd_data[6];
                        txd_state <= 3'd2;
                      end
                3'd2:begin
                        MISO <= txd_data[5];
                        txd_state <= 3'd3;
                      end
                3'd3:begin
                        MISO <= txd_data[4];
                        txd_state <= 3'd4;
                      end
                3'd4:begin
                        MISO <= txd_data[3];
                        txd_state <= 3'd5;
                      end
                3'd5:begin
                        MISO <= txd_data[2];
                        txd_state <= 3'd6;
                      end
                3'd6:begin
                        MISO <= txd_data[1];
                        txd_state <= 3'd7;
                      end
                3'd7:begin
                        MISO <= txd_data[0];
                        txd_state <= 3'd0;
                      end
                default: ;
            endcase
        end
end

endmodule