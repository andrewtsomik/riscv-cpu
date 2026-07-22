package risc_pkg;
	typedef enum logic [6:0] {
		OP = 7'b0110011,
		OP_IMM = 7'b0010011,	
		LOAD = 7'b0000011,
		STORE = 7'b0100011,
		BRANCH = 7'b1100011,
		JAL = 7'b1101111,
		JALR = 7'b1100111,
		LUI = 7'b0110111,
		AUIPC = 7'b0010111
	} opcodes_e;

	typedef enum logic [3:0] {
		ALU_ADD = 4'd0,
		ALU_SUB = 4'd1,
		ALU_AND = 4'd2,
		ALU_OR = 4'd3,
		ALU_XOR = 4'd4,
		ALU_SLT = 4'd5,
		ALU_SLTU = 4'd6,
		ALU_SLL = 4'd7,
		ALU_SRL = 4'd8,
		ALU_SRA = 4'd9
	} alu_ops_e;
endpackage
