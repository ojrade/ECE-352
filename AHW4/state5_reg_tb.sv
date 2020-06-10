module state5_reg_tb();

  //// declare stimulus as type reg ////
  reg error;
  reg clk;
  reg rst_n;
  
  wire [4:0] nxt_state;
  
  wire [4:0] state;		// hook to state output of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  state5_reg iDUT(.clk(clk),.rst_n(rst_n),.nxt_state(nxt_state),.state(state));
  
  assign nxt_state = {state[3:0],1'b0};
  
  initial begin
    error = 1'b0;		// innocent till proven guilty
    clk = 1'b0;
	rst_n = 1'b1;
	
	@(negedge clk);
	if (state!==5'bxxxx0) begin
	  $display("ERR: at time = %t state should be mainly uninitialized",$time);
	  error = 1'b1;
	end
	#1 rst_n = 1'b0;
	#1;
	if (state!==5'b00001) begin
	  $display("ERR: at time = %t state should be 5'b00001",$time);
	  error = 1'b1;
	end
	
	@(negedge clk);
	rst_n = 1'b1;
	if (state!==5'b00001) begin
	  $display("ERR: at time = %t state should be 5'b00001",$time);
	  error = 1'b1;
	end	
	
	@(negedge clk);
	if (state!==5'b00010) begin
	  $display("ERR: at time = %t state should be 5'b00010",$time);
	  error = 1'b1;
	end	
	
	@(negedge clk);
	if (state!==5'b00100) begin
	  $display("ERR: at time = %t state should be 5'b00100",$time);
	  error = 1'b1;
	end	

	#1 rst_n = 1'b0;
	#1;
	if (state!==5'b00001) begin
	  $display("ERR: at time = %t state should be 5'b00001",$time);
	  error = 1'b1;
	end
	
    if (!error)
	  $display("YAHOO! test passed for state5_reg");
	$stop();
  end
  
  always
    #5 clk = ~clk;		// clock start at zero and toggles every 5 time units
  
endmodule