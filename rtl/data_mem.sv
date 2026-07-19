module data_mem(
	input logic clk,
	input logic [31:0] mem_addr,
	input logic [31:0] mem_wr_dt,
	input logic mem_wr,
	input logic mem_rd,

	output logic [31:0] mem_rd_dt
);

	logic [31:0] sig [0:31];
	initial begin
		for(int i = 0; i < 32; i++)
			sig[i] = 32'd0;
	end
		
	assign mem_rd_dt = mem_rd ? sig[mem_addr[6:2]] : 32'd0;
	

	always_ff @(posedge clk) begin
		if(mem_wr)
			sig[mem_addr[6:2]] <= mem_wr_dt;
	end
endmodule
