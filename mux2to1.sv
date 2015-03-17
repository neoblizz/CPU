/* Function: muxes;
 * Input: in0, in1, s
 * Output: out
 */ 
module mux2to1 (in0,in1, s,out);
	input  in0,in1;	
	input s;
	output out;
	
	wire [1:0] inOut;
	wire sNot;
	
	not (sNot, s);
	
	and a1 (inOut[0], in0, sNot);
	and a2 (inOut[1], in1, s);
	
	or o1 (out, inOut[0], inOut[1]);
endmodule

module f2oMux (in,s,out);
	input [3:0]in;
	input [1:0] s;   // s for select
	output out;
  wire aOut1, aOut2,aOut3,aOut4;
	and a1(aOut1,s[1],s[0],in[3]);
	and a2(aOut2,s[1],~s[0],in[2]);
	and a3(aOut3,~s[1],s[0],in[1]);
	and a4(aOut4,~s[1],~s[0],in[0]);
	or o1(out,aOut1,aOut2,aOut3,aOut4);
endmodule 
 
module s2oMux(in,s,out);
	input [15:0]in;
	input [3:0] s;
	reg [3:0] Output;	 // store output from four 4to1 mux
	output out;
	
	 // output from 4to2 mux
	f2oMux m0 (in[3:0], s[1:0],Output[0]);
	f2oMux m1 (in[7:4], s[1:0],Output[1]);
	f2oMux m2 (in[11:8], s[1:0],Output[2]);
	f2oMux m3 (in[15:12], s[1:0],Output[3]);
	f2oMux m4 (Output, s[3:2],out);
endmodule 

module mux30_2to1(Input0, Input1, s,Out);
	input [29:0] Input0;
	input [29:0] Input1;
	input s;
	output [29:0] Out;
	genvar i;
	generate 
		for (i = 0; i<30; i++) begin: eachMux
			mux2to1 m2(.in0(Input0[i]),.in1(Input1[i]),.s(s),.out(Out[i]));
		end
	endgenerate 
endmodule
 
module mux32_2to1(Input0, Input1, s,Out);
	input [31:0] Input0;
	input [31:0] Input1;
	input s;
	output [31:0] Out;
	genvar i;
	generate 
		for (i = 0; i<32; i++) begin: eachMux
			mux2to1 m2(.in0(Input0[i]),.in1(Input1[i]),.s(s),.out(Out[i]));
		end
	endgenerate 
endmodule
 
module t2oMux (in,s,out);
	input [31:0] in;
	input [4:0] s;
	reg [1:0] Output;
	output out;
	s2oMux s0(in[15:0],s[3:0],Output[0]);
	s2oMux s1(in[31:16],s[3:0],Output[1]);
	reg aOut1,aOut2;
	and(aOut1,Output[1],s[4]);
	and(aOut2,Output[0],~s[4]);
	or o1(out,aOut1,aOut2);
endmodule 

module mux32_4to32(in,s,out);
	input reg[3:0][31:0]in;
	output [31:0]out;
	input [1:0] s; // s for select
	wire  [31:0][3:0] tempArr; // store the flipped multidimentional array
	
	
	// use for loop to manipulate output of 32 register so that mux can take it as input
	genvar row, colm;
	generate
		for(row = 0; row < 4; row++) begin : eachR
			for(colm = 0; colm < 32; colm++) begin : eachS
				buf R(tempArr[colm][row], in[row][colm]);
			end
		end
	endgenerate
	
	genvar i;
	generate
		for(i = 0; i < 32; i++) begin : eachM
			f2oMux t0 (tempArr[i],s,out[i]);
		end
	endgenerate
	
endmodule 
	
module t2t2tot2Mux(arr,s,out);
	input reg[31:0][31:0]arr;
	output [31:0]out;
	input [4:0] s; // s for select
	wire  [31:0][31:0] tempArr; // store the flipped multidimentional array
	
	
	// use for loop to manipulate output of 32 register so that mux can take it as input
	genvar row, colm;
	generate
		for(row = 0; row < 32; row++) begin : eachR
			for(colm = 0; colm < 32; colm++) begin : eachS
				buf R(tempArr[colm][row], arr[row][colm]);
			end
		end
	endgenerate
	
	genvar i;
	generate
		for(i = 0; i < 32; i++) begin : eachM
			t2oMux t0 (tempArr[i],s,out[i]);
			
		end
	endgenerate
	
endmodule 