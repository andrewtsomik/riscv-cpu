module instruct_mem(
	input logic [31:0] addr,
	output logic [31:0] instruct
);
	logic [31:0] arr [0:1023];
	string hexfile;

	initial begin
		for(int i = 0; i < 1024; i++)
			arr[i] = 32'd0;
		if (!$value$plusargs("HEX=%s", hexfile))
			hexfile = "..programs/test.hex";
		$readmemh(hexfile, arr);	
	end

	assign instruct = arr[addr[11:2]];
endmodule
