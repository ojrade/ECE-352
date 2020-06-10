module edge_detect(
  input clk,			// hook to CLK of flops
  input rst_n,			// hook to PRN
  input sig,			// signal we are detecting a rising edge on
  output sig_rise,		// high for 1 clock cycle on rise of sig
  output sig_ff2,       // output of 2nd flip flop
  output sig_fall       // high for 2 clock cycle of fall of sig
);

	//////////////////////////////////////////
	// Declare any needed internal signals //
	////////////////////////////////////////
	logic q1,q2,q3,notQ3,notQ2;
	
	
	///////////////////////////////////////////////////////
	// Instantiate flops to synchronize and edge detect //
	/////////////////////////////////////////////////////
	d_ff dff1(.CLK(clk),.D(sig),.CLRN(1'b1),.PRN(rst_n),.Q(q1));
	d_ff dff2(.CLK(clk),.D(q1),.CLRN(1'b1),.PRN(rst_n),.Q(q2));
	d_ff dff3(.CLK(clk),.D(q2),.CLRN(1'b1),.PRN(rst_n),.Q(q3));
	
  
	//////////////////////////////////////////////////////////
	// Infer any needed logic (data flow) to form sig_rise //
	////////////////////////////////////////////////////////
	//sig_rise
	not not1(notQ3,q3);
	and and1(sig_rise,q2,notQ3);
	
	//sig_fall
	not not2(notQ2,q2);
	and and2(sig_fall,notQ2,q3);
	
	//sig_ff2
	not not3(sig_ff2,notQ2);
	
endmodule