module manchester_RX(clk,rst_n,RX,data,rdy);

	////////////////////////////////////////////////////////////////
	// Don't even think of copying this code as your solution to //
	// AHW4.  It is written in a different style of verilog and //
	// is deliberately obfuscated to make it near unreadable.  //
	////////////////////////////////////////////////////////////
	input clk;			// 50MHz clock
	input rst_n;		// active low asynch reset
	input RX;			// serial line in
	output reg [7:0] data;	// data we received
	output reg rdy;		// high for 1 clock when data ready

	typedef enum reg[2:0] {S001,S002_L,
	               S003,S004,
				   S005} tse;
				   
	tse st,ns;
	
	logic n001;
	logic n002;
	logic n003;
	logic n004;
	logic n005;

	logic n006;
	logic [2:0] n007;
	logic sr, sf, sig_ff1, sig_ff2, sig_ff3;
	logic [8:0] n008,n009;
	logic n010;
	
	always_ff @(posedge clk, negedge rst_n)
	  if (!rst_n) begin
	    sig_ff1 <= 1'b1;
		sig_ff2 <= 1'b1;
		sig_ff3 <= 1'b1;
	  end
	  else begin
	    sig_ff1 <= RX;
		sig_ff2 <= sig_ff1;
		sig_ff3 <= sig_ff2;
	  end
	
    assign sr = sig_ff2 & ~sig_ff3;
    assign sf = ~sig_ff2 & sig_ff3;
	

	always_ff @(posedge clk)
	  if (n002)
	    n008 <= 9'h000;
	  else
	    n008 <= n008 + 9'h001;
	
	always_ff @(posedge clk)
	  if (n003)
	    n009 <= n008;
		
	assign n006 = (n008==n009) ? 1'b1 : 1'b0;
		
	always_ff @(posedge clk)
	  if (n001)
	    data <= {data[6:0],sig_ff2};
	
	always_ff @(posedge clk)
	  if (n004)
	    n007 <= 3'b000;
	  else if (n005)
	    n007 <= n007 + 3'b001;
		

	assign n010 = &n007;
	
    always_ff @(posedge clk, negedge rst_n)
	  if (!rst_n)
	    st <= S001;
	  else
	    st <= ns;
	

	always_comb begin
		n001 = 1'b0;
		n002 = 1'b0;
		n003 = 1'b0;
		n004 = 1'b0;
		n005 = 1'b0;
		rdy = 1'b0;
		ns = tse'(st);
		
		case (st)
		  S002_L : begin
		    if (sr) begin
			  n003 = 1'b1;
			  ns = S003;
			end
		  end
		  S001: begin
		    n002 = 1'b1;
		    if (sf) begin
			  n004 = 1'b1;
			  ns = S002_L;
		    end
		  end
		  S003 : begin
		    if (sf) begin
			  n002 = 1'b1;
			  ns = S004;
			end
		  end
		  S004 : begin
		    if (n006) begin
  			    n001 = 1'b1;
				ns = S005;
			end	
		  end
		  default : begin	
		    if (sig_ff2) begin
				n005 = 1'b1;
				if (n010) begin
				  rdy = 1'b1;
				  ns = S001;
				end else begin
				  ns = S003;
				end
			end
		  end
		endcase
	end
		
endmodule	