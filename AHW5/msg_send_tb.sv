module msg_send_tb();

  ///////////////////////////////////
  // declare stimulus of type reg //
  /////////////////////////////////
  reg clk,rst_n;		// 50MHz clock and async active low reset
  reg snd_msg;			// kicks off set (would be hooked to push button)
  reg nxt_byte;			// system is ready for the next byte of the message
  reg [3:0] msg_num;	// number (0 to 15) of message string to send
  reg error;			// holds if an error occurred during test bench
  reg [3:0] x;			// used in loop counter

  //////////////////////////////////////////
  // declare any needed internal signals //
  ////////////////////////////////////////
  wire trmt;
  wire [7:0] tx_data;
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  msg_send iDUT(.clk(clk),.rst_n(rst_n),.msg(msg_num),.snd_msg(snd_msg),
                .tx_data(tx_data),.trmt(trmt),.nxt_byte(nxt_byte));
  
  always begin
    error = 1'b0;		// innocent till proven guilty
	clk = 1'b0;
	rst_n = 1'b0;
	msg_num = 4'b0000;
	nxt_byte = 1'b0;
	snd_msg = 1'b0;
	
	@(posedge clk);
	@(negedge clk);
	rst_n = 1'b1;		// deassert reset
	
	@(negedge clk);
	snd_msg = 1'b1;		// initiate send of first message
	
	#1;
	if (!trmt) begin
	  $display("ERR: trmt should be asserted at time = %t",$time);
	  error = 1'b1;
	end
        @(negedge clk);
	if (tx_data!==8'h45) begin
	  $display("ERR: tx_data should be 0x45 at time = %t",$time);
	  error = 1'b1;
	end	
	  
	@(negedge clk);
	snd_msg = 1'b0;
	
	repeat(10) @(negedge clk);
	/// mimic that 1st byte has been consumed ///
	nxt_byte = 1'b1;
	@(negedge clk);
	nxt_byte = 1'b0;
        @(negedge clk);
	if (tx_data!==8'h43) begin
	  $display("ERR: tx_data should be 0x43 at time = %t, was %h",$time,tx_data);
	  error = 1'b1;
	end	
	
	
	/// Now do it 14 more times ///
	for (x=4'd0; x<4'd14; x = x + 4'd1) begin
	  repeat(10) @(negedge clk);
	  /// mimic that 1st byte has been consumed ///
	  nxt_byte = 1'b1;
	  @(negedge clk);
	  nxt_byte = 1'b0;	
	end
	
	/// All bytes should have been transmitted now ///
	
	repeat(15) @(negedge clk);
	/// mimic that 1st byte has been consumed ///
	nxt_byte = 1'b1;
	@(negedge clk);
	nxt_byte = 1'b0;	
	if (trmt) begin
	  $display("ERR: trmt should NOT be asserted at time = %t",$time);
	  error = 1'b1;
	end	
	@(negedge clk);
	
	if (!error)
	  $display("YAHOO!! test passed for msg_send!");
	$stop();
  end
  
  always
    #5 clk = ~clk;
	
endmodule