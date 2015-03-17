/* Function: Control (Instr, RegDst, WriteRegister, ALUSrc, MemToReg, RegWr, MemWr, Branch, 
						Jump, JR, ALUCntrl, ZeroExt, Rs, Rt, Rd, Imm16, TargetInstr);
 * Input: Instruction.
 * Output: RegDst, WriteRegister, ALUSrc, MemToReg, RegWr, MemWr, Branch, 
						Jump, JR, ALUCntrl, ZeroExt, Rs, Rt, Rd, Imm16, TargetInstr.
 * Note: Determines control of the CPU.
 */

module Control (Instr, RegDst, WriteRegister, ALUSrc, MemToReg, RegWr, MemWr, Branch, 
						Jump, JR, ALUCntrl, ZeroExt, Rs, Rt, Rd, xRs, xRt, Imm16, TargetInstr);
			
	input [31:0] Instr;
	
	reg [5:0] Funct;
	reg [5:0] Opcode;
	
	// CONTROL SIGNALS
	output reg RegDst, ALUSrc, MemToReg, RegWr, MemWr, Branch, JR, ZeroExt, xRs, xRt;
	output reg Jump = 0;
	output reg [1:0] ALUCntrl;
	
	// REGISTER FILE VARIABLES
	output reg [4:0] Rs, Rt, Rd, WriteRegister;
	
	// IMMEDIATE
	output reg [15:0] Imm16;
	
	// JUMP TARGET 
	output reg [25:0] TargetInstr;
	
	assign Rs = Instr[25:21];	
	assign Rt = Instr[20:16];
	assign Rd = Instr[15:11];
	
	assign Imm16 = Instr[15:0];
	assign TargetInstr = Instr[25:0];
	
	always @(*) begin
		case (Instr[31:26])
			6'b000000  : 
			             begin
			             Funct = Instr[5:0];
			             Opcode = 6'bxxxxxx;
			             end
			default :  begin
			           Funct = 6'bxxxxxx;
			           Opcode = Instr[31:26];
			           end
		endcase
	end
	
	// R-TYPE INSTRUCTIONS
	always @(*) begin
		case (Funct)
			6'b100000  : begin 
							 RegDst = 1;
							 WriteRegister = Rd; 
							 ALUSrc = 0; 
							 MemToReg = 0; 
							 RegWr = 1; 
							 MemWr = 0; 
							 Branch = 0; 
							 Jump = 0;
							 ALUCntrl = 2'b00;
							 JR = 1'bx;
							 ZeroExt = 1'bx;
							 xRs = 0;
							 xRt = 0;
						 end // Add
						 
			6'b100010  : begin 
							 RegDst = 1; 
							 WriteRegister = Rd;
							 ALUSrc = 0; 
							 MemToReg = 0; 
							 RegWr = 1;
							 MemWr = 0; 
							 Branch = 0; 
							 Jump = 0;
							 ALUCntrl = 2'b10;
							 JR = 1'bx;
							 ZeroExt = 1'bx; 
							 xRs = 0;
							 xRt = 0;
						 end // Sub
						 
			6'b001000  : begin
							 RegDst = 1'bx; 
							 //WriteRegister = Rd;
							 ALUSrc = 1'bx; 
							 MemToReg = 1'bx; 
							 RegWr = 0; 
							 MemWr = 0; 
							 Branch = 1'bx; 
							 Jump = 1; 
							 ALUCntrl = 2'bxx;
							 JR = 1; 
							 ZeroExt = 1'bx;
							 xRs = 0;
							 xRt = 1; 
						 end // JR
						 
			6'b101010  : begin 
							 RegDst = 1; 
							 WriteRegister = Rd;
							 ALUSrc = 0; 
							 MemToReg = 0; 
							 RegWr = 1; 
							 MemWr = 0; 
							 Branch = 0; 
							 Jump = 0; 
							 ALUCntrl = 2'b11;
							 JR = 1'bx; 
							 ZeroExt = 1'bx;
							 xRs = 0;
							 xRt = 0; 
						 end // SLT
			default;
		endcase
	
	// I-TYPE INSTRUCTIONS
		case (Opcode)
			6'b100011  : begin
							 RegDst = 0; 
							 WriteRegister = Rt;
							 ALUSrc = 1; 
							 MemToReg = 1; 
							 RegWr = 1; 
							 MemWr = 0; 
							 Branch = 0; 
							 Jump = 0; 
							 ALUCntrl = 2'b00;
							 JR = 1'bx; 
							 ZeroExt = 0;
							 xRs = 0;
							 xRt = 1; 
						 end // LW
						 
			6'b101011  : begin 
							 RegDst = 1'bx; 
							 //WriteRegister = Rt;
							 ALUSrc = 1; 
							 MemToReg = 1'bx; 
							 RegWr = 0; 
							 MemWr = 1; 
							 Branch = 0; 
							 Jump = 0; 
							 ALUCntrl = 2'b00;
							 JR = 1'bx; 
							 ZeroExt = 0;
							 xRs = 0;
							 xRt = 0; 
						 end // SW
						 
			6'b000101  : begin 
							 RegDst = 1'bx;
							 //WriteRegister = Rt; 
							 ALUSrc = 0; 
							 MemToReg = 1'bx; 
							 RegWr = 0; 
							 MemWr = 0; 
							 Branch = 1; 
							 Jump = 0; 
							 ALUCntrl = 2'b10;
							 JR = 1'bx; 
							 ZeroExt = 1'bx;
							 xRs = 0;
							 xRt = 0; 
						 end // BNE
						 
			6'b001110  : begin 
							 RegDst = 0; 
							 WriteRegister = Rt;
							 ALUSrc = 1; 
							 MemToReg = 0; 
							 RegWr = 1; 
							 MemWr = 0; 
							 Branch = 0; 
							 Jump = 0; 
							 ALUCntrl = 2'b01;
							 JR = 1'bx; 
							 ZeroExt = 1; 
							 xRs = 0;
							 xRt = 1;
						 end // XORI
	
	// J-TYPE INSTRUCTIONS

			6'b000010  : begin 
							 RegDst = 1'bx; 
							 //WriteRegister = Rt;
							 ALUSrc = 1'bx; 
							 MemToReg = 1'bx; 
							 RegWr = 0; 
							 MemWr = 0; 
							 Branch = 1'bx; 
							 Jump = 1; 
							 ALUCntrl = 2'bxx;
							 JR = 0; 
							 ZeroExt = 1'bx;
							 xRs = 1;
							 xRt = 1; 
						 end // J
			default;
		endcase
	end
endmodule
