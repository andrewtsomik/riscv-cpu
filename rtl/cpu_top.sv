import risc_pkg::*;

module cpu_top(
	input logic clk,
	input logic rst	
);

	logic [31:0] pc_next, pc_out, pc_plus4, branch_target;
	logic [31:0] instruct;
	logic [31:0] rd_dt1, rd_dt2, imm_out;
	logic [31:0] alu_b, alu_result, wr_dt, mem_rd_dt;
	logic [31:0] alu_a_val, jump_target;
	logic alu_zero, lt_signed, lt_unsigned;

	logic reg_wr, alu_src, mem_rd, mem_wr, branch, jump, alu_a;
	logic [1:0] mem_to_reg;
	logic cond;
	alu_ops_e alu_op;
	opcodes_e opcode;

	pc_register pc_inst(.clk(clk), .rst(rst), .pc_next(pc_next), .pc_out(pc_out));
	instruct_mem instr_mem_inst(.addr(pc_out), .instruct(instruct));
	register_file reg_inst(.rd_addr1(instruct[19:15]), .rd_addr2(instruct[24:20]), .wr_addr(instruct[11:7]), .wr_dt(wr_dt), .clk(clk), .wr_en(reg_wr), .rd_dt1(rd_dt1), .rd_dt2(rd_dt2));
	decoder decoder_inst(.instruct(instruct), .reg_wr(reg_wr), .alu_src(alu_src), .mem_rd(mem_rd), .mem_wr(mem_wr), .mem_to_reg(mem_to_reg), .branch(branch), .jump(jump), .alu_a(alu_a), .alu_op(alu_op));
	immediate_gen gen_inst(.instruct(instruct), .imm_out(imm_out));
	alu alu_inst(.o1(alu_a_val), .o2(alu_b), .oper(alu_op), .result(alu_result), .zero(alu_zero), .lt_signed(lt_signed), .lt_unsigned(lt_unsigned));
	data_mem data_mem_inst(.clk(clk), .mem_addr(alu_result), .mem_wr_dt(rd_dt2), .mem_wr(mem_wr), .mem_rd(mem_rd), .mem_rd_dt(mem_rd_dt));

	assign pc_plus4 = pc_out + 32'd4;
	assign branch_target = pc_out + imm_out;
	assign opcode = opcodes_e'(instruct[6:0]);
	always_comb begin
		case(instruct[14:12])
			3'd0 : cond = alu_zero;
	        	3'd1 : cond = ~alu_zero;
			3'd4 : cond = lt_signed;
			3'd5 : cond = ~lt_signed;
			3'd6 : cond = lt_unsigned;
			3'd7 : cond = ~lt_unsigned;
			default : cond = 1'b0;
		endcase
	end
	assign pc_next = jump ? jump_target : ((branch & cond) ? branch_target : pc_plus4);
	assign alu_b = alu_src ? imm_out : rd_dt2;
	assign alu_a_val = alu_a ? pc_out : rd_dt1;
	assign jump_target = (opcode == JALR) ? alu_result : branch_target;
	always_comb begin
		case(mem_to_reg)
			2'd0 : wr_dt = alu_result;
			2'd1 : wr_dt = mem_rd_dt;
			2'd2 : wr_dt = pc_plus4;
			2'd3 : wr_dt = imm_out;
			default : wr_dt = alu_result;
		endcase		
	end	
endmodule
