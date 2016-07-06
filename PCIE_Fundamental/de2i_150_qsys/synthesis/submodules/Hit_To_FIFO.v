	`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:44:21 04/22/2015 
// Design Name: 
// Module Name:    Hit_To_FIFO
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
module Hit_To_FIFO(com_clk, hit_add_inQ, hit_add_inS, hit_length, wr_en, hit_add_inQ_out, hit_add_inS_out, hit_length_out, reset);
//		hit_query_location_1, hit_query_location_2, hit_sub_location_1, hit_sub_location_2);
localparam
A = 3'b001,        //nucleotide "A"
G = 3'b010,        //nucleotide "G"
T = 3'b011,        //nucleotide "T"
C = 3'b100;        //nucleotide "C"
parameter LENGTH_CHAR = 3;
parameter LENGTH_COUNTER =8;
parameter LENGTH_ADDRESS = 16;
parameter LENGTH_HIT_INFO = 22;
parameter BUF_WIDTH = 3;

input com_clk;
input [LENGTH_HIT_INFO-1:0] wr_en;
input  [LENGTH_COUNTER*LENGTH_HIT_INFO-1:0] hit_add_inQ, hit_add_inS;
input [LENGTH_COUNTER*LENGTH_HIT_INFO-1:0] hit_length;
input reset;
output reg [LENGTH_COUNTER-1:0] hit_add_inQ_out, hit_add_inS_out;
output reg [LENGTH_COUNTER-1:0] hit_length_out;
// data input to be pushed to buffer

wire [LENGTH_COUNTER-1:0] buf_out_s[0:LENGTH_HIT_INFO-1] , buf_out_q[0:LENGTH_HIT_INFO-1];  
wire [LENGTH_COUNTER-1:0] buf_out_hit_length[0:LENGTH_HIT_INFO-1];              
// port to output the data using pop.
wire    [LENGTH_HIT_INFO-1:0]           buf_empty, buf_full;      
// buffer empty and full indication 
wire[BUF_WIDTH-1 :0] fifo_counter[0:LENGTH_HIT_INFO-1]; 
reg [LENGTH_HIT_INFO-1:0] rd_en = 0;
reg [LENGTH_COUNTER-1:0] counter_Mux = 0;

integer i;
reg flag=0;


genvar j;
generate
for (j=0; j < LENGTH_HIT_INFO; j = j + 1)
	begin: ABC
   Fifo fifo_Q(com_clk, reset, hit_add_inS[j*LENGTH_COUNTER+LENGTH_COUNTER-1:j*LENGTH_COUNTER], 
			hit_add_inQ[j*LENGTH_COUNTER+LENGTH_COUNTER-1:j*LENGTH_COUNTER],
			hit_length[j*LENGTH_COUNTER+LENGTH_COUNTER-1:j*LENGTH_COUNTER], buf_out_s[j], buf_out_q[j], buf_out_hit_length[j],
			wr_en[j], rd_en[j], buf_empty[j], buf_full[j], fifo_counter[j] );
	end
endgenerate


always @(posedge com_clk)
begin	
	rd_en = 0;
	
	if (buf_empty[counter_Mux] == 0 )
				begin	
					if (counter_Mux != 0) rd_en[counter_Mux-1] = 0;
					rd_en[counter_Mux] = 1;
					hit_add_inQ_out = buf_out_q[counter_Mux];
					hit_add_inS_out = buf_out_s[counter_Mux];
					hit_length_out  = buf_out_hit_length[counter_Mux];
					flag = 1;
				end
	else 
		begin	
			if (flag == 1) 
				begin
					if (counter_Mux != 0) rd_en[counter_Mux-1] = 0;
					hit_add_inQ_out = buf_out_q[counter_Mux];
					hit_add_inS_out = buf_out_s[counter_Mux];
					hit_length_out  = buf_out_hit_length[counter_Mux];
					flag = 0;
				end
			else
				begin
					hit_add_inQ_out = 0;
					hit_add_inS_out = 0;
					hit_length_out  = 0;
					if (counter_Mux != 0) rd_en[counter_Mux-1] = 0;
				end
			counter_Mux = counter_Mux + 1;
		end
			
	if (counter_Mux == LENGTH_HIT_INFO - 1) counter_Mux = 0;	
		
end

	 
endmodule