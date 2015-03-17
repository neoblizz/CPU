module AcceleratedBranch (DataA, DataB, Zero);

	input [31:0] DataA, DataB;
	output reg Zero;
	
	wire [31:0] Equivalency;
	wire [7:0] Equiv;
	wire [1:0] ZeroTest;
	
	assign Equivalency = DataA ^ DataB;
	
	/*nor (Equiv[0], Equivalency[0], Equivalency[1], Equivalency[2], Equivalency[3]);
	nor (Equiv[1], Equivalency[4], Equivalency[5], Equivalency[6], Equivalency[7]);
	nor (Equiv[2], Equivalency[8], Equivalency[9], Equivalency[10], Equivalency[11]);
	nor (Equiv[3], Equivalency[12], Equivalency[13], Equivalency[14], Equivalency[15]);
	
	nor (Equiv[4], Equivalency[16], Equivalency[17], Equivalency[18], Equivalency[19]);
	nor (Equiv[5], Equivalency[20], Equivalency[21], Equivalency[22], Equivalency[23]);
	nor (Equiv[6], Equivalency[24], Equivalency[25], Equivalency[26], Equivalency[27]);
	nor (Equiv[7], Equivalency[28], Equivalency[29], Equivalency[30], Equivalency[31]);
	
	and (ZeroTest[0], Equiv[0], Equiv[1], Equiv[2], Equiv[3]);
	and (ZeroTest[1], Equiv[4], Equiv[5], Equiv[6], Equiv[7]);
	
	and (Zero, ZeroTest[0], ZeroTest[1]);*/
	
	always @(*) begin
		case(Equivalency)
			32'b0 : Zero = 1;
			default : Zero = 0;
		endcase
	end

endmodule

module CheckBranch (Opcode, AccBranch);
	input [5:0] Opcode;
	output AccBranch;
	
	wire [5:0] Branch;
	assign Branch = 6'b000101;
	wire [5:0] Cmp;
	
	genvar i;
	generate
		for (i = 0; i < 6; i++) begin : eachXor
			xor each_xor(Cmp[i], Opcode[i], Branch[i]);
		end
	endgenerate
	
	nor n(AccBranch, Cmp[0], Cmp[1], Cmp[2], Cmp[3], Cmp[4], Cmp[5]);

endmodule
