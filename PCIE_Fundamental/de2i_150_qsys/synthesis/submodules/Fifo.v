`define BUF_WIDTH 2    // BUF_SIZE = 16 -> BUF_WIDTH = 4, no. of bits to be used in pointer
`define BUF_SIZE ( 1<<`BUF_WIDTH )
`define LENGTH_COUNTER 8

module Fifo( clk, rst, buf_in_s, buf_in_q, buf_in_l, buf_out_s, buf_out_q, buf_out_l, wr_en, rd_en, buf_empty, buf_full, fifo_counter );

input                 rst, clk, wr_en, rd_en;   
// reset, system clock, write enable and read enable.
input [`LENGTH_COUNTER-1:0]           buf_in_q, buf_in_s,buf_in_l;                   
// data input to be pushed to buffer
output reg [`LENGTH_COUNTER-1:0]            buf_out_s, buf_out_q, buf_out_l;                  
// port to output the data using pop.
output                buf_empty, buf_full;      
// buffer empty and full indication 
output[`BUF_WIDTH :0] fifo_counter;             
// number of data pushed in to buffer   
reg                   buf_empty, buf_full;
reg[`BUF_WIDTH-1 :0]    fifo_counter;
reg[`BUF_WIDTH -1:0]  rd_ptr, wr_ptr;           // pointer to read and write addresses  
reg[`LENGTH_COUNTER-1:0]              buf_mem_q[`BUF_SIZE -1 : 0], buf_mem_s[`BUF_SIZE -1 : 0], buf_mem_l[`BUF_SIZE -1 : 0]; //  

always @(fifo_counter)
begin
   buf_empty = (fifo_counter==0);
   buf_full = (fifo_counter== `BUF_SIZE);

end

always @(posedge clk or posedge rst)
begin
   if( rst )
       fifo_counter = 0;

   else if( (!buf_full && wr_en && (buf_in_l!=0) ) && ( !buf_empty && rd_en ) )
       fifo_counter = fifo_counter;

   else if( !buf_full && wr_en && (buf_in_l!=0) )
       fifo_counter = fifo_counter + 1;

   else if( !buf_empty && rd_en)
       fifo_counter = fifo_counter - 1;
   else
      fifo_counter = fifo_counter;
end

always @( posedge clk)
begin
   if( rst || (rd_en == 0))
      begin
			buf_out_s = 0;
			buf_out_q = 0;
			buf_out_l = 0;
		end
   else
   begin
      if( rd_en && !buf_empty )
			begin
				buf_out_s = buf_mem_s[rd_ptr];
				buf_out_q = buf_mem_q[rd_ptr];
				buf_out_l = buf_mem_l[rd_ptr];
			end
      else
			begin
				buf_out_s = 0;
				buf_out_q = 0;
				buf_out_l = 0;
			end
   end
	
	
end

always @(posedge clk)
begin

   if( wr_en && !buf_full && (buf_in_l!=0) )
		begin
			buf_mem_s[ wr_ptr ] = buf_in_s;
			buf_mem_q[ wr_ptr ] = buf_in_q;
			buf_mem_l[ wr_ptr ] = buf_in_l;
		end
   else
		begin
			buf_mem_s[ wr_ptr ] = buf_mem_s[ wr_ptr ];
			buf_mem_q[ wr_ptr ] = buf_mem_q[ wr_ptr ];
			buf_mem_l[ wr_ptr ] = buf_mem_l[ wr_ptr ];
		end
end

always@(posedge clk or posedge rst)
begin
   if( rst )
   begin
      wr_ptr = 0;
      rd_ptr = 0;
   end
   else
   begin
      if( !buf_full && wr_en && (buf_in_l!=0) )    wr_ptr = wr_ptr + 1;
          else  wr_ptr = wr_ptr;

      if( !buf_empty && rd_en )   rd_ptr = rd_ptr + 1;
      else rd_ptr = rd_ptr;
		

				
   end

end
endmodule