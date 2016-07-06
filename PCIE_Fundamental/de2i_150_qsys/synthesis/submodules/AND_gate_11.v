`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:58:16 09/19/2015 
// Design Name: 
// Module Name:    AND_gate_11 
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
module AND_gate_11(a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,out);
input a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10;
output out ;
wire out ;
assign out = a0&a1&a2&a3&a4&a5&a6&a7&a8&a9&a10;
endmodule