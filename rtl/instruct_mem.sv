module instruct_mem(
	input logic [31:0] addr,
	output logic [31:0] instruct
);
	logic [31:0] arr [0:31];

	initial begin
		for(int i = 0; i < 32; i++)
			arr[i] = 32'd0;
		$readmemh("../programs/branch.hex", arr);	
	end

	assign instruct = arr[addr[6:2]];
endmodule
