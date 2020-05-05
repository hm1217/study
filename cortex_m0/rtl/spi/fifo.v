module spi_fifo
#(parameter WIDTH = 5)
(
	input  wire 		clk,
	input  wire 		rst_n,
	input  wire 		wr,
	input  wire 		rd,
	input  wire[7:0] 	wrdata,
	output reg [7:0]	rddata,
	output wire 		empty,
	output wire 		full	
);

//buffer
reg[7:0] buffer[0:(2 ** WIDTH - 1)];

//initial begin
//	$readmemb("C:/Users/Hm/Desktop/CM3/sim/buffer.hex",buffer);
//end

//读写指针
reg[WIDTH-1:0]		wr_ptr,rd_ptr;
reg[WIDTH  :0]		count;


//读写fifo
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		wr_ptr <= {WIDTH{1'b0}};
		rd_ptr <= {WIDTH{1'b0}};
		count  <= {WIDTH{1'b0}};
	end
	else begin
		if(wr && !full)begin
			buffer[wr_ptr] <= wrdata;
			wr_ptr <= wr_ptr + 1'b1;
			count  <= count + 1'b1;
		end
		if(rd && !empty)begin
			rddata <= buffer[rd_ptr];
			buffer[rd_ptr] <= 8'h0;
			rd_ptr <= rd_ptr + 1'b1;
			count  <= count - 1'b1;
		end
	end
end


//空,满标志
assign empty = (count == {1'b0,{WIDTH{1'b0}}})?1'b1:1'b0;
assign full  = (count == {1'b1,{WIDTH{1'b0}}})?1'b1:1'b0;

endmodule
