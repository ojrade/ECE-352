module d_en_ff_tb();

  reg clk,rst_n;		// clock and reset
  reg D_stim;			// input stim to D input
  reg EN_stim;			// input stim to EN input
  reg error;
  
  wire Q;			// Q output of en flop
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  d_en_ff iDUT(.CLK(clk), .D(D_stim), .CLRN(rst_n), .EN(EN_stim), .Q(Q));
						

  initial begin
    error = 1'b0;		// innocent till proven guilty
    clk = 1'b0;
	rst_n = 1'b0;
	D_stim = 1'b1;
	EN_stim = 0;
	@(posedge clk);		// wait for rise of clk
	@(negedge clk);		// deassert reset at fall of clock
	rst_n = 1'b1;		// deasert reset
	if (Q!==1'b0) begin
	  $display("ERR: at time = %t flop is not reset",$time);
	  error = 1'b1;
	end
	
	@(negedge clk);
	if (Q!==1'b0) begin
	  $display("ERR: at time = %t output should still be low, flop not enabled",$time);
	  error = 1'b1;
	end	
	
	@(negedge clk);
	EN_stim = 1'b1;
	@(negedge clk);
	if (Q!==1'b1) begin
	  $display("ERR: at time = %t output should be high",$time);
	  error = 1'b1;
	end		
	
	EN_stim = 1'b0;
	D_stim = 1'b0;
	@(negedge clk);
	if (Q!==1'b1) begin
	  $display("ERR: at time = %t output should have remained high",$time);
	  error = 1'b1;
	end		
	
	EN_stim = 1'b1;
	@(negedge clk);
	if (Q!==1'b0) begin
	  $display("ERR: at time = %t output should returned low",$time);
	  error = 1'b1;
	end		

	if (!error)
	  $display("YAHOO! test passed for d_en_ff");
	$stop();
  end

  //////////////////////////////////////////////////////
  // clock starts low and toggles every 5 time units //
  ////////////////////////////////////////////////////
  always
    #5 clk = ~clk;

endmodule	
					