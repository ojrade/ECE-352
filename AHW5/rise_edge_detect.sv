module rise_edge_detect(
  input clk,			// hook to CLK of flops
  input rst_n,			// hook to PRN
  input sig,			// signal we are detecting a rising edge on
  output sig_rise		// high for 1 clock cycle on rise of sig
);

	//////////////////////////////////////////
	// Declare any needed internal signals //
	////////////////////////////////////////
	logic q1,q2,q3,notQ3;
	
	
	///////////////////////////////////////////////////////
	// Instantiate flops to synchronize and edge detect //
	/////////////////////////////////////////////////////
	d_ff dff1(.CLK(clk),.D(sig),.CLRN(1'b1),.PRN(rst_n),.Q(q1));
	d_ff dff2(.CLK(clk),.D(q1),.CLRN(1'b1),.PRN(rst_n),.Q(q2));
	d_ff dff3(.CLK(clk),.D(q2),.CLRN(1'b1),.PRN(rst_n),.Q(q3));
	
  
	//////////////////////////////////////////////////////////
	// Infer any needed logic (data flow) to form sig_rise //
	////////////////////////////////////////////////////////
	not not1(notQ3,q3);
	and and1(sig_rise,q2,notQ3);
	
endmodule