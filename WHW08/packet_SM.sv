//////////////////////////////////////////////////////
// Implements the packet receiver outlined in WHW08 //
//
// Student 1: Nicholas Hodlofski
// Student 2: N/A
//
///////////////////////////////////////////////////////
module packet_SM(
	input clk,			// 50MHz clock
	input rst_n,		// active low asynch reset
	input byte_rdy,		// asserted for 1 clock when new byte ready on Manchester
	output reg en_high,	// asserted to store byte in the holding register
	output reg en_low,	// asserted to store byte in low holding register
	output reg pckt_rdy // high for 1 clock when full 24-bit data ready
);

	typedef enum reg[2:0] {HIGH=3'b001,MID=3'b010,LOW=3'b100} state_t;
				   
	state_t nxt_state;	// nxt_state is of type state_t

	///////////////////////////////////
	// Declare any internal signals //
	/////////////////////////////////
	logic [2:0] state;		// you need to have a state3_reg
		
    //////////////////////////////////////////////////////////////////
	// Instantiate state flops (copy your state5_reg.sv from AHW4  //
	// to state3_reg.sv and modify it to be state3_reg.sv         //
	// --->>> You need to do this <<<---                         //
	//////////////////////////////////////////////////////////////
	state3_reg iST(.clk(clk),.rst_n(rst_n),.nxt_state(nxt_state),.state(state));
	

	always_comb begin
		/////////////////////////////////////////
		// Default all SM outputs & nxt_state //
		///////////////////////////////////////
		en_high = 1'b0;
		en_low = 1'b0;
		pckt_rdy = 1'b0;
		nxt_state = state_t'(state);

		case (state)
			HIGH: begin
				if (byte_rdy) begin
					nxt_state = MID;
					en_high = 1'b1;
				end
			end
			MID: begin
				if (byte_rdy) begin
					nxt_state = LOW;
					en_low = 1'b1;
				end
			end
			LOW: begin
				if (byte_rdy) begin
					nxt_state = HIGH;
					pckt_rdy = 1;
				end
			end
		endcase // state
	end
		
endmodule	