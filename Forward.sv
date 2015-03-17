module Forward (Rs, Rt, xRs, xRt, PortA, PortB, DataA, DataB, ALUData, MemData, ForwardA, ForwardB);
	
	input xRs, xRt;
	input [4:0] Rs, Rt, PortA, PortB;
	input [31:0] DataA, DataB, ALUData, MemData;
	
	output reg [31:0] ForwardA, ForwardB;
	
	always @(*) begin
		if (Rs == 5'b00000)
			ForwardA = DataA;
		else if (Rs == PortA && !xRs)
			ForwardA = ALUData;
		else if (Rs == PortB && !xRs)
			ForwardA = MemData;
		else 
			ForwardA = DataA;
	end
	
	always @(*) begin
		if (Rt == 5'b00000)
			ForwardB = DataB;
		else if (Rt == PortA && !xRt)
			ForwardB = ALUData;
		else if (Rt == PortB && !xRt)
			ForwardB = MemData;
		else 
			ForwardB = DataB;
	end

endmodule
