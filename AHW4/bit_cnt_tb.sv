module bit_cnt_tb();

  //// declare stimulus as type reg ////
  reg error;
  reg clk;
  reg clr;
  reg inc;
  
  wire [2:0] bit_cnt;		// hook to bit_cnt output of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  bit_cnt iDUT(.clk(clk),.clr(clr),.inc(inc),.bit_cnt(bit_cnt));
  
  initial begin
    error = 1'b0;		// innocent till proven guilty
    clk = 1'b0;
	clr = 1'b0;
	inc = 1'b0;
	
	@(negedge clk);
	if (bit_cnt!==3'bxxx) begin
	  $display("ERR: at time = %t bit_cnt should be uninitialized",$time);
	  error = 1'b1;
	end
	
	clr = 1'b1;
	@(negedge clk);
	if (bit_cnt!==3'b000) begin
	  $display("ERR: at time = %t bit_cnt should be 3'b000",$time);
	  error = 1'b1;
	end	
	
	clr = 1'b0;
	inc = 1'b1;
	@(negedge clk);
	if (bit_cnt!==3'b001) begin
	  $display("ERR: at time = %t bit_cnt should be 3'b001",$time);
	  error = 1'b1;
	end		

	inc = 1'b0;
	@(negedge clk);
	if (bit_cnt!==3'b001) begin
	  $display("ERR: at time = %t bit_cnt should still be 3'b001",$time);
	  error = 1'b1;
	end	
	
	inc = 1'b1;
	repeat(10)@(negedge clk);
	if (bit_cnt!==3'b011) begin
	  $display("ERR: at time = %t bit_reg should be 3'b011",$time);
	  error = 1'b1;
	end	

	clr = 1'b1;
	repeat(10)@(negedge clk);
	if (bit_cnt!==3'b000) begin
	  $display("ERR: at time = %t bit_reg should be 3'b000",$time);
	  error = 1'b1;
	end		
	
	
    if (!error)
	  $display("YAHOO! test passed for bit_cnt");
	$stop();
  end
  
  always
    #5 clk = ~clk;		// clock start at zero and toggles every 5 time units
  
endmodule