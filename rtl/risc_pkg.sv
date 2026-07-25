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

	typedef struct packed {
		logic [31:0] instruct;
		logic [31:0] pc;
		logic [31:0] pc_plus4;
	} if_id_t;

	typedef struct packed {
		logic [31:0] imm_out;
		logic [4:0] rd_addr1;
		logic [4:0] rd_addr2;
		logic [4:0] wr_addr;
		logic [31:0] rd_dt1;
		logic [31:0] rd_dt2;
		logic alu_src, alu_a, mem_rd, mem_wr, reg_wr, branch, jump, jalr;
		logic [2:0] branch_op;
		logic [1:0] mem_to_reg;
		logic [2:0] mem_size;
		logic [31:0] pc;
		logic [31:0] pc_plus4;
		alu_ops_e alu_op;
	} id_ex_t;

	typedef struct packed {
		logic [31:0] alu_result;
		logic [31:0] rd_dt2;
		logic mem_rd, mem_wr, reg_wr;
		logic [1:0] mem_to_reg;
		logic [2:0] mem_size;
		logic [4:0] wr_addr;
		logic [31:0] pc_plus4;
		logic [31:0] imm_out;
	} ex_mem_t;

	typedef struct packed {
		logic [31:0] imm_out;
		logic [31:0] pc_plus4;
		logic [31:0] mem_rd_dt;
		logic [31:0] alu_result;
		logic [4:0] wr_addr;
		logic [1:0] mem_to_reg;
		logic reg_wr;
	} mem_wb_t;
endpackage
