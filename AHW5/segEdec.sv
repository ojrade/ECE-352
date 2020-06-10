module segEdec
(
	input [3:0] D,
	output segE
);

 //////////////////////////////////////////
  // Declare any needed internal signals //
  ////////////////////////////////////////
  logic notD2, notD0, ND2andND0, D1andND0, notSegE;
  
  //////////////////////////////////////////////////////
  // Write STRUCTURAL verilog to implement segment B //
  ////////////////////////////////////////////////////
  not not1(notD0,D[0]);
  not not2(notD2,D[2]);
  and and1(ND2andND0,notD2,notD0);
  and and2(D1andND0,D[1],notD0);
  or or1(notSegE,ND2andND0,D1andND0);
  not not3(segE,notSegE);
  
endmodule
