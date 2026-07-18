package risc_pkg;
	typedef enum logic [6:0] {
		OP = 7'b0110011,
		OP_IMM = 7'b0010011,	
		LOAD = 7'b0000011,
		STORE = 7'b0100011,
		BRANCH = 7'b1100011,
		JAL = 7'b1101111
	} opcodes_e;

	typedef enum logic [2:0] {
		ALU_ADD = 3'd0,
		ALU_SUB = 3'd1,
		ALU_AND = 3'd2,
		ALU_OR = 3'd3,
		ALU_XOR = 3'd4,
		ALU_SLT = 3'd5
	} alu_ops_e;
endpackage
