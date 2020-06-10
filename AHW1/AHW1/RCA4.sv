///////////////////////////////////////////////////////
// RCA4.sv  This design will add two 4-bit vectors  //
// plus a carry in to produce a sum and a carry out//
////////////////////////////////////////////////////
module RCA4(
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
	FA fa0(.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(carry[0]));
	FA fa1(.A(A[1]), .B(B[1]), .Cin(carry[0]), .S(S[1]), .Cout(carry[1]));
	FA fa2(.A(A[2]), .B(B[2]), .Cin(carry[1]), .S(S[2]), .Cout(carry[2]));
	FA fa3(.A(A[3]), .B(B[3]), .Cin(carry[2]), .S(S[3]), .Cout(Cout));

endmodule