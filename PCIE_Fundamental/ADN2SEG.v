module ADN2SEG(output [6:0] hex, input [2:0] indata);
parameter   A_ADN = 3'b001,
				G_ADN = 3'b010,
				T_ADN = 3'b011,
				C_ADN = 3'b100,
				N_ADN = 3'b111;
   assign hex = (indata == A_ADN) ? 7'b0001000 : 
	             (indata == G_ADN) ? 7'b1000010 :
					 (indata == T_ADN) ? 7'b1001110 : 
				    (indata == C_ADN) ? 7'b1000110 :
					 (indata == N_ADN) ? 7'b1001000 : {indata[2],2'b11,indata[1],2'b11,indata[0]}	;
endmodule 