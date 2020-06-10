module shft_reg_tb();

  //// declare stimulus as type reg ////
  reg error;
  reg clk;
  reg shft;
  reg shft_in;
  
  wire [7:0] shft_reg;		// hook to shft_reg output of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  shft_reg iDUT(.clk(clk),.shft(shft),.shft_in(shft_in),.shft_reg(shft_reg));
  
  initial begin
    error = 1'b0;		// innocent till proven guilty
    clk = 1'b0;
	shft = 1'b0;
	shft_in = 1'b0;
	
	@(negedge clk);
	if (shft_reg!==8'hxx) begin
	  $display("ERR: at time = %t shft_reg should be uninitialized",$time);
	  error = 1'b1;
	end
	
	shft = 1'b1;
	@(negedge clk);
	if (shft_reg!==8'bxxxxxxx0) begin
	  $display("ERR: at time = %t shft_reg should be 8'bxxxxxxx0",$time);
	  error = 1'b1;
	end	
	
	shft_in = 1'b1;
	@(negedge clk);
	if (shft_reg!==8'bxxxxxx01) begin
	  $display("ERR: at time = %t shft_reg should be 8'bxxxxxx01",$time);
	  error = 1'b1;
	end		

	shft = 1'b0;
	@(negedge clk);
	if (shft_reg!==8'bxxxxxx01) begin
	  $display("ERR: at time = %t shft_reg should still be 8'bxxxxxx01",$time);
	  error = 1'b1;
	end	
	
	shft_in = 1'b0;
	shft = 1'b1;
	@(negedge clk);
	if (shft_reg!==8'bxxxxx010) begin
	  $display("ERR: at time = %t shft_reg should be 8'bxxxxx010",$time);
	  error = 1'b1;
	end	
	
    if (!error)
	  $display("YAHOO! test passed for shft_reg");
	$stop();
  end
  
  always
    #5 clk = ~clk;		// clock start at zero and toggles every 5 time units
  
endmodule