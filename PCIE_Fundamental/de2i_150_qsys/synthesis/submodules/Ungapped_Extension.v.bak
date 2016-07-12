`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:44:21 04/22/2015 
// Design Name: 
// Module Name:    Ungapped extension
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
module Ungapped_Extension(com_clk,reset, enable, Q_address_F, S_address_F, Q_context_F, S_context_F,
								Q_address_R, S_address_R, Q_context_R, S_context_R,
								hit_add_inQ_in,hit_add_inS_in, hit_length_in, hit_add_inQ_out,hit_add_inS_out, hit_length_out, hit_add_score);
//		hit_query_location_1, hit_query_location_2, hit_sub_location_1, hit_sub_location_2);
localparam
A = 3'b001,        //nucleotide "A"
G = 3'b010,        //nucleotide "G"
T = 3'b011,        //nucleotide "T"
C = 3'b100;        //nucleotide "C"
parameter LENGTH_CHAR = 3;
parameter LENGTH_COUNTER =8;
parameter LENGTH = 5;
parameter LENGTH_ADDRESS = 16;
parameter LENGTH_HIT_INFO = 22;
parameter MATCH = 2;
parameter MISMATCH = 3;
parameter XDROP_UNGAP = 15;
parameter BUF_WIDTH = 3;
parameter LENGTH_ADN = 128;

input  com_clk, reset, enable;
input [LENGTH_CHAR-1:0] Q_context_F, S_context_F;
input [LENGTH_CHAR-1:0] Q_context_R, S_context_R;
input [LENGTH_COUNTER-1:0] hit_length_in;
input [LENGTH_COUNTER-1:0] hit_add_inQ_in, hit_add_inS_in;

output reg [LENGTH_COUNTER-1:0] Q_address_F, S_address_F;
output reg [LENGTH_COUNTER-1:0] Q_address_R, S_address_R;
output reg [LENGTH_COUNTER-1:0] hit_length_out;
output reg [LENGTH_COUNTER-1:0] hit_add_inQ_out, hit_add_inS_out;
output reg [LENGTH_COUNTER-1:0] hit_add_score;
wire [LENGTH_COUNTER-1:0] hit_length_temp, hit_add_inQ_temp, hit_add_inS_temp;
reg fifo_Un_Ex_wr, fifo_Un_Ex_rd;
wire fifo_Un_Ex_empty, fifo_Un_Ex_full;
reg temp_fifo_Un_Ex_empty = 1, temp_fifo_Un_Ex_empty1 = 1;
wire [BUF_WIDTH-1 :0] fifo_Un_Ex_counter;
reg [LENGTH_COUNTER-1:0] score = 0, score_temp = 0;
reg [LENGTH_COUNTER-1:0] Q_address_F_temp=0, S_address_F_temp=0;
reg [LENGTH_COUNTER-1:0] Q_address_R_temp=0, S_address_R_temp=0;
reg flag_end = 0, flag_end_F = 0, flag_end_R = 0, flag_read = 0;
reg [LENGTH_COUNTER-1:0] counter_F = 0, counter_R = 0;
reg [LENGTH_COUNTER-1:0] counter_end_F = 0, counter_end_R = 0;
reg [LENGTH_COUNTER-1:0] state = 0;

Fifo fifo_Un_Ex(com_clk, reset,hit_add_inS_in, hit_add_inQ_in, hit_length_in, hit_add_inS_temp, hit_add_inQ_temp, hit_length_temp,
			enable, fifo_Un_Ex_rd, fifo_Un_Ex_empty, fifo_Un_Ex_full, fifo_Un_Ex_counter );

always @(posedge com_clk)
begin
	temp_fifo_Un_Ex_empty1 = temp_fifo_Un_Ex_empty;
	temp_fifo_Un_Ex_empty = fifo_Un_Ex_empty;
	if (fifo_Un_Ex_rd == 1) 
		begin 
			fifo_Un_Ex_rd = 0;	
			flag_read = 1;
		end
	else flag_read = 0;
	
		
	// Initial state (Checking for input)
	// Enable receive HSP from FIFO
	if (state == 0)
		begin
		if (((fifo_Un_Ex_empty == 0)||(temp_fifo_Un_Ex_empty ==0) || (temp_fifo_Un_Ex_empty1 == 0)) && (score == 0) && (flag_read ==0) )
			begin
				fifo_Un_Ex_rd = 1;
				score = 255;
				state = 1;				
				flag_end_F = 0;
				flag_end_R = 0;
			end
		hit_add_inQ_out = 0;
		hit_add_inS_out = 0;
		hit_length_out = 0;
		hit_add_score = 0;
		end
	
		//Score is under xdrop, therefore return HSP
	if ((state == 1) || (state == 2) ||(state ==3))
		if (((score < XDROP_UNGAP) &&(score !=0 )) || ((flag_end_R == 1) && (flag_end_F == 1))||(state ==3))
			begin
				hit_add_inQ_out = Q_address_F_temp;
				hit_add_inS_out = S_address_F_temp;
				hit_length_out = Q_address_R_temp - Q_address_F_temp;
				//$display("Q_address_R:", Q_address_R_temp, ".Q_address_F:",Q_address_F_temp);
				hit_add_score = score_temp;
				fifo_Un_Ex_rd = 1;
				score = 0;
				state = 0;
			end	

		
	// HSP is detected
	if (state == 1)
		if (hit_length_temp!=0)
			begin
				 score = (hit_length_temp+1)*MATCH;
				 score_temp = (hit_length_temp+1)*MATCH;
				Q_address_F_temp = hit_add_inQ_temp;
				S_address_F_temp = hit_add_inS_temp;
				Q_address_R_temp = Q_address_F_temp + hit_length_temp;
				S_address_R_temp = S_address_F_temp + hit_length_temp;
				
				//$display("HSP extension: Hit in Q: ", hit_add_inQ_temp,". Hit in S: ", hit_add_inS_temp,". Length: ",hit_length_temp+1,". Score: ", score);
				//$display("HSP extension: Hit in Q_R: ", Q_address_R_temp);
				flag_end = 0;
				flag_end_F = 0;
				flag_end_R = 0;
				counter_end_F = 0;
				counter_end_R = 0;
				fifo_Un_Ex_rd = 0;
				
			
				if ((hit_add_inQ_temp == 0)|| (hit_add_inS_temp == 0))
				begin		
					flag_end_F = 1;
					Q_address_F = hit_add_inQ_temp;
					S_address_F = hit_add_inS_temp;
				end
				else if ((hit_add_inQ_temp == 1) || (hit_add_inS_temp == 1))
				begin						
					score = score-MISMATCH;
					flag_end_F = 1;
					Q_address_F = hit_add_inQ_temp - 1;
					S_address_F = hit_add_inS_temp - 1;
//					if (((score - MATCH) < XDROP_UNGAP) && (hit_add_inQ_temp + hit_length_temp != 63))
//						begin 
//							Q_address_F = Q_address_F + 1;
//							S_address_F = S_address_F + 1;
//							score = score + MISMATCH;
//							state = 3;
//						end
				end
				else 
				begin
					score = score-MISMATCH;
					Q_address_F = hit_add_inQ_temp - 2;
					S_address_F = hit_add_inS_temp - 2;
					flag_end_F = 0;					
					counter_end_F = counter_end_F + 1;
//					if (((score - MATCH) < XDROP_UNGAP) && (hit_add_inQ_temp + hit_length_temp != 63))
//						begin 
//							Q_address_F = Q_address_F + 2;
//							S_address_F = S_address_F + 2;
//							score = score + MISMATCH;
//							state = 3;
//						end
				end
				
				if (state == 1)
					if ((hit_add_inQ_temp + hit_length_temp == (LENGTH_ADN-1)) || (hit_add_inS_temp + hit_length_temp == (LENGTH_ADN-1)))
					begin
						flag_end_R = 1;
						Q_address_R = hit_add_inQ_temp + hit_length_temp;
						S_address_R = hit_add_inS_temp + hit_length_temp;
					end
					else if (hit_add_inQ_temp + hit_length_temp == (LENGTH_ADN-2) || (hit_add_inS_temp + hit_length_temp == (LENGTH_ADN-2)))
					begin 
						score = score-MISMATCH;
						flag_end_R = 1;
						Q_address_R = hit_add_inQ_temp + hit_length_temp + 1;
						S_address_R = hit_add_inS_temp + hit_length_temp + 1;
//						if (score < XDROP_UNGAP)
//							begin 
//								Q_address_R = Q_address_R - 1;
//								S_address_R = S_address_R - 1;
//								score = score + MISMATCH;
//								state = 3;
//							end
					end
					else 
					begin 
						score = score-MISMATCH;
						Q_address_R = hit_add_inQ_temp + hit_length_temp + 2;
						S_address_R = hit_add_inS_temp + hit_length_temp + 2;
						flag_end_R = 0;
						counter_end_R = counter_end_R + 1;
//						if (score < XDROP_UNGAP)
//							begin 
//								Q_address_R = Q_address_R - 2;
//								S_address_R = S_address_R - 2;
//								score = score + MISMATCH;
//								state = 3;
//							end
					end
				else
					begin
						//flag_end_R = 1;
						Q_address_R = hit_add_inQ_temp + hit_length_temp;
						S_address_R = hit_add_inS_temp + hit_length_temp;
					end
				state = 2;
				
				if (score >= score_temp)
				begin
					
					Q_address_F_temp = Q_address_F;
					S_address_F_temp = S_address_F;
					Q_address_R_temp = Q_address_R;
					S_address_R_temp = S_address_R;
					score_temp = score;
				end
			end
	
	
	
	
	//Score is processing for ungap extension
	if (state == 2)
		if ((score !=0 ) && (score != 255) && (flag_end_F == 0) && (0 < Q_context_F) && (6 > Q_context_F ))
			begin
				counter_F = counter_F + 1;
				if (counter_F == 3)
					begin 
						counter_F = 0;
				
						if (Q_context_F == S_context_F)
							begin
								score = score+MATCH;
								counter_end_F = 0;
							end
						else 
						begin
							score = score - MISMATCH;
							if (counter_end_F == 2 ) 
							begin	
								flag_end_F = 1;
								Q_address_F = Q_address_F + 3;
								S_address_F = S_address_F + 3;
								score = score + MISMATCH*3;
								//$display("Reserve 3 chars: HSP extension to Font in Q: ", Q_address_F,"/ Character: ", Q_context_F,". in S: ", S_address_F,"/ Character: ", S_context_F,". Score: ", score,". Score_temp: ", score_temp);
							end
							counter_end_F = counter_end_F + 1;
						
						end
		
						if ((Q_address_F == 0)|| (S_address_F == 0))
						begin		
							flag_end_F = 1;
							//state = 3;
							//Q_address_F = 255;
							//S_address_F = 255;
						end
						else if ((score >= XDROP_UNGAP)&&(flag_end_F!=1))
						begin
							Q_address_F = Q_address_F - 1;
							S_address_F = S_address_F - 1;
							flag_end_F = 0;
						end
//						else 
//						begin 
//								Q_address_F = Q_address_F + 1;
//							S_address_F = S_address_F + 1;
//							score = score + MISMATCH;
//							state = 3;
//							end
					//$display("HSP extension to Font in Q: ", Q_address_F,"/ Character: ", Q_context_F,". in S: ", S_address_F,"/ Character: ", S_context_F,". Score: ", score,". Score_temp: ", score_temp);
					if ((score >= score_temp) && (counter_end_F!=3))
						begin					
						Q_address_F_temp = Q_address_F+1;
						S_address_F_temp = S_address_F+1;
						Q_address_R_temp = Q_address_R;
						S_address_R_temp = S_address_R;
						score_temp = score;
						end
					
						
				end
					
					
				
		
	end
	
	if (state == 2)
		if ((score !=0 ) && (score != 255) && (flag_end_R == 0) && (0 < Q_context_R) && (6 > Q_context_R ))
		begin
			counter_R = counter_R + 1;
			if (counter_R == 3)
			begin
				counter_R = 0;
				if (Q_context_R == S_context_R)
					begin
						score = score + MATCH;
						counter_end_R = 0;
					end
				else 
				begin
					score = score - MISMATCH;
					if (counter_end_R == 2 ) 
							begin	
								flag_end_R = 1;
								Q_address_R = Q_address_R - 3;
								S_address_R = S_address_R - 3;
								score = score + MISMATCH*3;
								//$display("Reserve 3 chars: HSP extension to Rear in Q: ", Q_address_R,"/ Character: ", Q_context_R,". in S: ", S_address_R,"/ Character: ", S_context_R,". Score: ", score);
							end
					counter_end_R = counter_end_R + 1;						
						
				end
		
				if ((Q_address_R == (LENGTH_ADN-1)) || (S_address_R == (LENGTH_ADN-1)))
					begin		
						flag_end_R = 1;
						//state = 3;
						//Q_address_R = 255;
					end
				else if ((score >= XDROP_UNGAP)&& (flag_end_R!=1))
					begin
						Q_address_R = Q_address_R + 1;
						S_address_R = S_address_R + 1;
						flag_end_R = 0;
					end
//				else 				
//					begin 
//						Q_address_R = Q_address_R - 1;
//						S_address_R = S_address_R - 1;
//						score = score + MISMATCH;
//						state = 3;
//					end
				//$display("HSP extension to Rear in Q: ", Q_address_R,"/ Character: ", Q_context_R,". in S: ", S_address_R,"/ Character: ", S_context_R,". Score: ", score);
				if ((score >= score_temp) && (counter_end_R!=3))
					begin					
						Q_address_F_temp = Q_address_F;
						S_address_F_temp = S_address_F;
						Q_address_R_temp = Q_address_R-1;
						S_address_R_temp = S_address_R-1;
						score_temp = score;
						
					end
					
				end
			
		
		end
	
	
		
end
	 
endmodule