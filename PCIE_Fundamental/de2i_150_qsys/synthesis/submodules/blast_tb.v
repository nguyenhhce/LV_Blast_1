`timescale 1ns / 1ps
module blast_tb ;

// port 2 memory interface
      wire[13:0] memory_address;       
      wire       memory_write;         
      reg [63:0] memory_readdata;      
      wire[63:0] memory_writedata;            
      wire[7:0]  memory_byteenable;           
      wire       memory_chipselect;           
      wire       memory_clken;
          
// clock, resset
		reg clk;
		reg reset;
				 
		reg memory_ready;
		reg app_ready;
      reg [7:0] app_code;
				 
		wire          query_enable;
		wire [2:0]    query_datastream_in;
		wire          subject_enable;
		wire [2:0]    subject_datastream_in;
		
      reg  [7:0] hit_add_inQ_UnGap;
		reg  [7:0] hit_add_inS_UnGap;
		reg  [7:0] hit_length_UnGap;
		reg  [7:0] hit_add_score;

Blast_top  UUT(
		 .memory_address(memory_address) ,
		 .memory_write(memory_write) ,
		 .memory_readdata(memory_readdata), 
		 .memory_writedata(memory_writedata),
		 .memory_byteenable(memory_byteenable), 
		 .memory_chipselect(memory_chipselect) ,
		 .memory_clken(memory_clken),
		 
		 .clk(clk),
		 .reset(reset),
		 
		 .memory_ready(memory_ready),
		 .app_ready(app_ready),
		 .app_code(app_code),
		 
		 .query_enable(query_enable),
		 .query_datastream_in(query_datastream_in),
		 .subject_enable(subject_enable),
		 .subject_datastream_in(subject_datastream_in),
		 
		 .hit_add_inQ_UnGap(hit_add_inQ_UnGap),
		 .hit_add_inS_UnGap(hit_add_inS_UnGap),
		 .hit_length_UnGap(hit_length_UnGap),
		 .hit_add_score(hit_add_score)
 );
 
    initial begin
	   clk = 1'b0;
		reset = 1'b0;
		app_code = 0;
		app_ready = 0;
		memory_readdata = -345;
	 end
	 
    always   #5 clk = ~clk;
	 
	 initial begin
    reset = 1;
#15
    reset = 0; 
	 hit_add_inQ_UnGap = 8'haa;
	 hit_add_inS_UnGap = 8'hbb;
	 hit_length_UnGap  = 8'hcc;
	 hit_add_score     = 8'hdd;
	 app_ready         = 1'b1;
	 app_code          = 8'hAA;
#10
    app_ready         = 1'b0;
	 app_code          = 8'hBB;
#60 
    app_ready         = 1'b1;
#10 
    app_ready         = 1'b0;
    #400000
	 $finish;
	 end
	 
	 always #10 memory_readdata = memory_readdata + 1;
endmodule 