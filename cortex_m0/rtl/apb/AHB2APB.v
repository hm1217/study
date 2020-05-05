module AHB2APB
(
	input wire			 HSEL,
	input wire			 HCLK,
	input wire			 HRESETn,
	input wire			 HREADY,
	input wire			 HWRITE,
	input wire  [ 1:0]   HTRANS,
	input wire  [ 2:0]   HSIZE,
	input wire  [31:0] 	 HADDR,
	input wire  [31:0] 	 HWDATA,
	
	input wire  [31:0] 	 PRDATA,	

	output wire 		 HREADYOUT,
	output wire [31:0]   HRDATA,

	output wire [15:0]	 PSEL,
	output wire			 PCLK,
	output wire			 PRESETn,	
	output reg  [31:0]   PADDR,
	output reg  	 	 PWRITE,
	output reg  [31:0] 	 PWDATA,
	output wire			 PENABLE
);

assign	PCLK 	= HCLK;
assign	PRESETn = HRESETn;


//状态
parameter[7:0]		IDLE 		 = 8'b0000_0001;
parameter[7:0]		R_SETUP 	 = 8'b0000_0010;
parameter[7:0]		R_ENABLE 	 = 8'b0000_0100;
parameter[7:0]		W_WAIT 		 = 8'b0000_1000;
parameter[7:0]		W_SETUP 	 = 8'b0001_0000;
parameter[7:0]		W_ENABLE 	 = 8'b0010_0000;
parameter[7:0]		W_SETUP_SEQ  = 8'b0100_0000;
parameter[7:0]		W_ENABLE_SEQ = 8'b1000_0000;

reg[7:0]	current_state;
reg[7:0]	next_state;

wire		valid;
wire		ACRegEN;
wire[31:0]	HaddrMux;
wire		HreadyNext;
reg			HreadyReg;


assign	valid = HSEL & HTRANS[1];
assign	ACRegEN = HREADY || (current_state == R_ENABLE) || (current_state == W_ENABLE) || (current_state == W_ENABLE_SEQ);


//地址和控制信号暂存
reg			HwriteReg;
reg[31:0]	HaddrReg;

always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		begin
			HwriteReg <= 1'b1;
			HaddrReg  <= 32'b0;
		end
	else if(ACRegEN)
		begin
			HwriteReg <= HWRITE;
			HaddrReg  <= HADDR;
		end
end

assign	HaddrMux = ((next_state == R_SETUP)&&(current_state == IDLE ||current_state == R_ENABLE|| current_state == W_ENABLE))?HADDR:HaddrReg;


//状态转移
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		current_state <= IDLE;
	else
		current_state <= next_state;
end

//下一状态
always@(*)
begin
	case(current_state)
		IDLE:
			begin
				if(valid & HWRITE)
					next_state <= W_WAIT;
				else if(valid & !HWRITE)
					next_state <= R_SETUP;
				else
					next_state <= IDLE;
			end
			
		R_SETUP:
			next_state <= R_ENABLE;
			
		R_ENABLE:
			begin
				if(valid & HWRITE)
					next_state <= W_WAIT;
				else if(valid & !HWRITE)
					next_state <= R_SETUP;
				else
					next_state <= IDLE;
			end
		W_WAIT:
			begin
				if(valid)
					next_state <= W_SETUP_SEQ;
				else
					next_state <= W_SETUP;
			end
			
		W_SETUP:
			begin
				if(valid)
					next_state <= W_ENABLE_SEQ;
				else
					next_state <= W_ENABLE;
			end
			
		W_ENABLE:
			begin
				if(valid & HWRITE)
					next_state <= W_WAIT;
				else if(valid & !HWRITE)
					next_state <= R_SETUP;
				else
					next_state <= IDLE;
			end
			
		W_SETUP_SEQ:
			next_state <= W_ENABLE_SEQ;
			
		W_ENABLE_SEQ:
			begin
				if(valid & HwriteReg)
					next_state <= W_SETUP_SEQ;
				else if(!valid & HwriteReg)
					next_state <= W_SETUP;
				else
					next_state <= R_SETUP;
			end
			
		default:next_state <= IDLE;
	endcase
end

//状态输出
assign	HRDATA = PRDATA;

//HREADYOUT
assign	HreadyNext = ((next_state == R_SETUP) || (next_state == W_SETUP_SEQ) || ((next_state == W_ENABLE_SEQ) && ((!HWRITE & valid) && (HwriteReg == 1'b1)) || (current_state == W_SETUP)))? 1'b0:1'b1;

always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		HreadyReg <= 1'b1;
	else
		HreadyReg <= HreadyNext;
end

assign	HREADYOUT = HreadyReg;

//PADDR
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		PADDR <= 32'b0;
	else if((next_state == R_SETUP) || (next_state == W_SETUP) || (next_state == W_SETUP_SEQ))
		PADDR <= HaddrMux;
end

//PWRITE
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		PWRITE <= 1'b0;
	else if((next_state == R_SETUP) || (next_state == W_SETUP) || (next_state == W_SETUP_SEQ))
		PWRITE <= (next_state == W_SETUP || next_state == W_SETUP_SEQ);
end

//PENABLE
assign	PENABLE = (current_state == R_ENABLE) || (current_state == W_ENABLE) || (current_state == W_ENABLE_SEQ);

//PWDATA
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		PWDATA <= 32'b0;
	else if((next_state == W_SETUP) || (next_state == W_SETUP_SEQ))
		PWDATA <= HWDATA;
end


//APB译码
reg[15:0]		PSELint;
reg[15:0]		PSELMux;
reg[15:0]		PSELReg;

always@(*)
begin
	case(HaddrMux[23:20])
		4'b0000:PSELint = 16'b0000_0000_0000_0001;
		4'b0001:PSELint = 16'b0000_0000_0000_0010;
		4'b0010:PSELint = 16'b0000_0000_0000_0100;
		4'b0011:PSELint = 16'b0000_0000_0000_1000;
		4'b0100:PSELint = 16'b0000_0000_0001_0000;
		4'b0101:PSELint = 16'b0000_0000_0010_0000;
		4'b0110:PSELint = 16'b0000_0000_0100_0000;
		4'b0111:PSELint = 16'b0000_0000_1000_0000;
		4'b1000:PSELint = 16'b0000_0001_0000_0000;
		4'b1001:PSELint = 16'b0000_0010_0000_0000;
		4'b1010:PSELint = 16'b0000_0100_0000_0000;
		4'b1011:PSELint = 16'b0000_1000_0000_0000;
		4'b1100:PSELint = 16'b0001_0000_0000_0000;
		4'b1101:PSELint = 16'b0010_0000_0000_0000;
		4'b1110:PSELint = 16'b0100_0000_0000_0000;
		4'b1111:PSELint = 16'b1000_0000_0000_0000;
		default:PSELint = 16'b0;
	endcase
end

always@(*)
begin
	PSELMux = 16'b0;
	if(next_state == R_SETUP || next_state == W_SETUP|| next_state == W_SETUP_SEQ)
		PSELMux = PSELint;
	else if(next_state == IDLE || next_state == W_WAIT)
		PSELMux = 16'b0;
	else
		PSELMux = PSELReg;
end

//PSEL
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
		PSELReg <= 16'b0;
	else
		PSELReg <= PSELMux;
end

assign	PSEL = PSELReg;

endmodule
