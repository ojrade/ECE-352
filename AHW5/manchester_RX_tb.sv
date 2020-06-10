module manchester_RX_tb();

  //////////////////////////////////
  // Define stimulus as type reg //
  ////////////////////////////////
  reg error;
  reg clk,rst_n;
  reg [7:0] tx_data;
  reg trmt;
  reg [3:0] baud;			// transmitter bit period
  
  ////////////////////////////////////////////
  // Declare internal signals as type wire //
  //////////////////////////////////////////
  wire TX_RX;
  wire [7:0] rx_data;
  wire rdy;
  
  //////////////////////////////
  // Instantiate transmitter //
  ////////////////////////////
  manchester_TX iTX(.clk(clk),.rst_n(rst_n),.period(baud),
                    .data(tx_data),.trmt(trmt),.done(done),.TX(TX_RX));
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  manchester_RX iDUT(.clk(clk),.rst_n(rst_n),.RX(TX_RX),.data(rx_data),
                    .rdy(rdy));
					
  initial begin
    error = 1'b0;		// innocent till proven guilty
    clk = 1'b0;
	rst_n = 1'b0;
	baud = 4'h7;
	tx_data = 8'hA5;
	trmt = 1'b0;
	
    @(posedge clk);
	@(negedge clk);
	rst_n = 1'b1;		// deassert reset
	
	@(negedge clk);
	trmt = 1'b1;		// transmit first byte
	@(negedge clk);
	trmt = 1'b0;
	
	fork
	  begin: timeout1
	    repeat(2500) @(negedge clk);
		$display("ERR: timed out waiting for rdy");
        error = 1'b1;
		disable wait_rdy1;
	  end
	  begin: wait_rdy1
	    @(posedge rdy);
		disable timeout1;
	  end
	join
	
	if (rx_data !== tx_data) begin
	  $display("ERR: at time = %t rx_data expected to be %h but was %h",$time,tx_data,rx_data);
	  error = 1'b1;
	end
	
	if (error) begin
	  $display("ERR: reception of first byte failed...stopping here");
	  $stop();
	end else
	  $display("GOOD: first byte received...proceeding to 2nd byte test");
	  
	repeat(100) @(negedge clk);
	tx_data = 8'hb4;
	trmt = 1'b1;
	@(negedge clk);
	trmt = 1'b0;
	
	fork
	  begin: timeout2
	    repeat(2500) @(negedge clk);
		$display("ERR: timed out waiting for rdy");
        error = 1'b1;
		disable wait_rdy2;
	  end
	  begin: wait_rdy2
	    @(posedge rdy);
		disable timeout2;
	  end
	join	

	if (rx_data !== tx_data) begin
	  $display("ERR: at time = %t rx_data expected to be %h but was %h",$time,tx_data,rx_data);
	  error = 1'b1;
	end	
	
	if (!error)
	  $display("YAHOO!! test passed");
	$stop();
	
  end
  
  always
    #5 clk = ~clk;

endmodule  
					
  