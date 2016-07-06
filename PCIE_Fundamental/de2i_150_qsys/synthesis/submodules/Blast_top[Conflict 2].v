module Blast_top 
#(
    parameter DATABASE_BLOCK_SIZE       = 16250,    //(127*1024/8)
    parameter MEM_QUERY_ADDR            = 0,
    parameter MEM_SUBJECT_ADDR          = 12,
    parameter MEM_HIT_SCORE_ADDR        = (MEM_SUBJECT_ADDR + DATABASE_BLOCK_SIZE),
    parameter MEMORY_DATAWIDTH          = 64,
    parameter MEMORY_ADDRESS            = 14,
    parameter LENGTH_CHAR               = 3,
    parameter LENGTH_COUNTER            = 8
)
(
// port 2 memory interface
    output wire [13:0] memory_address,       
    output             memory_write,         
    input  wire [63:0] memory_readdata,      
    output reg  [63:0] memory_writedata,            
    output wire [7:0]  memory_byteenable,           
    output wire        memory_chipselect,           
    output wire        memory_clken,

// clock, resset
    input clk,
    input reset,

    input       memory_ready,
    input       app_ready,
    input [7:0] app_code,

		  //Debuging
    output reg [6*MEMORY_DATAWIDTH -1: 0] query_data_debug,
    output reg [6*MEMORY_DATAWIDTH -1: 0] subject_data_debug,
	 output reg [MEMORY_DATAWIDTH/2 -1: 0] subject_length,
    output reg [MEMORY_DATAWIDTH/2 -1: 0] subject_ID,
	 output wire [13:0]                    memory_address_Q, 
	 output wire [13:0]                    memory_address_S, 
	 output wire [13:0]                    memory_address_H,
	 output wire                           write_LCD,
	 output wire [25:0]                     debug_status,
	 output wire [87:0] 							_debug_,
	 output wire [383:0]							query_debug,
	 output wire [383:0]							subject_debug
  );

  
  
    parameter  QUERY_AREA     = 2'b01;
    parameter  SUBJECT_AREA   = 2'b10;
    parameter  HIT_SCORE_AREA = 2'b11;

	parameter IDLE                 = 3'b000;
	parameter READ_QUERY           = 3'b001;
	parameter READ_SUBJECT         = 3'b010;
	parameter WRITE_HIT_SCORE      = 3'b011;
	parameter FINISHED             = 3'b100;


	parameter READ_QUERY_CODE      = 8'HAA;
	parameter READ_SUBJECT_CODE    = 8'HBB;
	parameter FINISHED_CODE        = 8'HEE;
  
  
    reg                      query_enable;
    reg [LENGTH_CHAR-1:0]    query_datastream_in;
    reg                      subject_enable;
    reg [LENGTH_CHAR-1:0]    subject_datastream_in;
	 wire [LENGTH_CHAR-1:0]    query_datastream_out;
    wire [LENGTH_CHAR-1:0]    sub_datastream_out;

    wire  [LENGTH_COUNTER-1:0] hit_add_inQ_UnGap;
    wire  [LENGTH_COUNTER-1:0] hit_add_inS_UnGap;
    wire  [LENGTH_COUNTER-1:0] hit_length_UnGap;
    wire  [LENGTH_COUNTER-1:0] hit_add_score;
	 wire 	FIFO_empty;
	 wire [LENGTH_COUNTER-1:0] num_HSP_out, num_HSP_read;
	 
    reg [2:0]                       state;
    reg [2:0]                       next_state;
	 
    wire                            found_hit_score;

    reg  [MEMORY_ADDRESS-1:0]       query_address;
    reg  [MEMORY_ADDRESS-1:0]       subject_address;
    reg  [MEMORY_ADDRESS-1:0]       hit_score_address;
    reg  [2:0]                      read_query_count;
    reg  [2:0]                      read_subject_count;
    reg                             first_read_subject;

    reg                             read_query_done;
    reg                             read_subject_done;
    wire                            write_hit_score_done;
    reg                             write_hit_score_header_done;
    wire                            finished;

   reg read_query     ;
   reg read_subject   ;
   reg write_hit_score;
   reg write_hit_score_header;
   reg idle ;  

   
//   reg first_read_query;

   reg [6*MEMORY_DATAWIDTH -1: 0] query_data;
   reg [6*MEMORY_DATAWIDTH -1: 0] subject_data;
//   reg [MEMORY_DATAWIDTH/2 -1: 0] subject_length;
   reg [MEMORY_DATAWIDTH/2 -1: 0] read_subject_total;
//   reg [MEMORY_DATAWIDTH/2 -1: 0] subject_ID;
   reg [MEMORY_DATAWIDTH/2 -1: 0] hit_score_length;

   
    reg [8:0] push_query_count;
    reg [8:0] push_subject_count;   
	 
	 //assign debug_status    = {idle,write_hit_score,read_subject,first_read_subject,state,finished, FIFO_empty,read_hit_score_pair, query_datastream_out, sub_datastream_out};
	 assign debug_status    = {idle,write_hit_score,read_subject,first_read_subject,state,finished, FIFO_empty, num_HSP_out, num_HSP_read};
    assign memory_clken    = 1'b1;
    assign found_hit_score = |{|hit_add_inQ_UnGap, |hit_add_inS_UnGap, |hit_length_UnGap, |hit_add_score}&&(!FIFO_empty);
    assign memory_address  = (read_query) ? query_address : 
                             (read_subject) ? subject_address :
                             (write_hit_score | write_hit_score_header) ? hit_score_address : 0 ;

	 assign      memory_address_Q = query_address; 
	 assign      memory_address_S = subject_address; 
	 assign      memory_address_H = hit_score_address;

     assign write_LCD = read_query | read_subject ;
     assign memory_clken      = 1'b1;
     assign memory_chipselect = 1'b1;
     assign memory_byteenable = 8'HFF;
     assign memory_write      = (write_hit_score || write_hit_score_header);
///   reg first_write_hit_score;
//changing state of write_hit_score to read_subject after 64 clock
   assign write_hit_score_done = ~|subject_data[3*MEMORY_DATAWIDTH +:3*MEMORY_DATAWIDTH];
   assign finished             = write_hit_score_done && (read_subject_total >= subject_length && read_subject_total>4'd8);
   //assign finished                      = ~|subject_data[0 +: 3*MEMORY_DATAWIDTH];
   always @(posedge clk)
   begin
      if(reset) state <= IDLE;
      else state <= next_state;
   end

   always @(*)
   begin
      next_state             = state;
      read_query             = 1'b0;
      read_subject           = 1'b0;
      write_hit_score        = 1'b0;
      write_hit_score_header = 1'b0;
      idle                   = 1'b0;

      case(state)
         IDLE: begin
            if(app_ready) begin
               if( app_code == READ_QUERY_CODE) begin
                  next_state = READ_QUERY;
               end
               else if(app_code == READ_SUBJECT_CODE) begin
                  next_state = READ_SUBJECT;
               end 
            end
            idle               = 1'b1;
         end
         READ_QUERY: begin
            if(read_query_done) begin
               next_state = IDLE;
            end
               read_query = 1'b1;
         end
         READ_SUBJECT: begin
            //if(finished) begin
            //   next_state = FINISHED;
            //end
            if(read_subject_done) begin
               next_state = WRITE_HIT_SCORE;
            end
            read_subject = 1'b1;
         end
         WRITE_HIT_SCORE: begin
            if(finished) begin
               next_state = FINISHED;
            end
            else if(write_hit_score_done) begin
               next_state = READ_SUBJECT;
            end
            write_hit_score = 1'b1;
         end
         FINISHED: begin
            if(write_hit_score_header_done) begin
               next_state = IDLE;
            end
            write_hit_score_header = 1'b1;
         end
			default: begin
			end
      endcase
   end


   always @(posedge clk) begin

//read query
      if(read_query) begin
         query_data[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= memory_readdata;
         query_data[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
         query_data[3*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];         query_data[1*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data[2*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
         query_data[2*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data[3*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
         query_data[1*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data[2*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
         query_data[0*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data[1*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
         push_query_count                                   <= 8'b0;
			
			//Binh added for debuging
         query_data_debug[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= memory_readdata;
         query_data_debug[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data_debug[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
         query_data_debug[3*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data_debug[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];         query_data[1*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data[2*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
         query_data_debug[2*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data_debug[3*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
         query_data_debug[1*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data_debug[2*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
         query_data_debug[0*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= query_data_debug[1*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
		end
      else begin
         if(push_query_count  < 8'd128) begin
           query_datastream_in  <= query_data[2:0];
            query_enable        <= 1'b1;
            push_query_count    <= push_query_count + 1'b1;
            query_data          <= query_data >> 3;
         end
         else begin
            query_enable        <= 1'b0;
         end

      end 

//read subject
      if(read_subject) begin
         if(first_read_subject) begin
            if(read_subject_count == 1) begin
                {subject_ID, subject_length}                        <= memory_readdata;
            end
				else if(read_subject_count > 1)begin
					subject_data[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= memory_readdata;
					subject_data[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
					subject_data[3*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
					subject_data[2*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data[3*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
					subject_data[1*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data[2*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
					subject_data[0*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data[1*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
					
					subject_data_debug[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= memory_readdata;
					subject_data_debug[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data_debug[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
					subject_data_debug[3*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data_debug[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
					subject_data_debug[2*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data_debug[3*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
					subject_data_debug[1*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data_debug[2*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
					subject_data_debug[0*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data_debug[1*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
				end
         end
			else begin
				subject_data[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= memory_readdata;
				subject_data[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
				subject_data[3*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
				subject_data_debug[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= memory_readdata;
				subject_data_debug[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data_debug[5*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
				subject_data_debug[3*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH] <= subject_data_debug[4*MEMORY_DATAWIDTH +: MEMORY_DATAWIDTH];
			end
         push_subject_count                                      <= 8'b0;
      end
      else begin
         if(push_subject_count < 7'd64) begin
            subject_datastream_in <= subject_data[2:0];
            subject_enable        <= 1'b1;
            push_subject_count    <= push_subject_count + 1'b1;
            subject_data          <= subject_data >> 3;
         end
         else begin
            subject_enable        <= 1'b0;
         end
      end 

   end


    always @(posedge clk) begin
      if(reset | idle) begin 
         first_read_subject          <= 1'b1;
         read_subject_total          <= 0;
         read_query_count            <= 3'b0;
         write_hit_score_header_done <= 1'b0;
         read_query_done             <= 1'b0;
         read_subject_done           <= 1'b0;
         read_subject_count          <= 3'b0;
         query_address               <= MEM_QUERY_ADDR;
         subject_address             <= MEM_SUBJECT_ADDR ;
         hit_score_address           <= MEM_HIT_SCORE_ADDR;			
      end
		
      else if(read_query) begin
         read_query_count            <= read_query_count + 1'b1;
         if(read_query_count == 3'h5) begin
           read_query_done           <= 1'b1;
         end
         else begin
         end
//         memory_SEG                  <= QUERY_AREA;
         query_address               <= query_address + 1'b1;
      end
		
      else if(read_subject) begin
         if(first_read_subject)begin
             if(read_subject_count == 3'd7) begin
                read_subject_done    <= 1'b1;
                first_read_subject   <= 1'b0;
             end
         end
         else begin
            if(read_subject_count == 3'd3) begin
               read_subject_done     <= 1'b1;
            end
         end
         read_subject_total          <= read_subject_total + 4'd8;
         read_subject_count          <= read_subject_count + 1'b1;
		   subject_address             <= subject_address + 1'b1;
      end
		
      else if(write_hit_score) begin
		   read_subject_count           <= 3'b0;
         read_subject_done            <= 1'b0;
			hit_score_address            <= hit_score_address + 1'b1;
			if(hit_score_address == -14'h1) begin
			   hit_score_address         <= MEM_HIT_SCORE_ADDR + 1'b1;
			end
         if(found_hit_score) begin
            hit_score_length         <= hit_score_length + 4'd8;
            memory_writedata         <= {hit_add_inQ_UnGap, hit_add_inS_UnGap, hit_length_UnGap, hit_add_score};
         end
      end    
		
      else if(write_hit_score_header) begin
         write_hit_score_header_done <= 1'b1;
			hit_score_address           <= MEM_HIT_SCORE_ADDR;
         memory_writedata            <= {subject_ID, hit_score_length};
         hit_score_length            <= 0;
         first_read_subject          <= 1'b1;
      end
   end
   
	assign read_hit_score_pair = write_hit_score;
	
	Blastn_Array BA(
	   .array_clk(clk), 
		.query_enable(query_enable), 
		.sub_enable(subject_enable), 
//		.enable, 
		.reset(reset), 
		.read_HSP(read_hit_score_pair),
//		.Q_address_F, 
//		.S_address_F, 
//		.Q_context_F, 
//		.S_context_F,
//		.Q_address_R,
//		.S_address_R,
//		.Q_context_R,
//		.S_context_R,
//		.Q_valid_F, 
//		.S_valid_F, 
//		.Q_valid_R, 
//		.S_valid_R,
      .query_datastream_in(query_datastream_in), 
		.sub_datastream_in(subject_datastream_in), 
		.query_datastream_out(query_datastream_out), 
		.sub_datastream_out(sub_datastream_out),
		.hit_add_inQ_UnGap(hit_add_inQ_UnGap),
		.hit_add_inS_UnGap(hit_add_inS_UnGap),
		.hit_length_UnGap(hit_length_UnGap),
		.hit_add_score(hit_add_score),
		.FIFO_empty(FIFO_empty),
		._debug_(_debug_),
		.query_debug(query_debug),
		.subject_debug(subject_debug),
		.num_HSP_out(num_HSP_out),
		.num_HSP_read(num_HSP_read)
		);
		
//	 assign hit_add_inQ_UnGap  = 8'HFE;
//    assign hit_add_inS_UnGap  = 8'hCA;
//    assign hit_length_UnGap   = 8'HAD;
//    assign hit_add_score      = 8'HDE;
endmodule 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    