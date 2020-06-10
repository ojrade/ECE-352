module AHW2_top(SW,LEDR,HEX0,HEX6,HEX7,HEX1,HEX2,HEX3,HEX4,HEX5);

  input [17:0] SW;			// slide switches
  output [17:0] LEDR;		// Red LEDs
  output [6:0] HEX0;		// used to display hex char (0-F)
  output [6:0] HEX6,HEX7;	// used to display 2-digit BCD num
  output [6:0] HEX1,HEX2;	// have to drive off
  output [6:0] HEX3,HEX4;	// have to drive off
  output [6:0] HEX5;		// have to drive off
  
  wire [3:0] upper,lower;	// upper and lower digits of BCD number
  
  ///////////////////////////////////////////////
  // map switches to LEDs for ease of reading //
  /////////////////////////////////////////////
  assign LEDR[17:14] = SW[17:14];
  assign LEDR[3:0] = SW[3:0];
  
  ////////////////////////////////////////////
  // Instantiate hex7seg driven by SW[3:0] //
  //////////////////////////////////////////
  hex7seg iHEX(.nibble(SW[3:0]),.seg(HEX0));
  
  ///////////////////////////////////////////////////////////////
  // Instantiate bin2bcd making two BCD digits from SW[17:14] //
  /////////////////////////////////////////////////////////////
  bin2bcd iDIG(.bin(SW[17:14]),.upper(upper),.lower(lower));
  
  //////////////////////////////////////////////////////////////
  // Instantiate two bcd7seg to drive upper and lower digits //
  ////////////////////////////////////////////////////////////
  bcd7seg iBCD1(.num(upper),.seg(HEX7));
  bcd7seg iBCD2(.num(lower),.seg(HEX6));
  
  ////////////////////////////////////////////////////
  // assigns just to shut other 7-seg displays off //
  //////////////////////////////////////////////////
  assign HEX1 = 7'h7F;
  assign HEX2 = 7'h7F;
  assign HEX3 = 7'h7F;
  assign HEX4 = 7'h7F;
  assign HEX5 = 7'h7F;  
  
  
  
endmodule
  
  