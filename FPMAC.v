module FPMAC(input clk, input PB1,input PB2,input KeyRd,input [3:0]RowIn,
				 output reg IO8,IO9,output [3:0]ColOut,
				 output  [7:0]disp, output [3:0]led, output reg [5:0]flag,
				 output reg [7:0]disp1,output reg [7:0]disp2,
				 output  reg [7:0]disp3,output reg [7:0]disp4);

wire PB1_Out;
wire slow_clk;
wire data_ready;
reg [1:0]state = 2'b00;
reg Enable;

/* Memory variables*/
reg cs_A,we_A,oe_A,cs_B,we_B,oe_B;
reg [2:0] address;
wire [15:0] data_A; wire [15:0]data_B;
wire [15:0] mem_reg;

/*MAC variables*/

wire [15:0]ACC_Result;
reg [15:0]numA;
reg [15:0]numB;
reg stop = 1'b0;

wire [7:0]disp1K;wire [7:0]disp1R;
wire [7:0]disp2K;wire [7:0]disp2R;
wire [7:0]disp3K;wire [7:0]disp3R;
wire [7:0]disp4K;wire [7:0]disp4R;

wire slow_clk1;
/*Block instantiations*/
clock_div 		  C1(clk,slow_clk);
clock_div1		  C2(clk,slow_clk1);
debounce_handler  D1(PB1,slow_clk,PB1_Out);
KeyPadScanner 	  K1(PB2,KeyRd,slow_clk,RowIn,ColOut,led,disp,disp1K,disp2K,disp3K,disp4K,data_ready,mem_reg);
MAC  		      M1(stop,numA,numB,gclk,ACC_Result);

reg [15:0] tb_data;

always@(mem_reg,state) begin
		
		if(state == 2'b01 || state == 2'b10) tb_data = mem_reg;
		else if (state == 2'b00) tb_data =16'h0000;
		else tb_data =16'h0000;

end

SRAM SRAMA(address, data_A,cs_A,we_A,oe_A);
SRAM SRAMB(address, data_B,cs_B,we_B,oe_B);


assign data_A = (!oe_A) ? tb_data : 16'bZ;
assign data_B = (!oe_B) ? tb_data : 16'bZ;

always@(negedge PB1)
		state <= state+1; 
		

		
always@(state ) 
begin
		case(state) 
				2'b00:  begin IO9 = 0;IO8 = 0;
									flag[3]= 0; flag[2]=0;
									cs_A = 1'b1;we_A=1'b1;oe_A = 1'b0;
									cs_B = 1'b1;we_B=1'b1;oe_B = 1'b0;
									Enable = 1;
									if(D==3'b111) flag[1]= 1;
									
						 end
				
				2'b01:  begin 
							IO9 = 0;IO8 = 1;
							cs_A = 1'b1;we_A=1'b1;oe_A = 1'b0;
							cs_B = 1'b0;we_B=1'b0;oe_B = 1'b0;
							flag[3]= 0; flag[2]=1;flag[1]= 0;
							Enable = 0;
								
						  
						  end
				2'b10:  begin IO9 = 1;IO8 = 0;
						  cs_A = 1'b0;we_A=1'b0;oe_A = 1'b0;
						  cs_B = 1'b1;we_B=1'b1;oe_B = 1'b0;
						  flag[3]= 1; flag[2]=0;flag[1]= 0;
						  Enable = 0;
						  
						  end
				2'b11:  begin IO9 = 1;IO8 = 1;
						  cs_A = 1'b1;we_A=1'b0;oe_A = 1'b1;
						  cs_B = 1'b1;we_B=1'b0;oe_B = 1'b1;
						  flag[3]= 1; flag[2]=1;flag[1]= 0;
						  if(stop_counter == 4'b1011) Enable =0;
						  else Enable =1;
						  end

				default: begin IO9 = 0;IO8 = 0;
							cs_A = 1'b0;we_A=1'b0;oe_A = 1'b0;
							cs_B = 1'b0;we_B=1'b0;oe_B = 1'b0;
							flag[3]= 0; flag[2]=0;Enable = 0;flag[1]= 0;
							end
				endcase

end

reg [3:0] A = 4'b0000;reg [3:0] B= 4'b0000;
reg [2:0] C= 3'b000;reg [2:0] D= 3'b000;
always@(state) begin

		case(state)

		2'b00 : address = D;
		2'b01 : begin if(A[3]==0)address = {A[2],A[1],A[0]};else address = 3'b111;end
		2'b10 : begin if(B[3]==0)address = {B[2],B[1],B[0]};else address = 3'b111;end
		2'b11 : address = C;
		endcase

end


always @( posedge data_ready) begin

if(state == 2'b01) begin
		A = #1 A +1;
		if(A== 4'b1000 ) flag[5] = 1;end // SRAM A last input flag

else if(state == 2'b10) begin
		B = #1 B +1; 
		if(B== 4'b1000) flag[4] = 1;end //SRAM B last input flag

else begin
		A = 2'b00;B = 2'b00; 
		flag[5] = 0;flag[4] = 0;end
	  
end

/*reg [15:0] block [7:0];
initial
	begin
	block[0] = 16'h3c00;
	block[1] = 16'h4000;
	block[2] = 16'h4200;
	block[3] = 16'h4400;
	block[4] = 16'h4500;
	block[5] = 16'h4600;
	block[6] = 16'h4700;
	block[7] = 16'h4800;
end

reg [3:0]counter;
reg [3:0]result;*/

reg [3:0]stop_counter;
wire gclk;
Clockgating C4(slow_clk1, Enable, gclk);


always@(posedge gclk) begin
if (state == 2'b11) begin
	C <= #1 C+1;
	numA <= data_A;
	numB <= data_B;
	stop_counter <= stop_counter+1;
end
	
if (state == 2'b00) begin
	D <= #1 D+1;end

 end

//always@(ACC_Result)
//if(ACC_Result ==16'h4200 ) result =counter;

//always@(ACC_Result) begin
//if(ACC_Result == 16'h5A60) stop = 1'b1;
//end

//always @(stop_counter)
//if(stop_counter == 4'b1111) stop = 1'b1;

SSD S1(ACC_Result[15:12],disp1R);
SSD S2(ACC_Result[11:8],disp2R);
SSD S3(ACC_Result[7:4],disp3R);
SSD S4(ACC_Result[3:0],disp4R);

 

always@(*) begin
		case(state)
		2'b00,2'b01,2'b10:  begin disp1 = disp1K;disp2 = disp2K;disp3 = disp3K;disp4 = disp4K;end
		 		2'b11	:	 begin disp1 = disp1R;disp2 = disp2R;disp3 = disp3R;disp4 = disp4R;end
		endcase
end



endmodule

