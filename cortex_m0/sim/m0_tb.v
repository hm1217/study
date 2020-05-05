`timescale	1ns/1ns

`include	"../../../rtl/sys/config.v"

module	m0_tb;

	reg			clk;
	reg			rst_n;
 `ifdef	RAM_IP
	reg			write;
	reg[11:0]	wraddrin;
	reg[31:0]	wrdatain;
`endif

 `ifdef UART
	reg			rxd;
	reg			en;
	wire 		txd;
 `endif
 `ifdef SPI
	reg			miso;
	wire		cs_n;
	wire 		mosi;
	wire 		sck;
 `endif
  `ifdef GPIO
	wire[15:0] 	gpio;
 `endif
 `ifdef LED
	wire[3:0]	led;
 `endif
 
	//data to send
	reg[31:0]	txdata[0:1023];
	
	initial begin
		$readmemh("../../../keil5_proj/Obj/test.hex",txdata);
	end

`ifdef	RAM_IP
	//download code to ram
	task	download;	
	integer i;
	begin
		write = 1;
		for(i=0;i<132;i=i+1)
		begin
			@(negedge clk);
			wrdatain = txdata[i];
			wraddrin = i;
		end
		@(negedge clk);
		write = 0;
	end
	endtask
`endif

	//uart send code to ram
task uart_send;
	integer	i,j,z;
	begin
		for(i=0;i<200;i=i+1)
		begin
			for(j=0;j<4;j=j+1)
			begin
				rxd <= 0;
				#8680;
				for(z=0;z<8;z=z+1)
				begin
					rxd <= txdata[i][j*8+z];
					#8680;
				end
				rxd <= 1;
				#8680;
				#1000;
			end
		end
	end
endtask


ARM_SOC	cm0
(
	.CLK		(clk	),
	.RESET		(rst_n	),
`ifdef	RAM_IP
	.WR			(write	),
	.WRADDR		(wraddrin),
	.WRDATA		(wrdatain),
`endif

 `ifdef SPI
	.MISO		(miso	),
	.CS_N		(cs_n	),
	.MOSI		(mosi	),
	.SCK		(sck	),
 `endif
  `ifdef UART
	.RXD		(rxd	),
	.ISPEN 		(en		),
	.TXD		(txd	),
 `endif
 `ifdef LED
	.LED		(led	),
 `endif
   `ifdef GPIO
	.GPIO 		(gpio	)
 `endif
);

initial begin
	clk = 0;
	rst_n = 0;
`ifdef UART
	rxd = 1;
	en = 1;
`endif
`ifdef SPI
	miso = 1;
`endif
`ifdef	RAM_IP
	write = 0;
	wraddrin = 12'b0;
	wrdatain = 32'b0;
	#10000;
	download;
`endif

	#10000;
	rst_n = 1;
	#10000000;
	uart_send;
	en = 0;
	#100000000;
	$stop;
end


always #10 clk = ~clk;

endmodule