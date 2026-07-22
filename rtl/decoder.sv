import risc_pkg::*;

module decoder(
	input logic [31:0] instruct,

	output logic reg_wr,
	output logic alu_src,
	output logic mem_rd,
	output logic mem_wr,
	output logic [1:0] mem_to_reg,
	output logic branch,
	output logic jump,
	output logic alu_a,
	output alu_ops_e alu_op
);

	opcodes_e opcode;
        assign opcode = opcodes_e'(instruct[6:0]); 

	always_comb begin
		reg_wr = 1'd0;
		alu_src = 1'd0;
		mem_rd = 1'd0;
		mem_wr = 1'd0;
		mem_to_reg = 2'd0;
		branch = 1'd0;
		jump = 1'd0;
		alu_a = 1'd0;
		case(opcode)
			OP : reg_wr = 1'd1;
			OP_IMM : begin
					reg_wr = 1'd1;
					alu_src = 1'd1;
				 end
			LOAD : begin
			   		reg_wr = 1'd1;
					alu_src = 1'd1;
					mem_rd = 1'd1;
					mem_to_reg = 2'd1;
			       end
			STORE : begin
		 			alu_src = 1'd1;
					mem_wr = 1'd1;
				end
			BRANCH : branch = 1'd1;
			LUI : begin
					reg_wr = 1'd1;
					mem_to_reg = 2'd3;
			      end
		      	JAL, JALR : begin
			   		reg_wr = 1'd1;
					alu_src = 1'd1;
					jump = 1'd1;
					mem_to_reg = 2'd2;
				    end
			AUIPC : begin
		    			reg_wr = 1'd1;
					alu_src = 1'd1;
					alu_a = 1'd1;
				end		
		endcase
	end

	always_comb begin
		alu_op = ALU_ADD;
		case(opcode)
			OP : begin
					case(instruct[14:12])
						3'b000 : begin
								if(instruct[30])
									alu_op = ALU_SUB;
								else
									alu_op = ALU_ADD;
							end
						3'b111 : alu_op = ALU_AND;
						3'b110 : alu_op = ALU_OR;
						3'b100 : alu_op = ALU_XOR;
						3'b010 : alu_op = ALU_SLT;
					endcase
			     end
		       OP_IMM : begin
			       		case(instruct[14:12])
						3'b000 : alu_op = ALU_ADD;
						3'b111 : alu_op = ALU_AND;
						3'b110 : alu_op = ALU_OR;
						3'b100 : alu_op = ALU_XOR;
						3'b010 : alu_op = ALU_SLT;
					endcase
				end
		      LOAD, STORE, AUIPC, JALR : alu_op = ALU_ADD;
		      BRANCH : alu_op = ALU_SUB;
		endcase
	end


endmodule
