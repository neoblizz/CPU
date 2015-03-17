/* Function: regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);
 * Input: WriteData, RegWrite, ReadRegister
 * Output: ReadData1 and ReadData2
 */ 
module regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);
	
	input [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input RegWrite, clk;
	input [31:0] WriteData;
	
	output [31:0] ReadData1, ReadData2;	
	wire reset = 0;
	
	// store the output of decoder 
	wire [31:0] SelectRegister;

	// Output of Register
	wire [31:0][31:0] routReg;
	
	
	// DECODER AND WIRING WriteData
	decoder5to32 d1(.in(WriteRegister), .out(SelectRegister), .enable(RegWrite));
	// hardcode output of register0 to be zero
	assign routReg[0] = 32'b0;

	
	// connect 32 registers 
	genvar i;
	generate 
		for (i = 1;i <32;i++) begin: eachReg32
			reg32 register(.in(WriteData),.out(routReg[i]),.decoderOut(SelectRegister[i]),.reset(reset), .clk(clk));
		end
	endgenerate
	
	// send output of 32 register to 32*32 to 1 mux
   t2t2tot2Mux mux1(.arr(routReg),.s(ReadRegister1),.out(ReadData1));
	t2t2tot2Mux mux2(.arr(routReg),.s(ReadRegister2),.out(ReadData2));
	
endmodule

/* Function: reg32 (in, out, decoderOut,reset, clk);
 * Input: in and reset
 * Output: out and decoderOut
 */ 
module reg32 (in, out, decoderOut,reset, clk);
	input reset,clk;
	input decoderOut;  // store the bite crossponding to each register;
	input [31:0] in; // store write data
	output reg [31:0] out;
	reg [31:0] d;
	
	genvar i;
	generate 
		for (i = 0;i <32;i++) begin: eachDff
			mux2to1 m1 (.in0(out[i]), .in1(in[i]),.s(decoderOut),.out(d[i]));
			D_FF dFF(.q(out[i]), .d(d[i]),.reset(reset), .clk(clk));
		end
	endgenerate
	
endmodule

/* Function: D_FF (q, d, reset, clk);
 * Input: d and reset
 * Output: q
 */ 
 module D_FF (q, d, reset, clk);
	output reg q;
	input d, reset, clk;
	
	always @(posedge clk)
	if (reset)
		q <= 0; // On reset, set to 0
	else
		q <= d; // Otherwise out = d
endmodule

/* Function: decoders;
 * Input: in
 * Output: out
 */ 
module decoder2to4 (in, out, enable);
	input [1:0] in;
	input enable;
	output [3:0]out;
	wire [1:0] notOut;
	not n1(notOut[1], in[1]);
	not n2(notOut[0], in[0]);

	and a0(out[0], enable, notOut[0], notOut[1]);
	and a1(out[1], enable, in[0], notOut[1]);
	and a2(out[2], enable, notOut[0], in[1]);
	and a3(out[3], enable, in[0], in[1]);
endmodule

module decoder3to8 (in,out,enable);
	input [2:0] in;
	input enable;
	output [7:0]out;
	wire [2:0] notOut;
	not n1(notOut[2], in[2]);
	not n2(notOut[1], in[1]);
	not n3(notOut[0], in[0]);
	and a0(out[0], enable, notOut[0], notOut[1], notOut[2]);
	and a1(out[1], enable, in[0], notOut[1],notOut[2]);
	and a2(out[2], enable, notOut[0], in[1],notOut[2]);
	and a3(out[3], enable, in[0], in[1], notOut[2]);
	and a4(out[4], enable, notOut[0],notOut[1],in[2]);
	and a5(out[5], enable, in[0],notOut[1],in[2]);
	and a6(out[6], enable, notOut[0], in[1], in[2]);
	and a7(out[7], enable, in[0], in[1], in[2]);
endmodule

module decoder5to32 (in, out, enable);
	input [4:0] in;
	input enable;
	output [31:0] out;
	wire [3:0] enableOut;
	decoder3to8 d1 (in[2:0], out[7:0], enableOut[0]);
	decoder3to8 d2 (in[2:0], out[15:8], enableOut[1]);
	decoder3to8 d3 (in[2:0], out[23:16], enableOut[2]);
	decoder3to8 d4 (in[2:0], out[31:24], enableOut[3]);
	decoder2to4 d5 (in[4:3], enableOut, enable);
endmodule
