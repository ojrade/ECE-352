module LCD_write(clk,rst_n,RX_rdy,index,go,lcd_done,debug);

	input clk,rst_n;		// 50MHz clock and active low asynch reset
	input RX_rdy;			// new byte received from manchester_rx
	output reg [3:0] index;	// address of LCD char to write to
	output reg go;			// tells LCD driver to write character
	output [5:0] debug;		// maps to bits [7:2] of green LEDs
	input lcd_done;			// indicates LCD driver done writing character
	
	////////////////////
	// Define states //
	//////////////////
	typedef enum reg[1:0] {IDLE,WAIT_SND,SND_NXT} state_t;
	state_t state, nxt_state;
	
	assign debug = {index,state};	// map to whatever you like to help debug
	
	/////////////////////////
	// Declare SM outputs //
	///////////////////////
	logic clr_indx, inc_indx;
	
	////////////////////////////////
	// infer index (LCD address) //
	//////////////////////////////
	always_ff @(posedge clk)
	  if (clr_indx)
	    index <= 4'b0000;
	  else if (inc_indx)
	    index <= index + 4'b0001;
		
	////////////////////////
	// Infer state flops //
	//////////////////////
	always_ff @(posedge clk, negedge rst_n)
	  if (!rst_n)
	    state <= IDLE;
	  else
	    state <= nxt_state;
		
	//////////////////////////////////////////////
	// State transitions and outputs specified //
	// next as combinational logic with case  //
	///////////////////////////////////////////
	always_comb begin
	  ///////////////////////////////////////
	  // default SM outputs and nxt_state //
	  /////////////////////////////////////
	  clr_indx = 1'b0;
	  inc_indx = 1'b0;
	  go = 1'b0;
	  nxt_state = state;
	  
	  case (state)
	    IDLE : begin
		  clr_indx = 1'b1;
		  if (RX_rdy) begin
		    go = 1'b1;
			nxt_state = WAIT_SND;
		  end
		end
		WAIT_SND : begin
		  if (lcd_done) begin
		    if (&index)
			  nxt_state = IDLE;
			else begin
			  inc_indx = 1'b1;
			  nxt_state = SND_NXT;
			end
		  end
		end
		SND_NXT : begin
		  if (RX_rdy) begin
		    go = 1'b1;
		    nxt_state = WAIT_SND;
		  end
		end
	  endcase
	end
	
	
endmodule