`timescale 1ns/1ps

module spi_slave_tb;

reg 			clk;
reg 			rst_n;
reg 			CS_N;
reg 			SCK;
reg [7:0] 		txd_data;
reg 			MOSI;
wire 			MISO;
wire [7:0] 		rxd_data;
wire 			rxd_flag; 

// reg [0:0] mem [15:0];

spi uut(
	.clk		( clk		),
	.rst_n		( rst_n		),
	.CS_N		( CS_N		),
	.SCK		( SCK		),
	.txd_data	( txd_data	),
	.MOSI		( MOSI		),		
	.MISO		( MISO		),
	.rxd_data	( rxd_data	),
	.rxd_flag	( rxd_flag	)
);

// initial begin
  // $readmemb("./data.txt",mem);
// end

//复位
task reset;
	input[31:0] rst_time;
	begin
		rst_n=0;
		#rst_time;
		rst_n=1;
	end
endtask


//发送数据
task send();
	integer i;
	begin
		for(i=0;i<63;i=i+1)
		begin
			@(negedge SCK);
      // MOSI<=mem[i[3:0]];	
			MOSI<={$random}%2;
		end
	end
endtask

initial begin
	clk=0;
	SCK=0;
	txd_data=8'b1010_1010;
	CS_N=0;
	reset(10000);
	send();	
end

always #10 clk=~clk;

always #1000 SCK=~SCK;

endmodule

