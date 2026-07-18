import risc_pkg::*;

module immediate_gen(
	input logic [31:0] instruct,
	output logic[31:0] imm_out	
);

opcodes_e opcode;
assign opcode = opcodes_e'(instruct[6:0]);

always_comb begin
	imm_out = 32'd0;
	case(opcode)
		OP : imm_out = 32'd0;
		OP_IMM, LOAD : imm_out = {{20{instruct[31]}}, instruct[31:20]};
		STORE : imm_out = {{20{instruct[31]}}, instruct[31:25], instruct[11:7]};
		BRANCH : imm_out = {{20{instruct[31]}}, instruct[7], instruct[30:25], instruct[11:8], 1'b0};
		JAL : imm_out = {{12{instruct[31]}}, instruct[19:12], instruct[20], instruct[30:21], 1'b0};
	endcase
end

endmodule 
