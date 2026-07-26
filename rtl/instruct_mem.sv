module instruct_mem(
	input logic clk,
	input logic en,
	input logic [31:0] addr,
	output logic [31:0] instruct
);
	logic [31:0] arr [0:1023];
`ifndef SYNTHESIS
	string hexfile;
`endif

	initial begin
		for(int i = 0; i < 1024; i++)
			arr[i] = 32'd0;
`ifdef SYNTHESIS
		$readmemh("C:/riscv-fpga/program.hex", arr);
`else
		if (!$value$plusargs("HEX=%s", hexfile))
			hexfile = "../programs/test.hex";
		$readmemh(hexfile, arr);	
`endif
	end
	always_ff @(posedge clk) begin 
		if(en)
			instruct <= arr[addr[11:2]];
	end
endmodule
