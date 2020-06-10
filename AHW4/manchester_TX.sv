module manchester_TX(clk,rst_n,period,data,trmt,done,TX);

	input clk;			// 50MHz clock
	input rst_n;		// active low asynch reset
	input [3:0] period;	// affects TX "baud" rate
	input [7:0] data;	// data we are transmitting
	input trmt;			// tells it to tranmit
	output reg done;	// asserts when we are done
	output reg TX;		// the serial line output

	typedef enum reg[2:0] {IDLE,START_H,START_L,DATA_H,DATA_L} state_t;
	
	/////////////////////////////
	// declare state register //
	///////////////////////////
	state_t state, nxt_state;
	
	////////////////////////////////
	// declare internal regiters //
	//////////////////////////////
	logic [7:0] tx_reg;
	logic [8:0] period_cnt;
	logic [2:0] bit_cnt;
	
	/////////////////////////
	// declare SM outputs //
	///////////////////////
	logic shift;
	logic rst_per;
	logic clr_bit_cnt;
	logic inc_bit_cnt;
	logic set_TX,clr_TX;
	logic set_done;
	
	///////////////////////////////////
	// declare any internal signals //
	/////////////////////////////////
	wire [7:0] per_full, per3_4;
	wire [6:0] per1_2;
	wire [5:0] per1_4;
	
	assign per3_4 = {1'b1,period,2'b00} + {2'b01,period,1'b1};
	assign per1_2 = {1'b1,period,2'b00};
	assign per1_4 = {1'b1,period,1'b0};
	
	///////////////////////////
	// Infer state register //
	/////////////////////////
	always_ff @(posedge clk, negedge rst_n)
	  if (!rst_n)
	    state <= IDLE;
	  else
	    state <= nxt_state;
		
	//////////////////////////////
	// Infer TX shift register //
	////////////////////////////
	always_ff @(posedge clk, negedge rst_n)
	  if (!rst_n)
	    tx_reg = 8'hFF;
	  else if (trmt)
	    tx_reg <= data;
	  else if (shift)
	    tx_reg <= {tx_reg[6:0],1'b1};
		
	///////////////////////////
	// Infer period counter //
	/////////////////////////
	always_ff @(posedge clk)
	  if (rst_per)
	    period_cnt <= 8'h00;
	  else
	    period_cnt <= period_cnt + 8'h01;
		
	////////////////////////
	// Infer bit counter //
	//////////////////////
	always_ff @(posedge clk)
	  if (clr_bit_cnt)
	    bit_cnt <= 3'b000;
	  else if (inc_bit_cnt)
	    bit_cnt <= bit_cnt + 3'b001;

	////////////////////
	// Infer TX flop //
	//////////////////
	always_ff @(posedge clk, negedge rst_n)
	  if (!rst_n)
	    TX <= 1'b1;
	  else if (set_TX)
	    TX <= 1'b1;
	  else if (clr_TX)
	    TX <= 1'b0;
		
	//////////////////////
	// Infer done flop //
	////////////////////
	always_ff @(posedge clk, negedge rst_n)
	  if (!rst_n)
	    done <= 1'b0;
	  else if (set_done)
	    done <= 1'b1;
	  else if (trmt)
	    done <= 1'b0;

	//////////////////////////////////////////////
	// State transitions and outputs specified //
	// next as combinational logic with case  //
	///////////////////////////////////////////		
	always_comb begin
		/////////////////////////////////////////
		// Default all SM outputs & nxt_state //
		///////////////////////////////////////
		shift = 1'b0;
		rst_per = 1'b0;
		clr_bit_cnt = 1'b0;
		inc_bit_cnt = 1'b0;
		set_TX = 1'b0;
		clr_TX = 1'b0;
		set_done = 1'b0;
		nxt_state = state;
		
		case (state)
		  IDLE: begin
		    if (trmt) begin
			  clr_TX = 1'b1;
			  rst_per = 1'b1;
			  nxt_state = START_H;
		    end
		  end
		  START_H : begin
		    if (period_cnt[6:0]==per1_2) begin
			  set_TX = 1'b1;
			  rst_per = 1'b1;
			  nxt_state = START_L;
			end
		  end
		  START_L : begin
		    if (period_cnt[6:0]==per1_2) begin
			  clr_TX = 1'b1;
			  rst_per = 1'b1;
			  clr_bit_cnt = 1'b1;
			  nxt_state = DATA_H;
			end
		  end
		  DATA_H : begin
		    if ((tx_reg[7] && (period_cnt[5:0]==per1_4)) ||
  			    (~tx_reg[7] && (period_cnt==per3_4))) begin
				set_TX = 1'b1;
				rst_per = 1'b1;
				nxt_state = DATA_L;
			end	
		  end
		  default : begin		// this is same as DATA_L
		    if ((tx_reg[7] && (period_cnt==per3_4)) ||
  			    (~tx_reg[7] && (period_cnt[5:0]==per1_4))) begin
				inc_bit_cnt = 1'b1;
				rst_per = 1'b1;
				shift = 1'b1;
				if (bit_cnt==3'b111) begin
				  set_done = 1'b1;
				  nxt_state = IDLE;
				end else begin
				  clr_TX = 1'b1;
				  nxt_state = DATA_H;
				end
			end
		  end
		endcase
	end
		
endmodule	