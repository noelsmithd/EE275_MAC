module KeyPadScanner(input PB2,input KeyRd,input Clock, input [3:0]RowIn, 
							output [3:0] ColOut, output reg [3:0]led, 
							output reg [7:0]disp,output reg [7:0]disp1,
							output reg [7:0]disp2,output reg [7:0]disp3,
							output reg [7:0]disp4,output reg data_ready,
							output reg[15:0] mem_reg);


parameter Scan=3'b000, Calculate=3'b001, Analyze=3'b010, WaitForRead=3'b011, Display=3'b100;

reg [2:0] HexState;
reg [15:0] Data;
reg [3:0] Col;
reg [3:0] Sum;
reg waitbit;

reg [1:0] display_id;

reg[3:0] data_reg;

/*Column out to the hexpad*/
assign ColOut[0] = Col[0] ? 1'bz : 1'b0; 
assign ColOut[1] = Col[1] ? 1'bz : 1'b0; 
assign ColOut[2] = Col[2] ? 1'bz : 1'b0; 
assign ColOut[3] = Col[3] ? 1'bz : 1'b0; 


/*Key pad scanner module*/
always @(posedge Clock, negedge PB2) begin
	if (PB2 == 0) begin
		HexState <= Scan;
		Col <= 4'b0111;
		Data <= 16'hFFFF;
		Sum <= 0;
		display_id <=2'b00;
		data_ready = 0;
		mem_reg <= 0;
		waitbit <= 0;
		disp = 8'h00;
		disp1 = 8'hFF;
		disp2 = 8'hFF;
		disp3 = 8'hFF;
		disp4 = 8'hFF;end
	else begin
		led[3] = data_ready;
		case(HexState)
			Scan: begin
					led[2:0] = 3'b011;
					case(Col)
						4'b0111: begin 
									if(waitbit == 1) begin
										Data[15:12] <= RowIn;
										Col <= 4'b1011;
										waitbit <= 0;
									end
									else waitbit <= 1;
									end
						4'b1011: begin
									if(waitbit == 1) begin
										Data[11:8] <= RowIn;
										Col <= 4'b1101;
										waitbit <= 0;
									end
									else waitbit <= 1;
									end
						4'b1101: begin
									if(waitbit == 1) begin
										Data[7:4] <= RowIn;
										Col <= 4'b1110;
										waitbit <= 0;
									end
									else waitbit <= 1;
									end
						4'b1110: begin
									if(waitbit == 1) begin
										Data[3:0] <= RowIn;
										Col <= 4'b0111;
										HexState <= Calculate;	
										waitbit <= 0;
									end
									else waitbit <= 1;
									end
						default: begin
									Col <= 4'b1110;
									end
					endcase	
					end 
				
			Calculate: begin
								led[2:0] = 3'b111;
								Sum <= ~Data[0] + ~Data[1] + ~Data[2] + ~Data[3]
									 + ~Data[4] + ~Data[5] + ~Data[6] + ~Data[7]
									 + ~Data[8] + ~Data[9] + ~Data[10] + ~Data[11]
									 + ~Data[12] + ~Data[13] + ~Data[14] + ~Data[15]; 
								HexState <= Analyze;
							end
			
			Analyze: begin
						led[2:0] = 3'b00;
						if(Sum == 4'b0001) begin
												case(Data)
													16'hFFFE : begin disp <= 8'hA1; data_reg <= 4'hD;end
													16'hFFFD : begin disp <= 8'h86; data_reg <= 4'hE;end
													16'hFFFB : begin disp <= 8'hC0; data_reg <= 4'h0;end
													16'hFFF7 : begin disp <= 8'h8E; data_reg <= 4'hF;end
													16'hFFEF : begin disp <= 8'hC6; data_reg <= 4'hC;end
													16'hFFDF : begin disp <= 8'h90; data_reg <= 4'h9;end
													16'hFFBF : begin disp <= 8'h80; data_reg <= 4'h8;end
													16'hFF7F : begin disp <= 8'hF8; data_reg <= 4'h7;end
													16'hFEFF : begin disp <= 8'h83; data_reg <= 4'hB;end
													16'hFDFF : begin disp <= 8'h82; data_reg <= 4'h6;end
													16'hFBFF : begin disp <= 8'h92; data_reg <= 4'h5;end
													16'hF7FF : begin disp <= 8'h99; data_reg <= 4'h4;end
													16'hEFFF : begin disp <= 8'h88; data_reg <= 4'hA;end
													16'hDFFF : begin disp <= 8'hB0; data_reg <= 4'h3;end
													16'hBFFF : begin disp <= 8'hA4; data_reg <= 4'h2;end
													16'h7FFF : begin disp <= 8'hF9; data_reg <= 4'h1;end
													default  : disp <= 8'hxx; 
												endcase				
												HexState <= WaitForRead;
											end
						else begin 		HexState <= Scan;  end
						end
			WaitForRead: begin 
								led[2:0] = 3'b100;
									if( KeyRd == 1) begin
										HexState <= Display;
										if(display_id ==0) data_ready = 0;
										
									end
							 end 
			Display : begin
							case(display_id)
							 3 : begin disp4 = disp;mem_reg[3:0]=data_reg; data_ready = 1;end//LSB
							 2 : begin disp3 = disp;mem_reg[7:4]=data_reg;end
							 1 : begin disp2 = disp;mem_reg[11:8]=data_reg;end
							 0 : begin disp1 = disp;mem_reg[15:12]=data_reg;;end //MSB
							endcase
							display_id = display_id +1;			
							HexState <= Scan;
						end
			
			default: begin 
							HexState <= Scan;
							Col <= 4'b1110;
							Data <= 16'hFFFF;
							Sum <= 0;
						end
		endcase
	end /*end for else case */
end    /*end for always*/
	
endmodule 




