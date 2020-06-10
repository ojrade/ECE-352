///////////////////////////////////////////////////////////
// Forms a 5-bit state register that will be one hot.   //
// Meaning it needs to aynchronously reset to 5'b00001 //
////////////////////////////////////////////////////////
module state5_reg(
  input clk,				// clock
  input rst_n,				// asynchronous active low reset
  input [4:0] nxt_state,	// forms next state (i.e. goes to D input of FFs)
  output [4:0] state		// output (current state)
);
  
  ////////////////////////////////////////////////////
  // Declare any needed internal signals.  Due to  //
  // all bits except LSB needed to reset, and the //
  // LSB needing to preset you will need to form //
  // two 5-bit vectors to hook to CLRN and PRN  //
  ///////////////////////////////////////////////
  logic [4:0] clrn_vector;
  logic [4:0] prn_vector;

  
  //////////////////////////////////////////////////////////
  // The two 5-bit vector for CLRN & PRN are formed with //
  // vector concatenation of a mix of rst_n and 1'b1    //
  ///////////////////////////////////////////////////////
  assign clrn_vector = {{4{rst_n}}, 1'b1};
  assign prn_vector = {{4{1'b1}}, rst_n};
  
  ////////////////////////////////////////////////////////
  // instantiate 5 d_ff as a vector to implement state //
  //////////////////////////////////////////////////////
  d_ff states[4:0](.CLK(clk), .D(nxt_state), .CLRN(clrn_vector), .PRN(prn_vector), .Q(state));
  
endmodule