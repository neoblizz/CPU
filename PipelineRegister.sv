module PipelineRegister (in, out, clk, reset);
	
	output reg [31:0] out;
	input [31:0] in;
	input reset, clk;
	
	always @(posedge clk)
	if (reset)
		out <= 32'b0;
	else
		out <= in;

endmodule

module PipelineImm (in, out, clk, reset);
	
	output reg [15:0] out;
	input [15:0] in;
	input reset, clk;
	
	always @(posedge clk)
	if (reset)
		out <= 16'b0;
	else
		out <= in;

endmodule

module PipelineExecute (in, out, clk, reset);
	
	output reg [9:0] out;
	input [9:0] in;
	input reset, clk;
	
	always @(posedge clk)
	if (reset)
		out <= 10'b0;
	else
		out <= in;

endmodule

module PipelineMemory (in, out, clk, reset);
	
	output reg [7:0] out;
	input [7:0] in;
	input reset, clk;
	
	always @(posedge clk)
	if (reset)
		out <= 8'b0;
	else
		out <= in;

endmodule

module PipelineWrite (in, out, clk, reset);
	
	output reg [5:0] out;
	input [5:0] in;
	input reset, clk;
	
	always @(posedge clk)
	if (reset)
		out <= 6'b0;
	else
		out <= in;

endmodule

module PipelineRegControls (in, out, clk, reset);
	
	output reg [19:0] out;
	input [19:0] in;
	input reset, clk;
	
	always @(posedge clk)
	if (reset)
		out <= 20'b0;
	else
		out <= in;

endmodule

module PipelineControls (in, out, clk, reset);
	
	output reg [10:0] out;
	input [10:0] in;
	input reset, clk;
	
	always @(posedge clk)
	if (reset)
		out <= 11'b0;
	else
		out <= in;

endmodule
