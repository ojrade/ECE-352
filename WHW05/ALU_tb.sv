module ALU_tb();

  //////////////////////////////////
  // Define stimulus of type reg //
  ////////////////////////////////
  reg [7:0] A,B;
  reg [1:0] mode;
  reg error;	// set if an error occurred during testing
  
  ////////////////////////////////////////////////////
  // Signals hooked to DUT output are of type wire //
  //////////////////////////////////////////////////
  wire [7:0] result;
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  ALU iDUT(.A(A), .B(B), .mode(mode), .Y(result));
  
  initial begin
    error = 0;		// innocent till proven guilty
	
	$display("Performing mode 00 testing");
    mode = 2'b00;	// start testing subtraction
	A = 8'hAA;
	B = 8'h56;
	#1;
	if (result!==8'h54) begin
	  $display("ERR: 0xAA - 0x56 should result in 0x54.  Your answer was %h",result);
	  error = 1;
	end
	
	B = 8'hAB;
	#1;
	if (result!==8'hFF) begin
	  $display("ERR: 0xAA - 0xAB should result in 0xFF.  Your answer was %h",result);
	  error = 1;
	end
	
	if (!error)
	  $display("Good...you passed mode 00 moving to mode 01 next");
	  
	mode = 2'b01;
	A = 8'h6E;
	#1;
	if (result!==8'hA5) begin
	  $display("ERR: 0x6E*1.5 should result in 0xA5.  Your answer was %h",result);
	  error = 1;
	end	else
	  $display("Good...you passed mode 01 moving to mode 10 next");
	  
	mode = 2'b10;
	A = 8'h95;
	#1;
	if (result!==8'hCA) begin
	  $display("ERR: 0x9E rotated right should result in 0xCA.  Your answer was %h",result);
	  error = 1;
	end	
	A = 8'hA4;
	#1;
	if (result!==8'h52) begin
	  $display("ERR: 0xA4 rotated right should result in 0x52.  Your answer was %h",result);
	  error = 1;
	end

	if (!error)
	  $display("Good...you passed mode 10 moving to mode 11 next");
	  
	mode = 2'b11;
	A = 8'h9C;
	#1;
	if (result!==8'hCE) begin
	  $display("ERR: 0x9C shifted right arithmetically should result in 0xCE.  Your answer was %h",result);
	  error = 1;
	end	
	A = 8'h7D;
	#1;
	if (result!==8'h3E) begin
	  $display("ERR: 0x7D shifted right arithmetically should result in 0x3E.  Your answer was %h",result);
	  error = 1;
	end	

    if (!error)
      $display("YAHOO!! test passed");
    
    $stop();
	
  end
  
endmodule
