
// Slow clock for debouncing 



module clock_div(input Clk, output reg SlowClock);
parameter clock_threshold = 2500000;
reg [23:0] clk_counter;

always @(posedge Clk ) begin 

   if (clk_counter == clock_threshold) 
	begin 
			clk_counter <= 0;
			SlowClock <= ~SlowClock; 
	end
		else 
					clk_counter <= clk_counter+1;
		end
endmodule

module clock_div1(input Clk, output reg SlowClock);
parameter clock_threshold = 50000000;
reg [27:0] clk_counter;

always @(posedge Clk ) begin 

   if (clk_counter == clock_threshold) 
	begin 
			clk_counter <= 0;
			SlowClock <= ~SlowClock; 
	end
		else 
					clk_counter <= clk_counter+1;
		end
endmodule



