module AHW4_top(clk,SW,KEY,LEDR,HEX0,HEX6,HEX7,HEX1,HEX2,HEX3,HEX4,HEX5,TX,RX);

  input clk;				// 50MHz clock
  input [17:0] SW;			// slide switches
  input [3:0] KEY;			// push buttons
  input RX;					// input to receiver (loop wire to TX)
  output [17:0] LEDR;		// Red LEDs
  output [6:0] HEX5,HEX4;	// used to display hex char to transmit
  output [6:0] HEX7,HEX6;	// used to display hex character received
  output [6:0] HEX3,HEX2;	// have to drive off
  output [6:0] HEX1,HEX0;	// have to drive off
  output TX;				// driven by transmitter
  
  wire rst_n;				// global reset
  wire [7:0] rx_data;
  wire key0_rel;
  
  assign rst_n = SW[0];		// SW[0] forms rst_n
  
  /// mimic switch positions on LEDs to make reading easier ///
  assign LEDR[17:10] = SW[17:10];
  
  /////////////////////////////////////////////////////////////
  // Instantiate transmitter driven by SW[17:10] and KEY[0] //
  ///////////////////////////////////////////////////////////
  manchester_TX iTX(.clk(clk),.rst_n(rst_n),.period(4'b1010),.data(SW[17:10]),
                    .trmt(key0_rel),.done(),.TX(TX));
				
  //////////////////////////////////////////////////////////////
  // Instantiate receiver which drives {HEX7,HEX6} with data //
  ////////////////////////////////////////////////////////////
  manchester_RX iRX(.clk(clk),.rst_n(rst_n),.RX(RX),.data(rx_data),.rdy());		

  ////////////////////////////////////////////////
  // Instantiate  rise_edge_detect for key0 PB //
  //////////////////////////////////////////////
  rise_edge_detect iKEY0(.clk(clk),.rst_n(rst_n),.sig(KEY[0]),.sig_rise(key0_rel));

  //////////////////////////////////////////////////////////////////
  // instantiate 4 of hex7seg to drive {HEX7,HEX6} & {HEX5,HEX4} //
  ////////////////////////////////////////////////////////////////
  hex7seg iHEX7(.nibble(rx_data[7:4]),.seg(HEX7));
  hex7seg iHEX6(.nibble(rx_data[3:0]),.seg(HEX6));
  hex7seg iHEX5(.nibble(SW[17:14]),.seg(HEX5));
  hex7seg iHEX4(.nibble(SW[13:10]),.seg(HEX4));
  

  ////////////////////////////////////////////////////
  // assigns just to shut other 7-seg displays off //
  //////////////////////////////////////////////////
  assign HEX3 = 7'h7F;
  assign HEX2 = 7'h7F;
  assign HEX1 = 7'h7F;
  assign HEX0 = 7'h7F;
  
endmodule
  
  