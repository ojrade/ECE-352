module AHW5_top(
	input 		          		clk,
	input						rst_n,			// SW[0]
	output		     			RST_indicate,	// LEDR[0]
	output		    [3:0]		per_indicate,	// LEDR[17:14]
	output			[3:0]		msg_indicate,	// LEDR[13:10]
	input						snd,			// KEY[0]
	output						snd_indicate,	// LEDG[0]
	//////////// EX_IO //////////
	output 		    			TX,		// EX_IO[0]
	input						RX,		// EX_IO[6]
	input			[3:0]		period,	// SW[17:14] form period
	input			[3:0]		msg,	// SW[13:10] form message
	
	output			[5:0] 		status,	// LEDG[7:1] can be used for debug

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,
	output		     [6:0]		HEX6,
	output		     [6:0]		HEX7,
	//////////// LCD //////////
	output		          		LCD_BLON,
	output 		     [7:0]		LCD_DATA,
	output		          		LCD_EN,
	output		          		LCD_ON,
	output		          		LCD_RS,
	output		          		LCD_RW
);

  /////////////////////////////////
  // Declare internal registers //
  ///////////////////////////////

  //// internal nets ////
  wire snd_released;
  wire lcd_done;
  wire lcd_go;
  wire [3:0] index;
  wire TX_done;
  wire RX_rdy;
  wire [7:0] RX_data;
  wire [7:0] TX_data;
  wire trmt;
  wire [3:0] MSGH,MSGL,PERH,PERL;


  ///////////////////////
  // assign constants //
  /////////////////////
  assign LCD_ON = 1'b1;
  assign RST_indicate = rst_n;	// LEDR[0] will indicate reset position
  assign per_indicate = period;	// LEDR[17:14] will indicate period
  assign msg_indicate = msg;	// LEDR[13:10] will indicate message selected
  assign snd_indicate = ~snd;	// LEDG[0] will indicate when send button pushed

  
  ///////////////////////////////////////////////////////
  // Instantiate  rise_edge_detect for key0 PB (send) //
  /////////////////////////////////////////////////////
  rise_edge_detect iKEY0(.clk(clk),.rst_n(rst_n),.sig(snd),.sig_rise(snd_released));


/////////////////////////////////////////////////////////
// Instantiate hex7seg drivers to show last character // 
// received and next character to send.              //
//////////////////////////////////////////////////////
hex7seg iTXL(.nibble(TX_data[3:0]),.seg(HEX0));
hex7seg iTXH(.nibble(TX_data[7:4]),.seg(HEX1));
hex7seg iRXL(.nibble(RX_data[3:0]),.seg(HEX2));
hex7seg iRXH(.nibble(RX_data[7:4]),.seg(HEX3));

  //////////////////////////////////////////////////
  // Instantiate bin to BCD decoders and dec7seg // 
  // drivers to show msg and period numbers     //
  // number and period (baud) numner           //
  //////////////////////////////////////////////
  bin2bcd iBCDM(.bin(msg),.upper(MSGH),.lower(MSGL));
  bin2bcd iBCDP(.bin(period),.upper(PERH),.lower(PERL));

  ////////////////////////////////////////////////////////
  // Message number is shown as decimal on {HEX5,HEX4} //
  //////////////////////////////////////////////////////
  bcd7seg iMSGL(.num(MSGL),.seg(HEX4));
  bcd7seg iMSGH(.num(MSGH),.seg(HEX5));
  ////////////////////////////////////////////////
  // Period is shown as decimal on {HEX7,HEX6} //
  //////////////////////////////////////////////
  bcd7seg iPERL(.num(PERL),.seg(HEX6));
  bcd7seg iPERH(.num(PERH),.seg(HEX7));
	
  ////////////////////////////////	
  // Instantiate manchester RX //
  //////////////////////////////				  
  manchester_RX iRX(.clk(clk),.rst_n(rst_n),.RX(RX),.data(RX_data),.rdy(RX_rdy));

  /////////////////////////////
  // Instantiate LCD writer //
  /////////////////////////////////////////////////////////////////////////////
  // This unit is kicked off by the reception of a new character from the   //
  // manchester_RX (RX_rdy).  It then kicks off (asserts "go") the LCD2x16 //
  // unit to write a character to location "index".  When the LCD2x16 is  //
  // done it asserts lcd_done. This unit is provided for you.            //                                          //
  ////////////////////////////////////////////////////////////////////////
  LCD_write iWRT(.clk(clk),.rst_n(rst_n),.RX_rdy(RX_rdy),.index(index),
                 .go(lcd_go),.lcd_done(lcd_done));
				 
  /////////////////////////////////
  // Instantiate LCD Controller //
  ///////////////////////////////
  LCD2x16 iLCD(.clk(clk),.rst_n(rst_n),.LCD_DATA(LCD_DATA),.LCD_RW(LCD_RW),
	           .LCD_EN(LCD_EN),.LCD_RS(LCD_RS),.index({3'b000,index}),
			   .char(RX_data),.go(lcd_go),.done(lcd_done));


  ////////////////////////////////	
  // Instantiate manchester TX //
  //////////////////////////////
  manchester_TX iTX(.clk(clk),.rst_n(rst_n),.period(period),.data(TX_data),
                    .trmt(trmt), .done(TX_done), .TX(TX));
				  
  //////////////////////////////////////////////////////////////
  // Instantiate block that sends messages via manchester_TX //
  ////////////////////////////////////////////////////////////////
  // When snd_msg is asserted (KEY[0] released) this unit will //
  // start sending the 16 characaters of the selected message //
  // via the manchester_TX block.  It needs to wait for each //
  // character to be displayed on the LCD before proceeding //
  // to the next character to send. You create this block. //
  //////////////////////////////////////////////////////////
  msg_send iMSG(.clk(clk),.rst_n(rst_n),.msg(msg),.snd_msg(snd_released),
                .tx_data(TX_data),.trmt(trmt),.nxt_byte(lcd_done));		 

endmodule
