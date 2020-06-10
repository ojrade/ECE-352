module packet_rcv_tb();

  ///////////////////////////////////
  // Declare stimulus as type reg //
  /////////////////////////////////
  reg clk,rst_n;
  reg [7:0] tx_data;
  reg trmt;
  reg error;
  
  ///////////////////////////////////////////////////
  // Internal signals and DUT output to type wire //
  /////////////////////////////////////////////////
  wire TX_RX;
  wire [23:0] pckt;
  wire pckt_rdy;
  wire tx_done;
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  packet_rcv iDUT(.clk(clk),.rst_n(rst_n),.RX(TX_RX),.pckt_rdy(pckt_rdy),.pckt(pckt));
  
  ///////////////////////////////////////////////////////////
  // Instantiate Manchester transmitter to aid in testing //
  /////////////////////////////////////////////////////////
  manchester_TX iTX(.clk(clk),.rst_n(rst_n),.period(4'b1000),.data(tx_data),
                    .trmt(trmt),.done(tx_done),.TX(TX_RX));
					
 
  initial begin
    clk = 0;
	rst_n = 0;
	error = 0;
	@(posedge clk);
	@(negedge clk);
	rst_n = 1;
		
	tx_data = 8'hBE;
	trmt = 1;
	@(negedge clk);
	trmt = 0;
		
	@(posedge tx_done);
	repeat(100) @(negedge clk);
	
	tx_data = 8'hF0;
	trmt = 1;
	@(negedge clk);
	trmt = 0;

	@(posedge tx_done);
	repeat(100) @(negedge clk);

	tx_data = 8'h0D;
	trmt = 1;
	@(negedge clk);
	trmt = 0;
	
    fork
	  begin : timeout
	    repeat(2000) @(posedge clk);
		$display("ERR: Expected pckt_rdy by now");
		error = 1;
		disable wait_rdy;
	  end
	  begin : wait_rdy
	    @(posedge pckt_rdy);
		disable timeout;
	  end
	join
	
	if (pckt!==24'hBEF00D) begin
	  $display("ERR : Expected pckt to 0xBEFOOD");
	  error = 1;
	end
	
	if (!error)
	  $display("YAHOO! test passed!");
	  
	$stop();
	
  end
  
  always
    #5 clk = ~clk;
	
endmodule