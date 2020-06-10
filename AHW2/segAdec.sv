// note that this is NOT a program - it is a hardware description that gets turned into hardware!

module segAdec
(
	input [3:0] D,
	output reg segA
);

always @ (*) begin
	case (D)
	4'h1, 4'h4 : segA = 1'b1; 
	4'h0, 4'h2, 4'h3, 4'h5, 4'h6, 4'h7, 4'h8, 4'h9 : segA = 1'b0; 
	default : segA = 1'bx; 
	endcase
end
endmodule
