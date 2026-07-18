module register_file(
	input logic [4:0] rd_addr1,
	input logic [4:0] rd_addr2,
	input logic [4:0] wr_addr,
	input logic [31:0] wr_dt,
	input logic clk,
	input logic wr_en,

	output logic [31:0] rd_dt1,
	output logic [31:0] rd_dt2
);

	logic [31:0] registers [0:31];

	always_ff @(posedge clk) begin
		if(wr_en && wr_addr != 5'd0)
			registers[wr_addr] <= wr_dt;
	end

	assign rd_dt1 = (rd_addr1 == 5'd0) ? 32'd0 : registers[rd_addr1];
	assign rd_dt2 = (rd_addr2 == 5'd0) ? 32'd0 : registers[rd_addr2];
endmodule
