module data_mem(
	input logic clk,
	input logic [31:0] mem_addr,
	input logic [31:0] mem_wr_dt,
	input logic mem_wr,
	input logic mem_rd,
	input logic [2:0] mem_size,

	output logic [31:0] mem_rd_dt
);

	logic [31:0] sig [0:1023];
	logic [3:0] byte_en;
	logic [31:0] wr_dt_shifted;
	string hexfile;
	
	initial begin
		for(int i = 0; i < 1024; i++)
			sig[i] = 32'd0;
		if(!$value$plusargs("HEX=%s", hexfile))
			hexfile = "../programs/test.hex";
		$readmemh(hexfile, sig);
	end
		
	assign mem_rd_dt = mem_rd ? sig[mem_addr[11:2]] : 32'd0;
	assign wr_dt_shifted = mem_wr_dt << {mem_addr[1:0], 3'b000};
	
	always_comb begin
		byte_en = 4'd0;
		case(mem_size)
			3'd0 : begin
					case(mem_addr[1:0])
						2'd0 : byte_en = 4'd1;
						2'd1 : byte_en = 4'd2;
						2'd2 : byte_en = 4'd4;
						2'd3 : byte_en = 4'd8;
					endcase
				end
			3'd1 : begin
					case(mem_addr[1:0])
						2'd0 : byte_en = 4'd3;
						2'd2 : byte_en = 4'd12;
					endcase
				end
			3'd2 : byte_en = 4'd15;
			default : byte_en = 4'd0;
		endcase
	end

			

	always_ff @(posedge clk) begin
		if(mem_wr) begin
			if(byte_en[0])
		 		sig[mem_addr[11:2]][7:0] <= wr_dt_shifted[7:0];
			if(byte_en[1])
				sig[mem_addr[11:2]][15:8] <= wr_dt_shifted[15:8];
			if(byte_en[2])
				sig[mem_addr[11:2]][23:16] <= wr_dt_shifted[23:16];
			if(byte_en[3])
				sig[mem_addr[11:2]][31:24] <= wr_dt_shifted[31:24];
		end			
	end
endmodule
