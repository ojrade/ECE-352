module msg_byte_cnt(
  input clk,				// clock
  input clr_byte_cnt,		// synchronous clear
  input inc_byte_cnt,		// if asserted bit_cnt increments
  output [3:0] msg_byte_cnt		// output of shift register
);
  
  //////////////////////////////////////////
  // Declare any needed internal signals //
  ////////////////////////////////////////
  logic not_clr;
  logic [3:0] next_state;
  
  /////////////////////////////////////////////////////////////////
  // infer 3-bit input vector to bit_cnt regiter that is 3'b000 //
  // if clr is asserted, bit_cnt + 1 if inc is asserted and    //
  // simply bit_cnt (maintains) if neither clr or inc are     //
  // asserted.  Use dataflow.  clr has priority over inc     //
  ////////////////////////////////////////////////////////////
  assign not_clr = ~clr_byte_cnt;
  assign next_state = (clr_byte_cnt == 1'b1) ? 3'b000:
                      (inc_byte_cnt == 1'b1) ? msg_byte_cnt + 1
                                    : msg_byte_cnt;
  
  //////////////////////////////////////////////////////////
  // instantiate 3 d_ff as a vector to implement bit_cnt //
  ////////////////////////////////////////////////////////
  d_ff state[3:0](.CLK(clk), .D(next_state), .CLRN(not_clr), .PRN(1'b1), .Q(msg_byte_cnt));
  
endmodule