module MIPS_Stimulus;

	reg clk, reset;
	parameter ClockDelay = 1000000;

	MIPS processor(.clk(clk), .reset(reset));

	always begin
		#(ClockDelay/2); 
		clk = ~clk;
	end

	initial begin
		 clk = 0;
		 reset = 1;  #(ClockDelay);
		 reset = 1;  #(ClockDelay); 
		 reset = 0;  #(ClockDelay);
		 reset = 0;  #(ClockDelay);
		 reset = 0;  #(ClockDelay);
		 reset = 0;  #(ClockDelay);
		 reset = 0;  #(ClockDelay);
		 reset = 0;  #(ClockDelay);
		 reset = 0;  #(ClockDelay);
		 reset = 0;  #(ClockDelay);
		 reset = 0;  #(ClockDelay);
	end
endmodule
