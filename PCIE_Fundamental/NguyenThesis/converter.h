// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//

#ifndef _CONVERTER_H
#define _CONVERTER_H

#define A_ADN 1                //3'b001,        //nucleotide "A"
#define G_ADN 2                //3'b010,        //nucleotide "G"
#define T_ADN 3                //3'b011,        //nucleotide "T"
#define C_ADN 4                //3'b100;        //nucleotide "C"
#define N_ADN 7                //3'b111;        //nucleotide "N"

#ifdef __cplusplus
extern "C"{
#endif

void printHexString(char indata[]);
int CovertQuery2Bit(char indata[], int indata_size,
	                char outdata[],int begin);


#ifdef __cplusplus
}
#endif



#endif /* _INC_PCIE_H */

