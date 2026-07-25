module uart
#(parameter int BAUD_DIV = 868)
( 
	input logic clk,
	input logic rst,
	input logic [7:0] data,
	input logic send,

	output logic busy,
	output logic tx	
);

typedef enum logic [1:0]{
	IDLE,
	START,
	DATA,
	STOP
} state_e;

	state_e state;
	logic [7:0] shift_reg;
	logic [2:0] bit_count;
	logic [15:0] baud_count;

	always_ff @(posedge clk or posedge rst) begin 
		if(rst) begin
			state <= IDLE;
			baud_count <= '0;
			bit_count <= '0;
		end
		else begin
			case(state)
				IDLE : begin
					if(send) begin
						shift_reg <= data;
						bit_count <= '0;
						baud_count <= '0;
						state <= START;
					end
				       end
				START : begin
					if(baud_count == BAUD_DIV-1) begin
						baud_count <= '0;
						state <= DATA;
					end
					else
						baud_count <= baud_count + 1;	
					end
				DATA : begin 
					if(baud_count == BAUD_DIV-1) begin
						baud_count <= '0;
					 	shift_reg <= shift_reg >> 1;
						
						if(bit_count == 3'd7)
							state <= STOP;
						else
							bit_count <= bit_count + 1;
						end
					else
						baud_count <= baud_count + 1;	
				       end
				STOP : begin
				       if(baud_count == BAUD_DIV-1) begin 
				       		baud_count <= '0;
						state <= IDLE;
				       end
				       else
					       baud_count <= baud_count + 1;
				       end
			endcase
		end
	end

	assign busy = (state != IDLE);
	assign tx = (state == START) ? 1'b0 : ((state == DATA) ? shift_reg[0] : 1'b1);

endmodule
