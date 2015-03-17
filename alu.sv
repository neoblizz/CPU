/* Function: alu (Output, CarryOut, zero, overflow, negative, BussA, BussB, ALUControl);
 * Input: BussA, BussB, ALUControl
 * Output: Output, CarryOut, zero, overflow and negative
 */ 
module alu (Output, CarryOut, zero, overflow, negative, BussA, BussB, ALUControl);
	input [31:0] BussA, BussB;
	input [1:0] ALUControl;
	output zero, overflow, negative, CarryOut;
	wire neg;
	output [31:0] Output;
	reg [31:0] Output;
	wire [31:0] CARRYOUT;
	
	wire[31:0] AddSubOut, XOROut;
	wire SLTOut;
	wire subtract;
	
	or (subtract, ALUControl[0], ALUControl[1]);
	assign CarryOut = CARRYOUT[31];
	
	// ADDER & SUBTRACTER
	wire muxOut;
	mux2to1 t1 (.in0(BussB[0]),.in1(~BussB[0]),.s(subtract),.out(muxOut));
	adder  f1 (.a(BussA[0]),.b(muxOut),.cin(subtract),.cout(CARRYOUT[0]),.s(AddSubOut[0]));
	
	genvar i;
	generate 
	for(i = 1; i < 32; i++) begin : eachAdder
			wire mOut;
			mux2to1 tm (.in0(BussB[i]),.in1(~BussB[i]),.s(subtract),.out(mOut));
			adder  fA (.a(BussA[i]),.b(mOut),.cin(CARRYOUT[i-1]),.cout(CARRYOUT[i]),.s(AddSubOut[i]));
		end
	endgenerate
	
	// OVERFLOW
	xor(overflow, CARRYOUT[31], CARRYOUT[30]);
	
	// NEGATIVE FOR XOR
	assign neg = AddSubOut[31];
	
	// XOR
	genvar j;
	generate
	for (j = 0; j < 32; j++) begin: eachXOR
			xor(XOROut[j], BussA[j], BussB[j]);
		end
	endgenerate
	

	// SET LESS THAN
	xor (SLTOut, overflow, neg); 
	
	
	
	// ALU CONTROL 
	wire [3:0][31:0] outputArray;  
	assign outputArray[0] = AddSubOut;
	assign outputArray[1] = XOROut;
	assign outputArray[2] = AddSubOut;
	assign outputArray[3] = {{31{1'b0}}, SLTOut};
	mux32_4to32 m1(.in(outputArray),.s(ALUControl),.out(Output));
	
	// NEGATIVE
	assign negative = Output[31];

	// zero 
	genvar k;
   wire [30:0] rOut;
	or(rOut[0],Output[1],Output[0]);
	generate 
	for (k = 2; k < 32; k++) begin: eachor	
			or o1(rOut[k-1],rOut[k-2],Output[k]);
		end
	endgenerate
	not n1(zero,rOut[30]);
endmodule 

/* Function: adder(a,b,cin,cout,s);
 * Input: a, b and cin
 * Output: cout and s
 */ 
module adder(a,b,cin,cout,s);
	input a,b,cin;
	output cout,s;
	wire s1,c1,c2,c3;
	xor(s1,a,b);
	xor(s,cin,s1);
	and(c1,a,b);
	and(c2,b,cin);
	and(c3,a,cin);
	or(cout,c1,c2,c3);
endmodule 

// 30bit adder with 1 as carry In for PC 
module adder32 (Op1,Op2,Sum);
	input [29:0] Op1;
	input [29:0] Op2;
	output[29:0] Sum;	
	reg [29:0] CARRYOUT;
	//adder  f1 (.a(Op1[0]),.b(Op2[0]),.cin(1'b1),.cout(CARRYOUT[0]),.s(Sum[0]));
	adder  f1 (.a(Op1[0]),.b(Op2[0]),.cin(1'b0),.cout(CARRYOUT[0]),.s(Sum[0]));
	genvar i;
	generate 
	for(i = 1; i < 30; i++) begin : eachAdder
			wire mOut;

			adder  fA (.a(Op1[i]),.b(Op2[i]),.cin(CARRYOUT[i-1]),.cout(CARRYOUT[i]),.s(Sum[i]));
		end
	endgenerate
endmodule 
