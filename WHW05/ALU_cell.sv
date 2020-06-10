module ALU_cell(
  input A,			// operand A input bit
  input B,			// operand B input bit
  input Rin,		// input coming from right (from bit of lesser significance)
  input Lin,		// input coming from left (from bit of greater significance)
  input [1:0] mode,	// mode bits
  output Rout,		// output to cell of leser significance
  output Lout,		// output to cell of greater significance
  output Y			// the result output
);

  ///////////////////////////////////////////////////////////////////
  // Declare any needed internal signals as type logic below here //
  /////////////////////////////////////////////////////////////////
  logic BMux, notB;
  
  ///////////////////////////////////////////////////////////////////
  // Instantiate verilog primitives to create any needed internal //
  // signals.  You are allowed to use assign statements only to  //
  // model a simple 2:1 mux structure, otherwise all modeling   //
  // has to be done by instantiation of primitive gates.       //                                    //
  //////////////////////////////////////////////////////////////
  not not1(notB,B);
  assign BMux = (mode[0]==1'b0 ? (notB) :
				(mode[0]==1'b1 ? (Lin) : 1'b0));
  
  ////////////////////////////////////
  // Instance of Full Adder cell   //
  // You need to complete the ??? //
  // connections as you see fit  //
  ////////////////////////////////
  FA iFA(.A(A), .B(BMux), .Cin(Rin), .S(S), .Cout(Lout));

  ////////////////////////////////////////////////////////
  // Instantiate gates or infer with assign statements //
  // simple logic to drive Y output, and Rout output. //
  /////////////////////////////////////////////////////
  //Rout
  assign Rout = A;
  
  //Y
  assign Y = (mode[1]==1'b0 ? (S) :
			 (mode[1]==1'b1 ? (Lin) : 1'b0));
  
endmodule
  
  
/////////////////////////////////////////////////////////////////////////
// Implementation of Full Adder is next.  Don't touch file below here //
///////////////////////////////////////////////////////////////////////
module FA(A,B,Cin,S,Cout);
  
  input A,B,Cin;
  output S,Cout;
  
  assign S = A^B^Cin;
  assign Cout = (A&B) | (A&Cin) | (B&Cin);
  
endmodule
