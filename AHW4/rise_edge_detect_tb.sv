module rise_edge_detect_tb();

  reg clk,rst_n;		// clock and reset
  reg sig_stim;			// input stim to edge detect
  reg error;
  
  wire sig_rise;
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  rise_edge_detect iDUT(.clk(clk), .rst_n(rst_n), .sig(sig_stim),
                        .sig_rise(sig_rise));


  initial begin
    error = 1'b0;		// innocent till proven guilty
    clk = 1'b0;
	rst_n = 1'b0;
	sig_stim = 1'b1;
	@(posedge clk);		// wait for rise of clk
	@(negedge clk);		// deassert reset at fall of clock
	rst_n = 1'b1;		// deassert reset
	@(negedge clk);
	sig_stim = 1'b0;
	@(negedge clk);
	sig_stim = 1'b1;
	if (sig_rise==1'b1) begin
	  $display("ERR at time=%t output should not be high yet!\n",$time);
      $display("	Did you preset or reset the flops?");
	  error = 1'b1;
	end	
	@(negedge clk);
	if (sig_rise==1'b1) begin
	  $display("ERR at time=%t output should not be high yet!\n",$time);
      $display("	you should have 2 flops for meta-stability and 3rd for edge detection");
	  error = 1'b1;
	end
	@(negedge clk);
	if (sig_rise!=1'b1) begin
	  $display("ERR at time=%t output should be high",$time);
	  error = 1'b1;
	end
	@(negedge clk);
	sig_stim = 1'b0;
	if (sig_rise==1'b1) begin
	  $display("ERR at time=%t output should not still be high",$time);
	  error = 1'b1;
	end
	if (!error)
	  $display("YAHOO! test passed for rise_edge_detect");
	$stop();
  end

  //////////////////////////////////////////////////////
  // clock starts low and toggles every 5 time units //
  ////////////////////////////////////////////////////
  always
    #5 clk = ~clk;

endmodule	
					