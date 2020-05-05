`timescale	1ns/1ns
`define	GPIO_MR	32'h40040000
`define	GPIO_DR	32'h40040004

module	gpio_tb;

reg			 PCLK;
reg			 PRESETn;
reg			 PSEL;
reg			 PWRITE;	
reg [31:0]   PADDR;
reg [31:0]   PWDATA;
reg			 PENABLE;
wire[31:0]   PRDATA;
wire[15:0]   GPIO;


reg[15:0]	 io_dir;
reg[15:0]	 gpio_dr;
reg[31:0]	 rxdata;

APB2GPIO		gpio_inst
(	
	.PCLK       ( PCLK      ),
	.PRESETn    ( PRESETn   ),
	.PSEL		( PSEL		),
	.PWRITE	    ( PWRITE	),
	.PADDR      ( PADDR     ),
	.PWDATA     ( PWDATA    ),
	.PENABLE    ( PENABLE   ),
	.PRDATA     ( PRDATA    ),
	.GPIO       ( GPIO      )
);

task	write_reg;
	input reg[31:0]	register;
	input reg[31:0]	wrdata;
		begin
			@(posedge PCLK);
			PSEL    = 1;
			PWRITE  = 1;
			PADDR   = register;
			PWDATA  = wrdata;
			PENABLE = 0;
			@(posedge PCLK);
			PENABLE = 1;
			@(posedge PCLK);
			PSEL    = 0;
			PWRITE  = 0;
			PENABLE = 0;
		end
endtask

task	read_reg;
	input  reg[31:0]	register;
	output reg[31:0]	rddata;
		begin
			@(posedge PCLK);
			PSEL    = 1;
			PWRITE  = 0;
			PADDR   = register;
			PENABLE = 0;
			@(posedge PCLK);
			PENABLE = 1;
			@(posedge PCLK);
			PSEL    = 0;
			PWRITE  = 0;
			PENABLE = 0;
			rddata  = PRDATA[31:16];
		end
endtask

initial	begin
	PCLK 	= 0;
	PRESETn = 0;
	PSEL    = 0;
	PWRITE  = 0;
	PADDR   = 0;
	PWDATA  = 0;
	PENABLE = 0;
	io_dir  = 0;
	gpio_dr = 0;
	#10000;
	PRESETn = 1;
	#10000;
	write_reg(`GPIO_MR,32'h0000_0f0f);
	#10000;

	io_dir  = 16'hf;
	gpio_dr = 16'h5;
	#10000;
	read_reg(`GPIO_DR,rxdata);
	#10000;
	write_reg(`GPIO_DR,32'h0000_00a0);
	#10000;
	write_reg(`GPIO_DR,32'h0000_0050);
end

// assign	GPIO = (~io_dir & 16'hzzzz) | (io_dir & gpio_dr);
assign	GPIO[0]  = (~io_dir[0] ) ? 1'bz : gpio_dr[0] ;
assign	GPIO[1]  = (~io_dir[1] ) ? 1'bz : gpio_dr[1] ;
assign	GPIO[2]  = (~io_dir[2] ) ? 1'bz : gpio_dr[2] ;
assign	GPIO[3]  = (~io_dir[3] ) ? 1'bz : gpio_dr[3] ;
assign	GPIO[4]  = (~io_dir[4] ) ? 1'bz : gpio_dr[4] ;
assign	GPIO[5]  = (~io_dir[5] ) ? 1'bz : gpio_dr[5] ;
assign	GPIO[6]  = (~io_dir[6] ) ? 1'bz : gpio_dr[6] ;
assign	GPIO[7]  = (~io_dir[7] ) ? 1'bz : gpio_dr[7] ;
assign	GPIO[8]  = (~io_dir[8] ) ? 1'bz : gpio_dr[8] ;
assign	GPIO[9]  = (~io_dir[9] ) ? 1'bz : gpio_dr[9] ;
assign	GPIO[10] = (~io_dir[10]) ? 1'bz : gpio_dr[10];
assign	GPIO[11] = (~io_dir[11]) ? 1'bz : gpio_dr[11];
assign	GPIO[12] = (~io_dir[12]) ? 1'bz : gpio_dr[12];
assign	GPIO[13] = (~io_dir[13]) ? 1'bz : gpio_dr[13];
assign	GPIO[14] = (~io_dir[14]) ? 1'bz : gpio_dr[14];
assign	GPIO[15] = (~io_dir[15]) ? 1'bz : gpio_dr[15];

always#10	PCLK = ~PCLK;

endmodule
