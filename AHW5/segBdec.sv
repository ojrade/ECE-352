module segBdec
(
	input [3:0] D,
	output segB
);

  //////////////////////////////////////////
  // Declare any needed internal signals //
  ////////////////////////////////////////
  logic notD2,D1xnorD0,notSegB;
  
  //////////////////////////////////////////////////////
  // Write STRUCTURAL verilog to implement segment B //
  ////////////////////////////////////////////////////
  not not1(notD2,D[2]);
  xnor xnor1(D1xnorD0,D[0],D[1]);
  or or1(notSegB,D1xnorD0,notD2);
  not not2(segB,notSegB);
  
endmodule
