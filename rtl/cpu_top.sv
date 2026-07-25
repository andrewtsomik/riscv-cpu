import risc_pkg::*;

module cpu_top(
	input logic clk,
	input logic rst,
	output logic [3:0] led,
	output logic uart_tx	
);

	logic [31:0] pc_next, pc_plus4, branch_target;
	logic [31:0] instruct;
	logic [31:0] rd_dt1, rd_dt2, imm_out;
	logic [31:0] alu_b, alu_result, wr_dt, mem_rd_dt;
	logic [31:0] alu_a_val, jump_target;
	logic alu_zero, lt_signed, lt_unsigned;

	logic reg_wr, alu_src, mem_rd, mem_wr, branch, jump, alu_a, jalr;
	logic [2:0] branch_op;
	logic [2:0] mem_size;
	logic [1:0] mem_to_reg;
	logic cond;
	alu_ops_e alu_op;

	if_id_t if_id_reg;
	if_id_t if_id_next;
	id_ex_t id_ex_reg;
	id_ex_t id_ex_next;
	ex_mem_t ex_mem_reg;
	ex_mem_t ex_mem_next;
	mem_wb_t mem_wb_reg;
	mem_wb_t mem_wb_next;
	logic [31:0] pc;

	logic [31:0] ex_mem_fwd_val, fwd_rd_addr1, fwd_rd_addr2;
	logic [1:0] forward_a, forward_b;
	logic [31:0] mem_rd_shifted, mem_rd_ext;

	logic stall;
	logic flush;

	logic [7:0] uart_dt;
	logic uart_send;
	logic uart_busy;

	//Stage 1: Fetch
	always_ff @(posedge clk or posedge rst) begin
		if(rst)
			pc <= '0;
		else if(!stall)
			pc <= pc_next;
	end

	instruct_mem instruct_mem_inst(.addr(pc), .instruct(instruct));

	assign pc_plus4 = pc + 32'd4;
	assign pc_next = id_ex_reg.jump ? jump_target : ((id_ex_reg.branch & cond) ? branch_target : pc_plus4);
	assign if_id_next.instruct = instruct;
	assign if_id_next.pc = pc;
	assign if_id_next.pc_plus4 = pc_plus4;

	always_ff @(posedge clk or posedge rst) begin
		if(rst)
			if_id_reg <= '0;
		else if(flush)
			if_id_reg <= '0;
		else if(!stall)
			if_id_reg <= if_id_next;
	end

	//Stage 2: Decode
	decoder decoder_inst(.instruct(if_id_reg.instruct), .reg_wr(reg_wr), .alu_src(alu_src), .mem_rd(mem_rd), .mem_wr(mem_wr), .mem_to_reg(mem_to_reg), .branch(branch), .jump(jump), .alu_a(alu_a), .alu_op(alu_op), .branch_op(branch_op
	), .jalr(jalr), .mem_size(mem_size));
	register_file reg_inst(.rd_addr1(if_id_reg.instruct[19:15]), .rd_addr2(if_id_reg.instruct[24:20]), .wr_addr(mem_wb_reg.wr_addr), .wr_dt(wr_dt), .clk(clk), .wr_en(mem_wb_reg.reg_wr), .rd_dt1(rd_dt1), .rd_dt2(rd_dt2));
	immediate_gen gen_inst(.instruct(if_id_reg.instruct), .imm_out(imm_out));

	assign id_ex_next.reg_wr = reg_wr;
	assign id_ex_next.alu_src = alu_src;
	assign id_ex_next.mem_rd = mem_rd;
	assign id_ex_next.mem_wr = mem_wr;
	assign id_ex_next.mem_to_reg = mem_to_reg;
	assign id_ex_next.branch = branch;
	assign id_ex_next.jump = jump;
	assign id_ex_next.alu_a = alu_a;
	assign id_ex_next.alu_op = alu_op;
	assign id_ex_next.branch_op = branch_op;
	assign id_ex_next.jalr = jalr;
	assign id_ex_next.mem_size = mem_size;
	assign id_ex_next.rd_addr1 = if_id_reg.instruct[19:15];
	assign id_ex_next.rd_addr2 = if_id_reg.instruct[24:20];
	assign id_ex_next.wr_addr = if_id_reg.instruct[11:7];
	assign id_ex_next.rd_dt1 = rd_dt1;
	assign id_ex_next.rd_dt2 = rd_dt2;
	assign id_ex_next.imm_out = imm_out;
	assign id_ex_next.pc = if_id_reg.pc;
	assign id_ex_next.pc_plus4 = if_id_reg.pc_plus4;
	assign stall = id_ex_reg.mem_rd && (id_ex_reg.wr_addr != 0) && (id_ex_reg.wr_addr == if_id_reg.instruct[19:15] || id_ex_reg.wr_addr == if_id_reg.instruct[24:20]);

	always_ff @(posedge clk or posedge rst) begin
		if(rst)
			id_ex_reg <= '0;
		else if(stall || flush)
			id_ex_reg <= '0;
		else
			id_ex_reg <= id_ex_next;
	end

	//Stage 3: Execute
	assign alu_a_val = id_ex_reg.alu_a ? id_ex_reg.pc : fwd_rd_addr1;
	assign alu_b = id_ex_reg.alu_src ? id_ex_reg.imm_out : fwd_rd_addr2;

	alu alu_inst(.o1(alu_a_val), .o2(alu_b), .oper(id_ex_reg.alu_op), .result(alu_result), .zero(alu_zero), .lt_signed(lt_signed), .lt_unsigned(lt_unsigned));

	assign branch_target = id_ex_reg.pc + id_ex_reg.imm_out;
	always_comb begin
		case(id_ex_reg.branch_op)
			3'd0 : cond = alu_zero;
			3'd1 : cond = ~alu_zero;
			3'd4 : cond = lt_signed;
			3'd5 : cond = ~lt_signed;
			3'd6 : cond = lt_unsigned;
			3'd7 : cond = ~lt_unsigned;
			default : cond = 1'b0;
		endcase
	end
	assign jump_target = id_ex_reg.jalr ? alu_result : branch_target;
	assign flush = id_ex_reg.jump || (id_ex_reg.branch && cond);

	assign ex_mem_next.alu_result = alu_result;
	assign ex_mem_next.rd_dt2 = fwd_rd_addr2;
	assign ex_mem_next.mem_rd = id_ex_reg.mem_rd;
	assign ex_mem_next.mem_wr = id_ex_reg.mem_wr;
	assign ex_mem_next.reg_wr = id_ex_reg.reg_wr;
	assign ex_mem_next.mem_size = id_ex_reg.mem_size;
	assign ex_mem_next.mem_to_reg = id_ex_reg.mem_to_reg;
	assign ex_mem_next.wr_addr = id_ex_reg.wr_addr;
	assign ex_mem_next.pc_plus4 = id_ex_reg.pc_plus4;
	assign ex_mem_next.imm_out = id_ex_reg.imm_out;

	always_ff @(posedge clk or posedge rst) begin
		if(rst)
			ex_mem_reg <= '0;
		else
			ex_mem_reg <= ex_mem_next;
	end

	always_comb begin
		case(ex_mem_reg.mem_to_reg)
			2'd0 : ex_mem_fwd_val = ex_mem_reg.alu_result;
			2'd2 : ex_mem_fwd_val = ex_mem_reg.pc_plus4;
			2'd3 : ex_mem_fwd_val = ex_mem_reg.imm_out;
			default : ex_mem_fwd_val = ex_mem_reg.alu_result;
		endcase
	end

	always_comb begin
		if(ex_mem_reg.reg_wr && ex_mem_reg.wr_addr != 0 && ex_mem_reg.wr_addr == id_ex_reg.rd_addr1)
			forward_a = 2'd2;
		else if(mem_wb_reg.reg_wr && mem_wb_reg.wr_addr != 0 && mem_wb_reg.wr_addr == id_ex_reg.rd_addr1)
			forward_a = 2'd1;
		else
			forward_a = 2'd0;

		if(ex_mem_reg.reg_wr && ex_mem_reg.wr_addr != 0 && ex_mem_reg.wr_addr == id_ex_reg.rd_addr2)
			forward_b = 2'd2;
		else if(mem_wb_reg.reg_wr && mem_wb_reg.wr_addr != 0 && mem_wb_reg.wr_addr == id_ex_reg.rd_addr2)
			forward_b = 2'd1;
		else
			forward_b = 2'd0;
	end

	always_comb begin
		case(forward_a)
			2'd0 : fwd_rd_addr1 = id_ex_reg.rd_dt1;
			2'd1 : fwd_rd_addr1 = wr_dt;
			2'd2 : fwd_rd_addr1 = ex_mem_fwd_val;
			default : fwd_rd_addr1 = id_ex_reg.rd_dt1;
		endcase

		case(forward_b)
			2'd0 : fwd_rd_addr2 = id_ex_reg.rd_dt2;
			2'd1 : fwd_rd_addr2 = wr_dt;
			2'd2 : fwd_rd_addr2 = ex_mem_fwd_val;
			default : fwd_rd_addr2 = id_ex_reg.rd_dt2;
		endcase
	end

	//Stage 4: Memory
	data_mem data_mem_inst(.clk(clk), .mem_addr(ex_mem_reg.alu_result), .mem_wr_dt(ex_mem_reg.rd_dt2), .mem_wr(ex_mem_reg.mem_wr), .mem_rd(ex_mem_reg.mem_rd), .mem_size(ex_mem_reg.mem_size), .mem_rd_dt(mem_rd_dt));

	assign mem_rd_shifted = mem_rd_dt >> {ex_mem_reg.alu_result[1:0], 3'b000};

	assign mem_wb_next.alu_result = ex_mem_reg.alu_result;
	assign mem_wb_next.pc_plus4 = ex_mem_reg.pc_plus4;
	assign mem_wb_next.imm_out = ex_mem_reg.imm_out;
	assign mem_wb_next.mem_to_reg = ex_mem_reg.mem_to_reg;
	assign mem_wb_next.reg_wr = ex_mem_reg.reg_wr;
	assign mem_wb_next.wr_addr = ex_mem_reg.wr_addr;
	
	always_comb begin
		case(ex_mem_reg.mem_size)
			3'd0 : mem_rd_ext = {{24{mem_rd_shifted[7]}}, mem_rd_shifted[7:0]};
			3'd1 : mem_rd_ext = {{16{mem_rd_shifted[15]}}, mem_rd_shifted[15:0]};
			3'd2 : mem_rd_ext = mem_rd_dt;
			3'd4 : mem_rd_ext = {24'd0, mem_rd_shifted[7:0]};
			3'd5 : mem_rd_ext = {16'd0, mem_rd_shifted[15:0]};
			default : mem_rd_ext = mem_rd_dt;
		endcase
	end

	assign mem_wb_next.mem_rd_dt = mem_rd_ext;

	always_ff @(posedge clk or posedge rst) begin
		if(rst)
			mem_wb_reg <= '0;
		else
			mem_wb_reg <= mem_wb_next;
	end

	//Stage 5: Write-back
	always_comb begin
		case(mem_wb_reg.mem_to_reg)
			2'd0 : wr_dt = mem_wb_reg.alu_result;
			2'd1 : wr_dt = mem_wb_reg.mem_rd_dt;
			2'd2 : wr_dt = mem_wb_reg.pc_plus4;
			2'd3 : wr_dt = mem_wb_reg.imm_out;
			default : wr_dt = mem_wb_reg.alu_result;
		endcase
	end

	//UART
	
	assign uart_dt = wr_dt[7:0];

	logic [23:0] send_timer;
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
		 	send_timer <= '0;
			uart_send <= 1'b0;
		end
		else begin
			send_timer <= send_timer + 1;
			uart_send <= (send_timer == '1) && !uart_busy;
		end	
	end

	uart uart_inst(.clk(clk), .rst(rst), .data(uart_dt), .send(uart_send), .busy(uart_busy), .tx(uart_tx));
	
	assign led = wr_dt[3:0];
endmodule
