// note that this is NOT a program - it is a hardware description that gets turned into logic!

module segGdec
(
	input [3:0] D,
	output segG
);

reg [0:15] truth_table = 16'b1100_0001_00xx_xxxx;

assign segG = truth_table[D];

endmodule
