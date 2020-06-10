///////////////////////////////////////////////////
// Initializes LCD and puts an initial message of:
// "No Data Written" on line1.  One can then specify
// and address (index) and a character to write and
// assert "go".  When the character is written to the
// location "done" is asserted.
// line1 addresses: 0x00 0x01 0x02 .... 0x0F
// line2 addresses: 0x40 0x40 0x42 .... 0x4F
//////////////////////////////////////////////////
module	LCD2x16(	
input	clk,
input	rst_n,
output	[7:0]LCD_DATA,
output	LCD_RW,
output	LCD_EN,
output	LCD_RS,
input   [6:0]index,
input   [7:0]char,
input   go,
output reg done
);

	////	Internal Registers ////
	reg	[4:0]	LUT_INDEX;
	reg	[8:0]	LUT_DATA;
	reg	[3:0]	LCD_ST, nxtLCD_ST;
	reg	[16:0]	mDLY;
	reg [7:0] char_ff;
	reg [6:0] index_ff;

	//// state machine outputs ////
	reg inc_indx;
	reg clr_dly;
	reg capture_char;
	reg			mLCD_Start;
	reg	[7:0]	mLCD_DATA;
	reg			mLCD_RS;

	//// internal nets ////
	wire		mLCD_Done;

	localparam  IDLE 		 = 4'b0000;
	localparam	INIT_SND     = 4'b0001;
	localparam  INIT_WAIT_DN = 4'b0010;
	localparam  INIT_DLY     = 4'b0011;
	localparam  U_WAIT_SND_A = 4'b0100;
	localparam  U_WAIT_DN_A  = 4'b0101;
	localparam  U_DLY_A      = 4'b0110;
	localparam  U_SND_D 	 = 4'b0111;
	localparam  U_WAIT_DN_D  = 4'b1000;
	localparam  U_DLY_D      = 4'b1001;

	always @(posedge clk, negedge rst_n)
	  if (!rst_n)
		LCD_ST <= IDLE;
	  else
		LCD_ST <= nxtLCD_ST;

	always @(posedge clk, negedge rst_n)
	  if (!rst_n)
		LUT_INDEX <= 5'h00;
	  else if (inc_indx)
		LUT_INDEX <= LUT_INDEX + 1;
		
	always @(posedge clk, negedge rst_n)
	  if (!rst_n)
		mDLY <= 17'h00000;
	  else if (clr_dly)
		mDLY <= 17'h00000;
	  else
		mDLY <= mDLY + 1;
		
	always @(posedge clk)
	  if (capture_char) begin
		char_ff <= char;
		index_ff <= index;
	  end

  	//////////////////////////////////////////////
	// State transitions and outputs specified //
	// next as combinational logic with case  //
	///////////////////////////////////////////
	always @(*) begin
	  /////////////////////////
	  // Default SM outputs //
	  ///////////////////////
	  nxtLCD_ST 	= LCD_ST;
	  inc_indx 		= 1'b0;
	  clr_dly 		= 1'b0;
	  mLCD_DATA 	= LUT_DATA[7:0];
	  mLCD_RS 		= LUT_DATA[8];
	  mLCD_Start 	= 1'b0;
	  done 			= 1'b0;
	  capture_char	= 1'b0;
	  
	  case (LCD_ST)
		IDLE : begin
		  if (&mDLY[10:0]) begin
			nxtLCD_ST = INIT_SND;
		  end
		end
		INIT_SND : begin
			mLCD_DATA	=	LUT_DATA[7:0];
			mLCD_RS		=	LUT_DATA[8];
			mLCD_Start	=	1'b1;
			nxtLCD_ST	=	INIT_WAIT_DN;	  
		end
		INIT_WAIT_DN : begin
		  if (mLCD_Done) begin
			clr_dly 	= 1'b1;
			nxtLCD_ST 	= INIT_DLY;
		  end
		end
		INIT_DLY : begin
		  if (&mDLY || (&mDLY[10:0] && (LUT_INDEX!==5'h02))) begin
			if (LUT_INDEX==5'h14)
			  nxtLCD_ST = U_WAIT_SND_A;
			else
			  nxtLCD_ST = INIT_SND;
			inc_indx = 1'b1;
		  end
		end
		U_WAIT_SND_A : begin
		  mLCD_DATA		=	{1'b1,index_ff};
		  mLCD_RS		=	1'b0;		// set address
		  if (go) begin
			mLCD_Start  = 1'b1;
			nxtLCD_ST   = U_WAIT_DN_A;
			capture_char = 1'b1;
		  end
		end
		U_WAIT_DN_A : begin
		  mLCD_DATA		=	{1'b1,index_ff};
		  mLCD_RS		=	1'b0;		// set address	  
		  if (mLCD_Done) begin
			clr_dly = 1'b1;
			nxtLCD_ST 	= U_DLY_A;
		  end
		end
		U_DLY_A : begin
		  if (&mDLY[10:0]) begin
			nxtLCD_ST = U_SND_D;
		  end
		end
		U_SND_D : begin
			mLCD_DATA	=	char_ff;
			mLCD_RS		=	1'b1;
			mLCD_Start	=	1'b1;
			nxtLCD_ST	=	U_WAIT_DN_D;
		end
		U_WAIT_DN_D : begin
		  mLCD_DATA	=	char_ff;
		  mLCD_RS		=	1'b1;
		  if (mLCD_Done) begin
			clr_dly = 1'b1;
			nxtLCD_ST 	= U_DLY_D;
		  end
		end
		default : begin		// this is U_DLY_D
		  if (&mDLY[10:0]) begin
			done = 1'b1;
			nxtLCD_ST = U_WAIT_SND_A;
		  end
		end
	  endcase	
	end	
		
		
	always @(*)
		case(LUT_INDEX)
			 5'h00:	LUT_DATA	=	9'h038;		// 2 display lines
			 5'h01:	LUT_DATA	=	9'h00C;		// display on no cursor no blinking
			 5'h02:	LUT_DATA	=	9'h001;		// clear display
			 5'h03:	LUT_DATA	=	9'h006;		// auto increment
			 5'h04:	LUT_DATA	=	9'h080;		// set address to zero
			 5'h05:	LUT_DATA	=	9'h14E;		//N
			 5'h06:	LUT_DATA	=	9'h16F;		//o
			 5'h07:	LUT_DATA	=	9'h120;		//
			 5'h08:	LUT_DATA	=	9'h144;		//D
			5'h09:	LUT_DATA	=	9'h161;		//a
			5'h0A:	LUT_DATA	=	9'h174;		//t
			5'h0B:	LUT_DATA	=	9'h161;		//a
			5'h0C:	LUT_DATA	=	9'h120;		// 
			5'h0D:	LUT_DATA	=	9'h157;		//W 
			5'h0E:	LUT_DATA	=	9'h172;		//r
			5'h0F:	LUT_DATA	=	9'h169;		//i
			5'h10:	LUT_DATA	=	9'h174;		//t
			5'h11:	LUT_DATA	=	9'h174;		//t
			5'h12:	LUT_DATA	=	9'h165;		//e
			5'h13:	LUT_DATA	=	9'h16E;		//n
			5'h14:	LUT_DATA	=	9'h120;		// 
			default : LUT_DATA = 9'h120;
		endcase	


LCD_Controller 		u0	(	//	Host Side
							.iDATA(mLCD_DATA),
							.iRS(mLCD_RS),
							.iStart(mLCD_Start),
							.oDone(mLCD_Done),
							.iCLK(clk),
							.iRST_N(rst_n),
							//	LCD Interface
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_EN(LCD_EN),
							.LCD_RS(LCD_RS)	);

endmodule


module LCD_Controller (	//	Host Side
						iDATA,iRS,
						iStart,oDone,
						iCLK,iRST_N,
						//	LCD Interface
						LCD_DATA,
						LCD_RW,
						LCD_EN,
						LCD_RS	);
//	CLK
parameter	CLK_Divide	=	16;

//	Host Side
input	[7:0]	iDATA;
input	iRS,iStart;
input	iCLK,iRST_N;
output	reg		oDone;
//	LCD Interface
output	[7:0]	LCD_DATA;
output	reg		LCD_EN;
output			LCD_RW;
output			LCD_RS;
//	Internal Register
reg		[4:0]	Cont;
reg		[1:0]	ST;
reg		preStart,mStart;

/////////////////////////////////////////////
//	Only write to LCD, bypass iRS to LCD_RS
assign	LCD_DATA	=	iDATA; 
assign	LCD_RW		=	1'b0;
assign	LCD_RS		=	iRS;
/////////////////////////////////////////////

always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		oDone	<=	1'b0;
		LCD_EN	<=	1'b0;
		preStart<=	1'b0;
		mStart	<=	1'b0;
		Cont	<=	0;
		ST		<=	0;
	end
	else
	begin
		//////	Input Start Detect ///////
		preStart<=	iStart;
		if({preStart,iStart}==2'b01)
		begin
			mStart	<=	1'b1;
			oDone	<=	1'b0;
		end
		//////////////////////////////////
		if(mStart)
		begin
			case(ST)
			0:	ST	<=	1;	//	Wait Setup
			1:	begin
					LCD_EN	<=	1'b1;
					ST		<=	2;
				end
			2:	begin					
					if(Cont<CLK_Divide)
					Cont	<=	Cont+1;
					else
					ST		<=	3;
				end
			3:	begin
					LCD_EN	<=	1'b0;
					mStart	<=	1'b0;
					oDone	<=	1'b1;
					Cont	<=	0;
					ST		<=	0;
				end
			endcase
		end
	end
end

endmodule
