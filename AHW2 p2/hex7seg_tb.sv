module hex7seg_tb();

  reg [4:0] nibble;		// stimulus to DUT
  reg error;			// did an error occur during test?
  reg [6:0] expected_seg;
  
  wire [6:0] seg;		// hooked to output of DUT
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  hex7seg iDUT(.nibble(nibble[3:0]),.seg(seg));
  
  initial begin
    error = 1'b0;		// innocent till proven guilty
	//// rip through all possible values ////
    for (nibble=5'h00; nibble<5'h10; nibble = nibble + 5'h1) begin
	  #5;
	  if (seg!==expected_seg) begin
	    $display("ERR: for num=%d, seg was %b, expected it to be %b",nibble[3:0],seg,expected_seg);
		error = 1'b1;	// guilty
	  end
	end
	if (!error)
	  $display("YAHOO! test for hex7seg passed");
	$stop();
  end
  
  always_comb begin
    case (nibble[3:0])
	  4'b0000 : expected_seg = 7'b1000000;
	  4'b0001 : expected_seg = 7'b1111001;
	  4'b0010 : expected_seg = 7'b0100100;
	  4'b0011 : expected_seg = 7'b0110000;
	  4'b0100 : expected_seg = 7'b0011001;
	  4'b0101 : expected_seg = 7'b0010010;
	  4'b0110 : expected_seg = 7'b0000010;
	  4'b0111 : expected_seg = 7'b1111000;
	  4'b1000 : expected_seg = 7'b0000000;
	  4'b1001 : expected_seg = 7'b0011000;
	  4'b1010 : expected_seg = 7'b0001000;
	  4'b1011 : expected_seg = 7'b0000011;
	  4'b1100 : expected_seg = 7'b0100111;
	  4'b1101 : expected_seg = 7'b0100001;
	  4'b1110 : expected_seg = 7'b0000110;
	  4'b1111 : expected_seg = 7'b0001110;
	  default : expected_seg = 7'bxxxxxxx;
	endcase
  end
  
endmodule