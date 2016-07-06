//Legal Notice: (C)2016 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module de2i_150_qsys_led (
                           // inputs:
                            address,
                            chipselect,
                            clk,
                            reset_n,
                            write_n,
                            writedata,

                           // outputs:
                            readdata,
							       readdata_valid,
                         )
;

  output reg          readdata_valid; 
  output reg [ 31: 0] readdata;
  input      [  1: 0] address;
  input               chipselect;
  input               clk;
  input               reset_n;
  input               write_n;
  input      [ 31: 0] writedata;

  wire             clk_en;

  assign clk_en = 1;
  
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          readdata <= 32'b0;
      else if (chipselect && ~write_n && (address == 0))begin
          readdata <= writedata;
			 readdata_valid <= 1'b1;
	   end
		else begin
		    readdata_valid <= 1'b0;
		end
    end

endmodule

