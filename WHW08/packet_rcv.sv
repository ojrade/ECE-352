module packet_rcv(
	input clk,rst_n,	// clock and asynch active low reset
	input RX,			// receive input line
	output pckt_rdy,	// indicates packet is ready
	output [23:0] pckt
);

	//////////////////////////////////////////////
	// Declare any needed internal signals
	////////////////////////////////////////
	wire byte_rdy;
	wire en_high,en_low;
	wire [7:0] data;

	/////////////////////////////////////////////
	// Instantiate State Machine //
	//////////////////////////////
	packet_SM iSM(.clk(clk),.rst_n(rst_n),.byte_rdy(byte_rdy),
	              .en_high(en_high),.en_low(en_low),.pckt_rdy(pckt_rdy));
				  
	////////////////////////////////////
	// Instantiate holding registers //
	//////////////////////////////////
	holding_reg iHIGH(.clk(clk), .en(en_high), .d_in(data), .d_out(pckt[23:16]));
	holding_reg iLOW(.clk(clk), .en(en_low), .d_in(data), .d_out(pckt[15:8]));
	assign pckt[7:0] = data;
	
	////////////////////////////////
	// Instantiate manchester_RX //
	//////////////////////////////
    manchester_RX iRX(.clk(clk),.rst_n(rst_n),.RX(RX),.data(data),.rdy(byte_rdy));

endmodule


/////////////////////////////////////////
// Implement holding_reg in same file //
///////////////////////////////////////
module holding_reg(clk,en,d_in,d_out);
  input clk,en;
  input [7:0] d_in;
  output reg [7:0] d_out;

  always_ff @(posedge clk)
    if (en)
      d_out <= d_in;

endmodule	  
				  