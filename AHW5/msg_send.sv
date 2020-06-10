module msg_send(clk,rst_n,msg,snd_msg,tx_data,trmt,nxt_byte);

	input clk,rst_n;			// 50MHz clock and active low asynch reset
	input [3:0] msg;			// which message to send
	input snd_msg;				// kick off SM to send message
	output [7:0] tx_data;		// data byte to send
	output logic trmt;			// tells transmitter to go
	input nxt_byte;				// ready to send next byte
	
	//////////////////////////
	// define states of SM //
	////////////////////////
	typedef enum reg[2:0] {IDLE=3'b001,????=3'b010,????=3'b100} state_t;
				   
	state_t nxt_state;
	
	/////////////////////////////////////////
	// define any needed internal signals //
	///////////////////////////////////////
	logic [3:0] msg_byte_cnt;
	logic [2:0] state;
	
	/////////////////////////
	// declare SM outputs //
	///////////////////////
	????
	
	///////////////////////////////
	// Instantiate msg_byte_cnt //
	/////////////////////////////
	msg_byte_cnt iBYTE(.clk(clk),.clr_byte_cnt(clr_byte_cnt),
	                   .inc_byte_cnt(inc_byte_cnt),.msg_byte_cnt(msg_byte_cnt));
	
	//////////////////////////////
	// Instantiate state flops //
	////////////////////////////
	state3_reg iST(.clk(clk),.rst_n(rst_n),.nxt_state(nxt_state),
	               .state(state));

	//////////////////////////////////////////////
	// State transitions and outputs specified //
	// next as combinational logic with case  //
	///////////////////////////////////////////		
	always_comb begin
	  ///////////////////////////////////////
	  // default SM outputs and nxt_state //
	  /////////////////////////////////////
	  ????
	  nxt_state = state_t'(state);
	  
	  case (state)
		????
	  endcase
	end
	
	
	//////////////////////////////////////////////////////
	// Instantiate msg_ROM                             //
	// address should be formed by {msg,msg_byte_cnt} //
	// output of ROM connected to tx_data            //
	//////////////////////////////////////////////////
	msg_ROM iROM(.addr({msg,msg_byte_cnt}),.tx_data(tx_data));
	  
endmodule
	