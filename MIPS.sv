`timescale 1 ps / 100 fs

/* Function: MIPS();
 * Input: 
 * Output: 
 * Note: The CPU instructions to be implemented are LW, SW, J, JR, BNE, XORI, ADD, SUB, and SLT.
 */
module MIPS(clk, reset);


	/********************************************************************************
	 *************************** CPU DECLARATIONS ***********************************
	 ********************************************************************************/
	
	// CLOCK SETTINGS
	input clk, reset;
	
	// MAIN DECLARATIONS
	wire [31:0] Instr;
	
	// CONTROL SIGNALS
	wire RegDst, ALUSrc, MemToReg, RegWr, MemWr, Branch, Jump, JR, ZeroExt, xRt, xRs, AccZero, AccBranch;
	wire [1:0] ALUCntrl;
	
	// REGISTER FILE VARIABLES
	wire [4:0] Rs, Rt, Rd, WriteRegister;
	wire [31:0] WriteData;
	wire [31:0] ReadData1, ReadData2;
	
	// ALU VARIABLES
	wire [31:0] BussB;
	// wire [31:0] ALUOut;
	wire zero, overflow, CarryOut, negative;
	
	// IMMEDIATE
	wire [15:0] Imm16;
	wire [31:0] Extended;
	
	// MEMORY VARIABLES
	// wire [31:0] MemOut;
	
	// JUMP TARGET 
	wire [25:0] TargetInstr;
	
	// FORWARD VARIABLES
	wire [31:0] ForwardA, ForwardB;

	
	// PIPELINE DECLARATIONS
	wire [31:0] p_Instr;
	wire [15:0] p_Imm16;
	wire p_AccBranch;
		
	// PIPELINE DECLARATIONS: STAGE 3 (EXE)
	wire ex_MemToReg, ex_RegWr, ex_MemWr;
	wire [1:0] ex_ALUCntrl;
	wire [4:0] ex_WriteRegister;
	wire [15:0] ex_Imm16;
	wire [31:0] ex_ReadData1, ex_ReadData2, ex_BussB;

	wire [31:0] ex_ALUOut;	
	
	// PIPELINE DECLARATIONS: STAGE 4 (MEM)
	wire mem_MemToReg, mem_RegWr, mem_MemWr;
	wire [4:0] mem_WriteRegister;
	wire [31:0] mem_ReadData2;
	
	wire [31:0] mem_ALUOut, mem_MemOut;
	
	// PIPELINE DECLARATIONS: STAGE 5 (WR)
	wire wr_RegWr;
	wire [4:0] wr_WriteRegister;
	wire [31:0] wr_WriteData;

	
	
	/********************************************************************************
	 ************************** INSTRUCTION FETCH ***********************************
	 ********************************************************************************/
	 
	// FETCH INSTRUCTION
	FetchUnit Fetch1(.Branch(p_AccBranch), .Zero(AccZero), .Jump(Jump), .JR(JR), .TargetInstr(TargetInstr), 
						  .Regrs(ForwardA), .Imm16(p_Imm16), .Instr, .clk, .reset);
						  
	CheckBranch CheckAccBranch(.Opcode(Instr[31:26]), .AccBranch);
	
	// PIPELINE REGISTER STAGE: IF
   PipelineRegister InstrReg (.in(Instr), .out(p_Instr), .clk, .reset);
   PipelineImm Imm16Reg (.in(Instr[15:0]), .out(p_Imm16), .clk, .reset);
	D_FF BranchReg (.q(p_AccBranch), .d(AccBranch),.reset, .clk);
	
	
	/********************************************************************************
	 ********************************* REG/DECODE ***********************************
	 ********************************************************************************/
	 
	regfile reg1(.ReadData1, .ReadData2, .WriteData(wr_WriteData), 
			  .ReadRegister1(Rs), .ReadRegister2(Rt), .WriteRegister(wr_WriteRegister),
			  .RegWrite(wr_RegWr), .clk(~clk));
			  
	Control cntrl (.Instr(p_Instr), .RegDst, .WriteRegister, .ALUSrc, .MemToReg, .RegWr, .MemWr, .Branch, 
						.Jump, .JR, .ALUCntrl, .ZeroExt, .Rs, .Rt, .Rd, .xRs, .xRt, .Imm16, .TargetInstr);
	
	// Extend immediate 16		  
	Extend Ext1(.Imm16, .Extended, .Ext(ZeroExt));
	
	// Determine source for second ALU data	
	mux32_2to1 alusrc(.Input0(ForwardB),.Input1(Extended),.s(ALUSrc),.Out(BussB));
						  
	Forward forCntrl (.Rs, .Rt, .xRs, .xRt, .PortA(ex_WriteRegister), .PortB(mem_WriteRegister), .DataA(ReadData1), 
							.DataB(ReadData2), .ALUData(ex_ALUOut), .MemData(WriteData), .ForwardA, .ForwardB);
							
	// Accelerated Branch Test
	AcceleratedBranch BranchZero (.DataA(ForwardA), .DataB(ForwardB), .Zero(AccZero));
			  
	// PIPELINE REGISTER STAGE: REG/DECODE
	PipelineRegister ReadReg1 (.in(ForwardA), .out(ex_ReadData1), .clk, .reset);
	PipelineRegister ReadReg2 (.in(ForwardB), .out(ex_ReadData2), .clk, .reset);
	PipelineRegister ALUBBussB (.in(BussB), .out(ex_BussB), .clk, .reset);
	
	PipelineExecute PipeExe (.in({MemToReg, RegWr, MemWr, ALUCntrl, WriteRegister}),
												
										 .out({ex_MemToReg, ex_RegWr, ex_MemWr, ex_ALUCntrl,
												ex_WriteRegister}), .clk, .reset);
			  
	
	
	/********************************************************************************
	 ********************************** EXECUTE *************************************
	 ********************************************************************************/
	 
	alu alu1(.Output(ex_ALUOut), .CarryOut, .zero, .overflow,
		 .negative, .BussA(ex_ReadData1), .BussB(ex_BussB), .ALUControl(ex_ALUCntrl));
		 
	// PIPELINE REGISTER STAGE: EXE
	PipelineRegister ExeALUOut (.in(ex_ALUOut), .out(mem_ALUOut), .clk, .reset);
	PipelineRegister ExeDataB (.in(ex_ReadData2), .out(mem_ReadData2), .clk, .reset);
	
	PipelineMemory PipeMem (.in({ex_MemToReg, ex_RegWr, ex_MemWr, ex_WriteRegister}),
									.out({mem_MemToReg, mem_RegWr, mem_MemWr, mem_WriteRegister}), .clk, .reset);
												
	
   /********************************************************************************
	 ************************************ MEMORY ************************************
	 ********************************************************************************/
	 
   dataMem dmem1(.data(mem_MemOut), .address(mem_ALUOut), .writedata(mem_ReadData2),
			  .writeenable(mem_MemWr), .clk(clk));
	
	/*
	PipelineRegister MemReg (.in(mem_MemOut), .out(MemOut), .clk, .reset);
	PipelineRegister MemALUOut (.in(mem_ALUOut), .out(ALUOut), .clk, .reset);
	*/
	
	
	/********************************************************************************
	 ********************************* WRITE BACK ***********************************
	 ********************************************************************************/
	 
	mux32_2to1 mem2reg(.Input0(mem_ALUOut),.Input1(mem_MemOut), .s(mem_MemToReg),.Out(WriteData));
	
	// PIPELINE REGISTER STAGE: MEM
	PipelineRegister WriteReg (.in(WriteData), .out(wr_WriteData), .clk, .reset);
	PipelineWrite PipeWr (.in({mem_RegWr, mem_WriteRegister}), 
								 .out({wr_RegWr, wr_WriteRegister}), .clk, .reset);
						  
	

endmodule

module Extend (Imm16, Extended, Ext);
	input [15:0] Imm16;
	input Ext;
	output reg [31:0] Extended;
	
	reg [31:0] SE, ZE;
	
	assign SE[31:0] = {{16{Imm16[15]}},Imm16[15:0]};
	assign ZE[31:0] = {16'b0,Imm16[15:0]};
	
	always @(*) begin
		case (Ext)
			0 : Extended = SE;
		   1 : Extended = ZE;
			default;
		endcase
	end
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
