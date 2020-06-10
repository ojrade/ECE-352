module bin2bcd_tb();

  reg [4:0] bin_stim;	// stimulus applied to bin2bcd_tb
  reg error;			// has an error occurred?
  
  wire [3:0] upper,lower;	// hooked to output of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  bin2bcd iDUT(.bin(bin_stim[3:0]),.upper(upper),.lower(lower));
  
  initial begin
    error = 1'b0;	// innocent till proven guilty
    for (bin_stim=5'h00; bin_stim<5'h10; bin_stim=bin_stim+5'h01) begin
	  #5;
	  if (bin_stim>5'h09) begin
	  	if (lower!==(bin_stim[3:0]+4'b0110)) begin
		  $display("ERR: lower is %b but should be %b",lower,bin_stim[3:0]+4'b0110);
		  error=1'b1;
		end
		if (upper!=4'b0001) begin
		  $display("ERR: upper is %b but should be 4'b0001",upper);
		  error=1'b1;
		end
	  end else begin
	    if (lower!==bin_stim[3:0]) begin
		  $display("ERR: lower is %b but should be %b",lower,bin_stim[3:0]);
		  error=1'b1;
		end
		if (upper!=4'b0000) begin
		  $display("ERR: upper is %b but should be zero",upper);
		  error=1'b1;
		end
	  end
	end
	if (!error)
	  $display("YAHOO! test for bcd2bin passed");
	$stop();
  end
  
endmodule

  