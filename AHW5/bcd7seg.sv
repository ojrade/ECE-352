module bcd7seg(
  input 	[3:0] num,		// BCD number to display
  output	[6:0] seg		// seg[0]=A, seg[1]=B, ...
);

  ////////////////////////////////////////
  // Instantiate the 7 segment drivers //
  //////////////////////////////////////
  segA seg1(.D(num),.segA(seg[0]));
  segB seg2(.D(num),.segA(seg[1]));
  segC seg3(.D(num),.segA(seg[2]));
  segD seg4(.D(num),.segA(seg[3]));
  segE seg5(.D(num),.segA(seg[4]));
  segF seg6(.D(num),.segA(seg[5]));
  segG seg7(.D(num),.segA(seg[6]));

endmodule  
