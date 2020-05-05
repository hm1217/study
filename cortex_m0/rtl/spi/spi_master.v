module spi_master
(
	input wire			clk,
	input wire			rst_n,
	
	input wire		 	tx_start,
	input wire[7:0] 	txdata,
	input wire[3:0] 	psc,
	input wire			cpol,
	input wire			cpha,
	input wire			firstbit,
	input wire			MISO,
	
	output reg 			MOSI,
	output reg			SCK,
	output reg			CS_N,
	output reg[7:0] 	rxdata,
	output reg			tr_flag
);


//获得发送完成标志位
reg 	tr_flag_r0;
wire 	tr_flag_p;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        tr_flag_r0 <= 1'b0;
    else
		tr_flag_r0 <= tr_flag;
end

assign tr_flag_p = tr_flag & ~tr_flag_r0;  


//时钟发生器
wire	sck;

baud spi_baud
(
	.clk		( clk	),
	.rst_n		( rst_n	),                       
	.psc		( psc	),
	.start		( tx_start	),
	.clk_out	( sck 	)
);

//片选
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        CS_N <= 1'b1;
	else if(tx_start)
		CS_N <= 1'b0;
	else
		CS_N <= 1'b1;
end

//SCK
reg[4:0] 	num;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)begin
        SCK <= cpol;
		num <= 5'b0;
	end
	else if(tr_flag_p || !tx_start)begin
		SCK <= cpol;
		num <= 5'b0;
	end
	else if(sck || (psc == 2))
	begin
		if(num == 0)
			SCK <= cpol;
		else
			SCK <= ~SCK;
		num <= num + 1'b1;
	end
end


//SPI写
reg[2:0]	tx_state;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            tx_state <= 3'b0;
			MOSI <= 1'b1;
        end

	else if(tx_start && !tr_flag_p && (sck || (psc ==2)) && (((num%2==0) && (cpha == 1)) ||((num%2!=0) && (cpha == 0))))
        begin
            case(tx_state)
                3'd0:begin
						MOSI <= txdata[(firstbit)?7:0];
						tx_state <= 3'd1;
                     end
                3'd1:begin
						MOSI <= txdata[(firstbit)?6:1];
						tx_state <= 3'd2;
                     end
                3'd2:begin
						MOSI <= txdata[(firstbit)?5:2];
						tx_state <= 3'd3;
                     end
                3'd3:begin
						MOSI <= txdata[(firstbit)?4:3];
						tx_state <= 3'd4;
                     end
                3'd4:begin
						MOSI <= txdata[(firstbit)?3:4];
						tx_state <= 3'd5;
                     end
                3'd5:begin
						MOSI <= txdata[(firstbit)?2:5];
						tx_state <= 3'd6;
                     end
                3'd6:begin
                        MOSI <= txdata[(firstbit)?1:6];
                        tx_state <= 3'd7;
                      end
				3'd7:begin
                        MOSI <= txdata[(firstbit)?0:7];
                        tx_state <= 3'd0;
                      end
                default:;
            endcase
        end
end


//SPI主机读
reg [2:0] 	rx_state;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            rxdata <= 8'b0;
            rx_state <= 3'd0;
			tr_flag <= 1'b0;
        end

    else if(tx_start && !tr_flag_p && (sck || (psc ==2)) && (((num%2==0) && (num > 0)&& (cpha == 0)) || ((num%2!=0) && (cpha == 1))))
        begin
            case(rx_state)
                3'd0:begin
                        rxdata[(firstbit)?7:0] <= MISO;  
                        rx_state <= 3'd1;
						tr_flag  <= 1'b0;
                      end
                3'd1:begin
                        rxdata[(firstbit)?6:1] <= MISO;
                        rx_state <= 3'd2;
                      end
                3'd2:begin
                        rxdata[(firstbit)?5:2] <= MISO;
                        rx_state <= 3'd3;
                      end
                3'd3:begin
                        rxdata[(firstbit)?4:3] <= MISO;
                        rx_state <= 3'd4;
                      end
                3'd4:begin
                        rxdata[(firstbit)?3:4] <= MISO;
                        rx_state <= 3'd5;
                      end
                3'd5:begin
                        rxdata[(firstbit)?2:5] <= MISO;
                        rx_state <= 3'd6;
                      end
                3'd6:begin
                        rxdata[(firstbit)?1:6] <= MISO;
                        rx_state <= 3'd7;
                      end
                3'd7:begin
                        rxdata[(firstbit)?0:7] <= MISO;
                        rx_state <= 3'd0;
						tr_flag  <= 1'b1;
                      end
                default: ;
            endcase
        end
end


endmodule 