import risc_pkg::*;

module alu(
	input logic [31:0] o1,
	input logic [31:0] o2,
	input alu_ops_e oper,
	output logic [31:0] result,
	output logic zero	
);
	assign zero = (result == 32'd0);
	always_comb begin
		result = 32'd0;
		case(oper)
			ALU_ADD : result = o1 + o2;
			ALU_SUB : result = o1 - o2;
			ALU_AND : result = o1 & o2;
			ALU_OR : result = o1 | o2;
			ALU_XOR : result = o1 ^ o2;
			ALU_SLT : result = $signed(o1) < $signed(o2);
		endcase
	end
endmodule
