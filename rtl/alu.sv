module alu(
	input logic [31:0] o1,
	input logic [31:0] o2,
	input logic [2:0] oper,
	output logic [31:0] result	
);

	always_comb begin
		result = 32'd0;
		case(oper)
			3'd0 : result = o1 + o2;
			3'd1 : result = o1 - o2;
			3'd2 : result = o1 & o2;
			3'd3 : result = o1 | o2;
			3'd4 : result = o1 ^ o2;
			3'd5 : result = $signed(o1) < $signed(o2);
		endcase
	end
endmodule
