module hex7seg(
  input 	[3:0] nibble,		// a nibble is half a byte
  output	[6:0] seg
);

  assign seg = (nibble==4'b0000) ? 7'h40 :
               (nibble==4'b0001) ? 7'h79 :
               (nibble==4'b0010) ? 7'h24 :
               (nibble==4'b0011) ? 7'h30 :
               (nibble==4'b0100) ? 7'h19 :
               (nibble==4'b0101) ? 7'h12 :
               (nibble==4'b0110) ? 7'h?? :
               (nibble==4'b0111) ? 7'h78 :
               (nibble==4'b1000) ? 7'h00 :
               (nibble==4'b1001) ? 7'h18 :
               (nibble==4'b1010) ? 7'h?? :
               (nibble==4'b1011) ? 7'h?? :
               (nibble==4'b1101) ? 7'h?? :
               (nibble==4'b1110) ? 7'h?? :
               7'h0E;	   

endmodule  