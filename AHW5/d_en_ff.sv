module d_en_ff(
  input CLK,
  input D,	// D input to be flopped
  input CLRN,		// asynch active low clear (reset)
  input EN,			// enable signal
  output logic Q
);

	////////////////////////////////////////////////////
	// Declare any needed internal sigals below here //
	/////////////////////////////////////////////////
	logic MuxOut;
	
	///////////////////////////////////////////////////
	// Infer logic needed to feed D input of simple //
	// flop to form an enabled flop (use dataflow) //
	////////////////////////////////////////////////
	assign MuxOut = (EN==1'b0 ? Q :
					(EN==1'b1 ? D : 1'b0));
	
	//////////////////////////////////////////////
	// Instantiate simple d_ff without enable  //
	// and tie PRN inactive.  Connect D input //    
	// to logic you inferred above.          //
	//////////////////////////////////////////
	d_ff dff2(.CLK(CLK),.D(MuxOut),.CLRN(CLRN),.PRN(1'b1),.Q(Q));

endmodule
