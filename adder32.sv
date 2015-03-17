// 32bit adder with 1 as carry In
module adder32 (Op1,Op2,Sum);
	input [31:0] Op1;
	input [31:0] Op2;
	output[31:0] Sum;	
	reg [31:0] CARRYOUT;
	adder  f1 (.a(Op1[0]),.b(Op2[0]),.cin(1),.cout(CARRYOUT[0]),.s(Sum[0]));
	genvar i;
	generate 
	for(i = 1; i < 32; i++) begin : eachAdder
			wire mOut;

			adder  fA (.a(Op1[i]),.b(Op2[i]),.cin(CARRYOUT[i-1]),.cout(CARRYOUT[i]),.s(Sum[i]));
		end
	endgenerate
endmodule 

