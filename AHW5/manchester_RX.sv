module manchester_RX(clk,rst_n,RX,data,rdy);

	input clk;			// 50MHz clock
	input rst_n;		// active low asynch reset
	input RX;			// serial line in
	output [7:0] data;	// data we received
	output reg rdy;		// high for 1 clock when data ready

	typedef enum reg[4:0] {IDLE=5'b00001,START_L=5'b00010,
	               WAIT_FALL=5'b00100,WAIT_SHF=5'b01000,
				   WAIT_H=5'b10000} state_t;
				   
	state_t nxt_state;
	
	////////////////////////////////////////////////
	// Declare SM outputs (other than rdy) which //
	// is already declared as an output         //
	/////////////////////////////////////////////
	logic shft;
	logic clr_per;
	logic capture_per;
	logic clr_bit_cnt;
	logic inc_bit_cnt;

	///////////////////////////////////
	// Declare any internal signals //
	/////////////////////////////////
	logic per_eq_cap;
	logic [2:0] bit_cnt;
	logic sig_rise, sig_fall, sig_ff2;
	logic [8:0] period,captured_period;
	logic done8;
	logic [4:0] state;
	
	////////////////////////////////
	// Instantiate edge_detector //
	//////////////////////////////
	edge_detect iEDG(.clk(clk),.rst_n(rst_n),.sig(RX),.sig_rise(sig_rise),
	                 .sig_fall(sig_fall),.sig_ff2(sig_ff2));

	
	////////////////////////////
	// per_cnt & per_capture //
	//////////////////////////
	per_cnt iPER(.clk(clk),.clr_period(clr_per),.period(period));
	per_capture iCAP(.clk(clk),.capture(capture_per),.period(period),
	                 .per_cap(captured_period));
	
	//////////////////////////////////////////////////////
	// Infer comparison logic that produces per_eq_cap //
	////////////////////////////////////////////////////
	assign per_eq_cap = (period==captured_period) ? 1'b1 : 1'b0;
	
	
    ////////////////////////////////////
	// Instantiate RX shift register //
	//////////////////////////////////
	shft_reg iSHFT(.clk(clk),.shft(shft),.shft_in(sig_ff2),.shft_reg(data));
	
	//////////////////////////////////////////////////////
	// Instantiate bit_cnt so we know when we are done //
	////////////////////////////////////////////////////
	bit_cnt iBITS(.clk(clk), .clr(clr_bit_cnt), .inc(inc_bit_cnt),
	              .bit_cnt(bit_cnt));
				  
	///////////////////////////////////
	// Infer logic to produce done8 //
	/////////////////////////////////
	assign done8 = &bit_cnt;
	
    //////////////////////////////
	// Instantiate state flops //
	////////////////////////////
	state5_reg iST(.clk(clk),.rst_n(rst_n),.nxt_state(nxt_state),.state(state));
	

	always_comb begin
		/////////////////////////////////////////
		// Default all SM outputs & nxt_state //
		///////////////////////////////////////
		clr_per = 1'b0;
		capture_per = 1'b0;
		clr_bit_cnt = 1'b0;
		inc_bit_cnt = 1'b0;
		shft = 1'b0;
		rdy = 1'b0;
		nxt_state = state_t'(state);
		
		case (state)
		  IDLE: begin
		  	if (sig_fall) begin 
		  		nxt_state = START_L;
		  		clr_per = 1'b1;
		  		clr_bit_cnt = 1'b1;
		  	end
		  end
		  START_L : begin
			if (sig_rise) begin 
				nxt_state = WAIT_FALL;
				capture_per = 1'b1;
			end
		  end
		  WAIT_FALL : begin
			if (sig_fall) begin 
				nxt_state = WAIT_SHF;
				clr_per = 1'b1;
			end
		  end
		  WAIT_SHF : begin
			if (per_eq_cap) begin 
				nxt_state = WAIT_H;
				shft = 1'b1;
			end
		  end
		  default : begin		// this is same as WAIT_H //Still bad practice tho :P
			if (sig_ff2 & ~done8) begin
				nxt_state = WAIT_FALL;
				inc_bit_cnt = 1'b1;
			end
			if (done8) begin
				nxt_state = IDLE;
				rdy = 1'b1;
			end
		  end
		endcase
	end
		
endmodule	