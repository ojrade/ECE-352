module shft_reg(
  input clk,				// clock
  input shft,				// synchronous shift to left
  input shft_in,			// bit shifted in
  output [7:0] shft_reg		// output of shift register
);
  
  //////////////////////////////////////////
  // Declare any needed internal signals //
  ////////////////////////////////////////
  logic [7:0] out_shifted;
  
  ////////////////////////////////////////////////////////////////
  // infer 8-bit input vector to shft regiter that is the left //
  // shifted version of shft_reg with shft_in coming in.      //
  /////////////////////////////////////////////////////////////
  assign out_shifted = {shft_reg[6:0], shft_in};
  
  //////////////////////////////////////////////////////////////
  // instantiate 8 d_en_ff as a vector to implement shft_reg //
  ////////////////////////////////////////////////////////////
  d_en_ff ffs[7:0](.CLK(clk), .D(out_shifted) , .CLRN(1'b1), .EN(shft), .Q(shft_reg));
  
endmodule