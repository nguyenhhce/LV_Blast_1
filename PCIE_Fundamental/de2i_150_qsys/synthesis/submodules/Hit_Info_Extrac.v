`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:44:21 04/22/2015 
// Design Name: 
// Module Name:    Hit_Info_Extrac
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Hit_Info_Extrac(com_clk,offset,query_enable, sub_enable,hits_vector,   hit_add_inQ_out, hit_add_inS_out, enable_Hit_Extrac, hit_length_out, reset);
//		hit_query_location_1, hit_query_location_2, hit_sub_location_1, hit_sub_location_2);
localparam
A = 3'b001,        //nucleotide "A"
G = 3'b010,        //nucleotide "G"
T = 3'b011,        //nucleotide "T"
C = 3'b100;        //nucleotide "C"
parameter LENGTH_CHAR = 3;
parameter LENGTH_COUNTER =8;
parameter LENGTH = 32;
parameter LENGTH_ADDRESS = 16;
parameter LENGTH_HIT_INFO = 22;
parameter NUMBER_ARRAY = 1;

input com_clk, query_enable, sub_enable;
input [LENGTH_COUNTER-1:0] offset;
input [LENGTH_HIT_INFO-1:0] hits_vector;
input reset;
reg [LENGTH_COUNTER-1:0] hit_add_inQ[0:LENGTH_HIT_INFO-1], hit_add_inS[0:LENGTH_HIT_INFO-1];
reg [LENGTH_COUNTER-1:0] hit_lenght[0:LENGTH_HIT_INFO-1];
reg [LENGTH_HIT_INFO-1:0] checked = 0;
reg out_flag = 0;
output wire [LENGTH_COUNTER*LENGTH_HIT_INFO-1:0] hit_length_out;
output wire [LENGTH_COUNTER*LENGTH_HIT_INFO-1:0] hit_add_inQ_out, hit_add_inS_out;
output reg [LENGTH_HIT_INFO-1:0] enable_Hit_Extrac;
reg [LENGTH_COUNTER-1:0] q_id = 8'b11111111, s_id = 8'b11111111;
genvar j;
generate
for (j=0; j < LENGTH_HIT_INFO; j = j + 1)
	begin : ABC
   assign hit_add_inQ_out[j*LENGTH_COUNTER+LENGTH_COUNTER-1:j*LENGTH_COUNTER] = hit_add_inQ[j];
	assign hit_add_inS_out[j*LENGTH_COUNTER+LENGTH_COUNTER-1:j*LENGTH_COUNTER] = hit_add_inS[j];
	assign hit_length_out[j*LENGTH_COUNTER+LENGTH_COUNTER-1:j*LENGTH_COUNTER] = hit_lenght[j];
	end
endgenerate

integer i,k;




always @(posedge com_clk)
begin		
	if (reset == 1)
		begin
			for(i = 0; i < LENGTH_HIT_INFO; i=i+1 )
			begin
				hit_add_inQ[i] = 0;
				hit_add_inS[i] = 0;
				hit_lenght[i] = 0;
				enable_Hit_Extrac[i] = 0;
				checked[i] = 0;
			end
			q_id = 8'b11111111;
			s_id = 8'b11111111;
			out_flag = 0;
		end


	checked = 0;
	enable_Hit_Extrac = 0;
	for(i = 0; i < LENGTH_HIT_INFO; i=i+1 )
		begin
		enable_Hit_Extrac[i] = 0;
		if (hits_vector[i] == 1'b1 && checked[i] == 0)
			begin
				hit_lenght[i] = 10;	
				checked[i] = 1;
				enable_Hit_Extrac[i] = 1;
				hit_add_inQ[i] = 21 - i;
				hit_add_inS[i] = s_id - i - 10 - (offset)*LENGTH;
				//hit_add_inS[i] = s_id - i - 10;
				
				for (k = 1; k  < LENGTH_HIT_INFO;k=k+1)					
						if (((i+k) < LENGTH_HIT_INFO) )							
								if ((hits_vector[i+k] == 1'b1) && (out_flag == 0))
									begin
										hit_lenght[i] = hit_lenght[i] + 1;
										hit_add_inQ[i] = hit_add_inQ[i] - 1;
										hit_add_inS[i] = hit_add_inS[i] - 1;
										checked[i+k] = 1;
									end
								else out_flag = 1;						
						else out_flag = 0;
			end
		end	
		
	if (query_enable == 1)
			begin
				q_id=q_id+1;
				
			end
			
	if (sub_enable == 1)
				begin					
					s_id=s_id+1;
					
				end
	
end

	 
endmodule