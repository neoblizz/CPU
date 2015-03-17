/* Function: MIPS();
 * Input: 
 * Output: 
 * Note: The CPU instructions to be implemented are LW, SW, J, JR, BNE, XORI, ADD, SUB, and SLT.
 */

module FetchUnit(Branch, Zero, Jump, JR, TargetInstr, Regrs, Imm16, Instr, clk, reset);

	input Branch,Zero,JR, Jump, clk,reset;
	input [15:0] Imm16;
	input [25:0] TargetInstr;
	input [31:0] Regrs;
	
	output [31:0] Instr;	
	wire [29:0] PC;
	reg [31:0] Address;
	
	wire [29:0] temp_PC;
	wire [29:0] Jumpaddress; 
	wire bez;
	and a1(bez, Branch, ~Zero);
	wire [29:0] immExtened; 
	wire [29:0] pcNew;

	assign Address[1:0] = 2'b0;

	mux30_2to1 mBez(.Input0({29'b0,1'b1}),.Input1({{14{Imm16[15]}},Imm16[15:0]}),
						 .s(bez),.Out(immExtened));
						 
	adder32 ad1(.Op1(PC),.Op2(immExtened),.Sum(pcNew));

	mux30_2to1 mBJr(.Input0({PC[29:26], TargetInstr[25:0]}),
	                .Input1(Regrs[31:2]),.s(JR),.Out(Jumpaddress));
						 
	mux30_2to1 mJump(.Input0(pcNew),.Input1(Jumpaddress),
						  .s(Jump),.Out(temp_PC));
	
   genvar i;
	generate
		for ( i = 0; i<30;i++) begin: eachDFF
			D_FF d(.q(PC[i]),.d(temp_PC[i]),.reset(reset),.clk(clk));
		end
	endgenerate
	
	assign Address [31:2] = PC[29:0]; 
	
	InstructionMem I1(.instruction(Instr), .address(Address));
	
endmodule 

/* module FETCHTEST;
	reg Branch,Zero,Jump,JR,clk,reset;	
	reg [15:0] Imm16;
	reg [25:0] TargetInstr;
	reg [31:0] Instr;

   // remember value of Reg[rs] for jump
	wire [31:0] Regrs; 
	FetchUnit f1(Branch, Zero, Jump, JR, TargetInstr, Regrs, Imm16, Instr, clk, reset);
	parameter ClockDelay = 10000;
	
	always begin
	#(ClockDelay/2)
	clk = ~clk;
	end 
	
	initial begin 
  
  clk = 0;

	reset = 1;#(ClockDelay)
	reset = 1;#(ClockDelay)
	
	reset = 0;
	//Imm16 = 16'b1111111111111111;
	//TargetInstr = 26'b1111111;
	
	//Jump = 0; JR = 0; Branch = 0; Zero = 0; 
	#(ClockDelay); 
	
	//Imm16 = 16'b1111111111111111;
	//TargetInstr = 26'b0;
	//Jump = 0; JR = 0; Branch = 0; Zero = 0; 
	#(ClockDelay);
	
	//Imm16 = 16'b1111111111111111;
	//TargetInstr = 26'b1;
	//Jump = 0; JR = 0; Branch = 0; Zero = 0; 
	#(ClockDelay);
	end
endmodule*/
	