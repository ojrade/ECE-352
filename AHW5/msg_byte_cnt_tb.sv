module msg_byte_cnt_tb();

  //// declare stimulus as type reg ////
  reg error;
  reg clk;
  reg clr;
  reg inc;
  
  wire [3:0] byte_cnt;		// hook to msg_byte_cnt output of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  msg_byte_cnt iDUT(.clk(clk),.clr_byte_cnt(clr),.inc_byte_cnt(inc),.msg_byte_cnt(byte_cnt));
  
  initial begin
    error = 1'b0;		// innocent till proven guilty
    clk = 1'b0;
	clr = 1'b0;
	inc = 1'b0;
	
	@(negedge clk);
	if (byte_cnt!==4'bxxxx) begin
	  $display("ERR: at time = %t byte_cnt should be uninitialized",$time);
	  error = 1'b1;
	end
	
	clr = 1'b1;
	@(negedge clk);
	if (byte_cnt!==4'b0000) begin
	  $display("ERR: at time = %t byte_cnt should be 4'b0000",$time);
	  error = 1'b1;
	end	
	
	clr = 1'b0;
	inc = 1'b1;
	@(negedge clk);
	if (byte_cnt!==4'b0001) begin
	  $display("ERR: at time = %t byte_cnt should be 4'b001",$time);
	  error = 1'b1;
	end		

	inc = 1'b0;
	@(negedge clk);
	if (byte_cnt!==4'b0001) begin
	  $display("ERR: at time = %t byte_cnt should still be 4'b0001",$time);
	  error = 1'b1;
	end	
	
	inc = 1'b1;
	repeat(18)@(negedge clk);
	if (byte_cnt!==4'b0011) begin
	  $display("ERR: at time = %t byte_reg should be 4'b0011",$time);
	  error = 1'b1;
	end	

	clr = 1'b1;
	repeat(10)@(negedge clk);
	if (byte_cnt!==4'b0000) begin
	  $display("ERR: at time = %t byte_reg should be 4'b0000",$time);
	  error = 1'b1;
	end		
	
	
    if (!error)
	  $display("YAHOO! test passed for msg_byte_cnt");
	$stop();
  end
  
  always
    #5 clk = ~clk;		// clock start at zero and toggles every 5 time units
  
endmodule