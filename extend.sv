module mux30_2to1(Input0, Input1, s,Out);
	input [29:0] Input0;
	input [29:0] Input1;
	input s;
	output reg [29:0] Out;
	always @(*) begin
		case (s)
			 0 :  Out = Input0;
		    1 :  Out = Input1;
		endcase
	end
endmodule

module fetchUnit(Branch, Zero, Jump, JR, TargetInstr, Regrs, Imm16, PC, Bits, Jumpaddress, concat);

	input Branch,Zero,Jump,JR;	
	input [15:0] Imm16;
	output [29:0] PC;
	input [25:0] TargetInstr;
	output [3:0] Bits;
	// output reg [31:0] Address;
	
	output [29:0] Jumpaddress;
	 
	wire bez;
	and a1(bez, Branch, ~Zero);
	
	wire [29:0] immExtened; 
	wire [29:0] pcNew;
	input [31:0] Regrs;
	
	output reg [29:0] concat;

	// assign Address[1:0] = 2'b0;
	// initial begin
	 assign PC[29:0] = 30'b0;
	
	assign Bits = PC[29:26];
	// end
	
	
  
	mux30_2to1 mBez(.Input0(30'b0),.Input1({{14{Imm16[15]}},Imm16[15:0]}),
						 .s(bez),.Out(immExtened));
				  
	adder32 ad1(.Op1(PC),.Op2(immExtened),.Sum(pcNew));

	assign concat = {PC[29:26], TargetInstr[25:0]};
	
	mux30_2to1 mBJr(.Input0({PC[29:26], TargetInstr[25:0]}),
	                .Input1(Regrs[31:2]),.s(JR),.Out(Jumpaddress));
						 
	mux30_2to1 mJump(.Input0(pcNew),.Input1(Jumpaddress),
						  .s(Jump),.Out(PC));
	
 /* always @(*) begin
     Address[31:2] = PC[29:0];
  end */
	//assign PC[29:0] = Address[31:2];
  
endmodule 
	
	

module extend (Imm16, Extended, Ext);
	input [15:0] Imm16;
	input Ext;
	output reg [31:0] Extended;
	
	always @(*) begin
		case (Ext)
			 0 :  Extended = {{16{Imm16[15]}},Imm16[15:0]};
		    1 : Extended = {16'b0,Imm16[15:0]};
			default;
		endcase
	end

endmodule
// 30bit adder with 1 as carry In for PC 
module adder32 (Op1,Op2,Sum);
	input [29:0] Op1;
	input [29:0] Op2;
	output[29:0] Sum;	
	reg [29:0] CARRYOUT;
	adder  f1 (.a(Op1[0]),.b(Op2[0]),.cin(1'b1),.cout(CARRYOUT[0]),.s(Sum[0]));
	genvar i;
	generate 
	for(i = 1; i < 30; i++) begin : eachAdder
			wire mOut;

			adder  fA (.a(Op1[i]),.b(Op2[i]),.cin(CARRYOUT[i-1]),.cout(CARRYOUT[i]),.s(Sum[i]));
		end
	endgenerate
endmodule 

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
	

/*
module extendTest;
	wire[31:0] Extended;
	reg [15:0]Imm16;
	reg Ext;
	parameter ClockDelay = 100;
	extend e1(Imm16,Extended, Ext);
	initial begin 
	Imm16 = 16'b1111111111111111;
	Ext = 1 ;#(ClockDelay);
	Ext = 0 ;#(ClockDelay);
	end
endmodule 
*/
module fecthUnitTest;
	reg Branch,Zero,Jump,JR;	
	reg [15:0] Imm16;
	reg [25:0] TargetInstr;
	//wire [31:0] Instr;
	// wire [31:0] Address;
	wire [29:0] Jumpaddress;
	wire [29:0] concat;
  wire [29:0] PC;
	wire [3:0] Bits;

	// remember value of Reg[rs] for jump
	reg [31:0] Regrs;
	fetchUnit f1(Branch, Zero, Jump, JR, TargetInstr, Regrs, Imm16, PC, Bits, Jumpaddress,concat);
	parameter ClockDelay = 1000;
	
	initial begin   
	Imm16 = 16'b1111111111111111;
	TargetInstr = 26'b1111111;
	Jump = 1; JR = 0; Branch = 0; Zero = 0; #(2*ClockDelay); 
	
	Imm16 = 16'b1111111111111111;
	TargetInstr = 26'b0;
	Jump = 1; JR = 0; Branch = 0; Zero = 0; #(2*ClockDelay);
	
	Imm16 = 16'b1111111111111111;
	TargetInstr = 26'b1;
	Jump = 0; JR = 0; Branch = 1; Zero = 0; #(2*ClockDelay);
	end
endmodule 
	
	