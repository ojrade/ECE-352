module per_capture(
  input clk,				// clock
  input capture,			// when high we capture period_cnt
  input [8:0] period,		// period value to be captured
  output [8:0] per_cap		// captured period register
);
  
    /////////////////////////////////////////////////////
    // instantiate 9 d_en_ff as a vector to implement //
    ///////////////////////////////////////////////////
	d_en_ff denff1[8:0](.CLK(clk),.D(period),.CLRN(1'b1),.EN(capture),.Q(per_cap));
  
endmodule