module per_cnt_tb();

  //// declare stimulus as type reg ////
  reg error;
  reg clk;
  reg clr_period;
  
  wire [8:0] period;		// hook to period output of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  per_cnt iDUT(.clk(clk),.clr_period(clr_period),.period(period));
  
  initial begin
    error = 1'b0;		// innocent till proven guilty
    clk = 1'b0;
	clr_period = 1'b0;
	@(negedge clk);
	if (period!==9'hxxx) begin
	  $display("ERR: at time = %t period should be uninitialized",$time);
	  error = 1'b1;
	end
	clr_period = 1'b1;
	@(negedge clk);
	if (period!==9'h000) begin
	  $display("ERR: at time = %t period should be 0x000",$time);
	  error = 1'b1;
	end	
	clr_period = 1'b0;
	@(negedge clk);
	if (period!==9'h001) begin
	  $display("ERR: at time = %t period should be 0x001",$time);
	  error = 1'b1;
	end		

	@(negedge clk);
	if (period!==9'h002) begin
	  $display("ERR: at time = %t period should be 0x002",$time);
	  error = 1'b1;
	end		
    if (!error)
	  $display("YAHOO! test passed for per_cnt");
	$stop();
  end
  
  always
    #5 clk = ~clk;		// clock start at zero and toggles every 5 time units
  
endmodule