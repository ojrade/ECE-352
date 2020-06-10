module per_cnt(
  input clk,				// clock
  input clr_period,			// synchronous clear of period
  output [8:0] period		// output register counts up if not cleared
);
  
    //////////////////////////////////////////
    // Declare any needed internal signals //
    ////////////////////////////////////////
	logic [8:0] inp;
  
    //////////////////////////////////////////////
    // infer 9-bit input vector that is either //
    // 9'h000 or period+1.  Use dataflow      //
    ///////////////////////////////////////////
	assign inp = (clr_period == 1'b0 ? (period+1) :
				 (clr_period == 1'b1 ? 9'h000 : 9'h000));
  
    //////////////////////////////////////////////////
    // instantiate 9 d_ff as a vector to implement //
    ////////////////////////////////////////////////
	d_ff dff[8:0](.CLK(clk),.D(inp),.CLRN(1'b1),.PRN(1'b1),.Q(period));
  
endmodule