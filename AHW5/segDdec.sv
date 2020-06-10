// note that this is NOT a program - it is a hardware description that gets turned into logic!

module segDdec
(
	input [3:0] D,
	output segD
);

reg [0:15] truth_table = 16'b0100_1001_01xx_xxxx;

assign segD = truth_table[D];

endmodule
