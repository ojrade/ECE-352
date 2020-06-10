module per_capture_tb();

  //// declare stimulus as type reg ////
  reg error;
  reg clk;
  reg [8:0] period;
  reg capture;
  
  wire [8:0] per_cap;		// hook to captured period output of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  per_capture iDUT(.clk(clk),.capture(capture),.period(period),
                   .per_cap(per_cap));
  
  
  initial begin
    error = 1'b0;		// innocent till proven guilty
    clk = 1'b0;
	period = 9'h1A5;
	@(negedge clk);
	if (per_cap!==9'hxxx) begin
	  $display("ERR: at time = %t per_cap should be uninitialized",$time);
	  error = 1'b1;
	end
	capture = 1'b1;
	@(negedge clk);
	if (per_cap!==9'h1A5) begin
	  $display("ERR: at time = %t per_cap should be 0x1A5",$time);
	  error = 1'b1;
	end	
	capture = 1'b0;
	period = 9'h0A0;
	@(negedge clk);
	if (per_cap!==9'h1A5) begin
	  $display("ERR: at time = %t per_cap should still be 0x1A5",$time);
	  error = 1'b1;
	end		
	capture = 1'b1;
	@(negedge clk);
	if (per_cap!==9'h0A0) begin
	  $display("ERR: at time = %t per_cap should be 0x0A0",$time);
	  error = 1'b1;
	end		
    if (!error)
	  $display("YAHOO! test passed for per_capture");
	$stop();
  end
  
  always
    #5 clk = ~clk;		// clock start at zero and toggles every 5 time units
  
endmodule