///////////////////////////////////////////////////////
// RCA4.sv  This design will add two 4-bit vectors  //
// plus a carry in to produce a sum and a carry out//
////////////////////////////////////////////////////
module RCA4_smarter(
  input 	[3:0]	A,B,	// two 4-bit vectors to be added
  input 		Cin,	// An optional carry in bit
  output 	[3:0]	S,	// 4-bit Sum
  output 		Cout  	// and carry out
);

	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	logic [2:0] carry;
	
	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	FA fa[3:0](A, B, Cin, S, Cout);
	
endmodule