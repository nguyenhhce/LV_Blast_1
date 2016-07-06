`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:44:21 04/22/2015 
// Design Name: 
// Module Name:    Blastn_Array
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
module Blastn_Array(array_clk, query_enable, sub_enable, reset, read_HSP,
						Q_address_F, S_address_F, Q_context_F, S_context_F,
						Q_address_R, S_address_R, Q_context_R, S_context_R,
//						Q_valid_F, S_valid_F, Q_valid_R, S_valid_R,
						query_datastream_in, sub_datastream_in, query_datastream_out, sub_datastream_out,
						hit_add_inQ_UnGap, hit_add_inS_UnGap, hit_length_UnGap, hit_add_score,FIFO_empty);
localparam
A = 3'b001,        //nucleotide "A"
G = 3'b010,        //nucleotide "G"
T = 3'b011,        //nucleotide "T"
C = 3'b100;        //nucleotide "C"
parameter LENGTH_CHAR = 3;
parameter LENGTH_2BYTES = 8;
parameter LENGTH_COUNTER = 8;
parameter MAX_ARRAY = 4;
parameter LENGTH = 32;
parameter LENGTH_ADDRESS = 16;
parameter LENGTH_HIT_INFO = 22;

input array_clk, query_enable, sub_enable;
input reset, read_HSP;
input [LENGTH_CHAR-1:0] query_datastream_in, sub_datastream_in;
input [LENGTH_CHAR*MAX_ARRAY-1:0] Q_context_F, S_context_F;
input [LENGTH_CHAR*MAX_ARRAY-1:0] Q_context_R, S_context_R;
output [LENGTH_COUNTER*MAX_ARRAY-1:0] Q_address_F, S_address_F;
output [LENGTH_COUNTER*MAX_ARRAY-1:0] Q_address_R, S_address_R;

output [LENGTH_CHAR-1:0] query_datastream_out, sub_datastream_out;
output FIFO_empty;
output reg [LENGTH_COUNTER-1:0] hit_add_score;
output reg [LENGTH_COUNTER-1:0] hit_add_inQ_UnGap, hit_add_inS_UnGap, hit_length_UnGap;

//output [LENGTH*4-1:0] _debug_;
//output [LENGTH_CHAR*LENGTH*MAX_ARRAY-1:0] query_debug,subject_debug;
//wire [LENGTH_CHAR*LENGTH-1:0] query_debug_temp[0:MAX_ARRAY-1],subject_debug_temp[0:MAX_ARRAY-1];
//output ready;
//wire [LENGTH-1:0] _debug_temp [0:MAX_ARRAY-1];
//output reg [LENGTH_COUNTER-1:0] num_HSP_read=0;
//output [LENGTH_COUNTER-1:0] num_HSP_out;

wire [LENGTH_CHAR-1:0]  query_temp[0:MAX_ARRAY-1], sub_temp[0:MAX_ARRAY-1];
wire [LENGTH_COUNTER-1:0] hit_add_inQ_UnGap_temp[0:MAX_ARRAY-1], hit_add_inS_UnGap_temp[0:MAX_ARRAY-1], hit_length_UnGap_temp[0:MAX_ARRAY-1],
									hit_add_score_temp[0:MAX_ARRAY-1];

									
wire [LENGTH_COUNTER-1:0] buf_out_s[0:MAX_ARRAY-1] , buf_out_q[0:MAX_ARRAY-1];  
wire [LENGTH_COUNTER-1:0] buf_out_hit_length[0:MAX_ARRAY-1], buf_out_score[0:MAX_ARRAY-1];              
// port to output the data using pop.
wire    [MAX_ARRAY-1:0]           buf_empty, buf_full;      
// buffer empty and full indication 
wire[LENGTH_COUNTER-1 :0] fifo_counter[0:MAX_ARRAY-1]; 
reg [MAX_ARRAY-1:0] rd_en = 0;
reg [LENGTH_COUNTER-1:0] counter_Mux = 0;
reg flag=0;
//wire [LENGTH_COUNTER-1:0] num_HSP_out_temp[0:MAX_ARRAY-1];

//assign _debug_ = {_debug_temp[0],_debug_temp[1],_debug_temp[2],_debug_temp[3]};
assign FIFO_empty = buf_empty[0]&&buf_empty[1]&&buf_empty[2]&&buf_empty[3];
//assign query_debug = {query_debug_temp[0],query_debug_temp[1],query_debug_temp[2],query_debug_temp[3]};
//assign subject_debug = {subject_debug_temp[0],subject_debug_temp[1],subject_debug_temp[2],subject_debug_temp[3]};
//assign num_HSP_out = num_HSP_out_temp[0] + num_HSP_out_temp[1] + num_HSP_out_temp[2] + num_HSP_out_temp[3];
								
genvar i;
generate
for (i=0; i < MAX_ARRAY; i = i + 1)
  begin: pe_block
      if (i == 0)                       //first blast unit in auto-generated chain
		begin: BU_block0
         Blastn_Unit Blastn_U(i,array_clk, query_enable, sub_enable, reset, 1,
						Q_address_F[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i], 
						S_address_F[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i],
						Q_context_F[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						S_context_F[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						Q_address_R[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i],
						S_address_R[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i],
						Q_context_R[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						S_context_R[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						query_datastream_in, sub_datastream_in, query_temp[i], sub_temp[i],
						hit_add_inQ_UnGap_temp[i], hit_add_inS_UnGap_temp[i], hit_length_UnGap_temp[i], hit_add_score_temp[i]);// _debug_temp[i],query_debug_temp[i], subject_debug_temp[i], num_HSP_out_temp[i]);
		end
		else if ((i>0) && (i<MAX_ARRAY-1))       //blast unit other than first one
		begin: BU_block1_3
          Blastn_Unit Blastn_U(i,array_clk, query_enable, sub_enable, reset, 1,
						Q_address_F[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i], 
						S_address_F[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i],
						Q_context_F[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						S_context_F[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						Q_address_R[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i],
						S_address_R[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i],
						Q_context_R[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						S_context_R[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						query_temp[i-1], sub_temp[i-1], query_temp[i], sub_temp[i],
						hit_add_inQ_UnGap_temp[i], hit_add_inS_UnGap_temp[i], hit_length_UnGap_temp[i], hit_add_score_temp[i]);// _debug_temp[i], query_debug_temp[i], subject_debug_temp[i], num_HSP_out_temp[i]);
		end
		
		else if (i==MAX_ARRAY-1)       //last blast unit
		begin: BU_block4
          Blastn_Unit Blastn_U(i,array_clk, query_enable, sub_enable, reset, 1,
						Q_address_F[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i], 
						S_address_F[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i],
						Q_context_F[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						S_context_F[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						Q_address_R[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i],
						S_address_R[LENGTH_COUNTER-1+LENGTH_COUNTER*i:LENGTH_COUNTER*i],
						Q_context_R[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						S_context_R[LENGTH_CHAR-1+LENGTH_CHAR*i:LENGTH_CHAR*i],
						query_temp[i-1], sub_temp[i-1], query_datastream_out, sub_datastream_out,
						hit_add_inQ_UnGap_temp[i], hit_add_inS_UnGap_temp[i], hit_length_UnGap_temp[i], hit_add_score_temp[i]);// _debug_temp[i], query_debug_temp[i],subject_debug_temp[i], num_HSP_out_temp[i]);
		end
   end
endgenerate


genvar j;
generate
for (j=0; j < MAX_ARRAY; j = j + 1)
	begin: ABC
   Fifo_HSP fifo_HSP_unit(array_clk, reset, hit_add_inS_UnGap_temp[j], 
			hit_add_inQ_UnGap_temp[j],
			hit_length_UnGap_temp[j], 
			hit_add_score_temp[j], 
			buf_out_s[j], buf_out_q[j], buf_out_hit_length[j], buf_out_score[j],
			1, rd_en[j], buf_empty[j], buf_full[j], fifo_counter[j] );
	end
endgenerate
			
always @(posedge array_clk)
begin	
	//reset = 0;
	rd_en = 0;
	if (read_HSP == 1)
	begin	
		if (buf_empty[counter_Mux] == 0 )
				begin	
					if (counter_Mux != 0) rd_en[counter_Mux-1] = 0;
					rd_en[counter_Mux] = 1;
					hit_add_inQ_UnGap = buf_out_q[counter_Mux];
					hit_add_inS_UnGap = buf_out_s[counter_Mux];
					hit_length_UnGap  = buf_out_hit_length[counter_Mux];
					hit_add_score = buf_out_score[counter_Mux];
					flag = 1;
					//num_HSP_read = num_HSP_read + 1;
				end
		else 
		begin	
			if (flag == 1) 
				begin
					if (counter_Mux != 0) rd_en[counter_Mux-1] = 0;
					hit_add_inQ_UnGap = buf_out_q[counter_Mux];
					hit_add_inS_UnGap = buf_out_s[counter_Mux];
					hit_length_UnGap  = buf_out_hit_length[counter_Mux];
					hit_add_score = buf_out_score[counter_Mux];
					flag = 0;
				end
			else
				begin
					hit_add_inQ_UnGap = 0;
					hit_add_inS_UnGap = 0;
					hit_length_UnGap  = 0;
					hit_add_score = 0;
					if (counter_Mux != 0) rd_en[counter_Mux-1] = 0;
				end
			counter_Mux = counter_Mux + 1;
		end
			
		if (counter_Mux == MAX_ARRAY) counter_Mux = 0;	
	end
end

			
			
endmodule