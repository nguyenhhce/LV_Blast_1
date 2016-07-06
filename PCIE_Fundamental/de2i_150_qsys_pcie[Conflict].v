// ============================================================================
// Copyright (c) 2012 by Terasic Technologies Inc.
// ============================================================================
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
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Wed Jun 27 19:19:53 2012
// ============================================================================

`define ENABLE_PCIE

module de2i_150_qsys_pcie(

							///////////CLOCK2/////////////
							CLOCK2_50,

							/////////CLOCK3/////////
							CLOCK3_50,

							/////////CLOCK/////////
							CLOCK_50,

							/////////DRAM/////////
							DRAM_ADDR,
							DRAM_BA,
							DRAM_CAS_N,
							DRAM_CKE,
							DRAM_CLK,
							DRAM_CS_N,
							DRAM_DQ,
							DRAM_DQM,
							DRAM_RAS_N,
							DRAM_WE_N,

							/////////EEP/////////
							EEP_I2C_SCLK,
							EEP_I2C_SDAT,

							/////////ENET/////////
							ENET_GTX_CLK,
							ENET_INT_N,
							ENET_LINK100,
							ENET_MDC,
							ENET_MDIO,
							ENET_RST_N,
							ENET_RX_CLK,
							ENET_RX_COL,
							ENET_RX_CRS,
							ENET_RX_DATA,
							ENET_RX_DV,
							ENET_RX_ER,
							ENET_TX_CLK,
							ENET_TX_DATA,
							ENET_TX_EN,
							ENET_TX_ER,

							/////////FAN/////////
							FAN_CTRL,

							/////////FL/////////
							FL_CE_N,
							FL_OE_N,
							FL_RY,
							FL_WE_N,
							FL_WP_N,
							FL_RESET_N,
							/////////FS/////////
							FS_DQ,
							FS_ADDR,
							/////////GPIO/////////
							GPIO,

							/////////G/////////
							G_SENSOR_INT1,
							G_SENSOR_SCLK,
							G_SENSOR_SDAT,

							/////////HEX/////////
							HEX0,
							HEX1,
							HEX2,
							HEX3,
							HEX4,
							HEX5,
							HEX6,
							HEX7,

							/////////HSMC/////////
							HSMC_CLKIN0,
							HSMC_CLKIN_N1,
							HSMC_CLKIN_N2,
							HSMC_CLKIN_P1,
							HSMC_CLKIN_P2,
							HSMC_CLKOUT0,
							HSMC_CLKOUT_N1,
							HSMC_CLKOUT_N2,
							HSMC_CLKOUT_P1,
							HSMC_CLKOUT_P2,
							HSMC_D,
							HSMC_I2C_SCLK,
							HSMC_I2C_SDAT,
							HSMC_RX_D_N,
							HSMC_RX_D_P,
							HSMC_TX_D_N,
							HSMC_TX_D_P,

							/////////I2C/////////
							I2C_SCLK,
							I2C_SDAT,

							/////////IRDA/////////
							IRDA_RXD,

							/////////KEY/////////
							KEY,

							/////////LCD/////////
							LCD_DATA,
							LCD_EN,
							LCD_ON,
							LCD_RS,
							LCD_RW,

							/////////LEDG/////////
							LEDG,

							/////////LEDR/////////
							LEDR,

							/////////PCIE/////////
`ifdef ENABLE_PCIE

							PCIE_PERST_N,
							PCIE_REFCLK_P,
							PCIE_RX_P,
							PCIE_TX_P,
							PCIE_WAKE_N,
`endif 
							/////////SD/////////
							SD_CLK,
							SD_CMD,
							SD_DAT,
							SD_WP_N,

							/////////SMA/////////
							SMA_CLKIN,
							SMA_CLKOUT,

							/////////SSRAM/////////
							SSRAM_ADSC_N,
							SSRAM_ADSP_N,
							SSRAM_ADV_N,
							SSRAM_BE,
							SSRAM_CLK,
							SSRAM_GW_N,
							SSRAM_OE_N,
							SSRAM_WE_N,
							SSRAM0_CE_N,
							SSRAM1_CE_N,							
							/////////SW/////////
							SW,

							/////////TD/////////
							TD_CLK27,
							TD_DATA,
							TD_HS,
							TD_RESET_N,
							TD_VS,

							/////////UART/////////
							UART_CTS,
							UART_RTS,
							UART_RXD,
							UART_TXD,

							/////////VGA/////////
							VGA_B,
							VGA_BLANK_N,
							VGA_CLK,
							VGA_G,
							VGA_HS,
							VGA_R,
							VGA_SYNC_N,
							VGA_VS,
);

//=======================================================
//  PORT declarations
//=======================================================

							///////////CLOCK2/////////////

input                                              CLOCK2_50;

///////// CLOCK3 /////////
input                                              CLOCK3_50;

///////// CLOCK /////////
input                                              CLOCK_50;

///////// DRAM /////////
output                        [12:0]               DRAM_ADDR;
output                        [1:0]                DRAM_BA;
output                                             DRAM_CAS_N;
output                                             DRAM_CKE;
output                                             DRAM_CLK;
output                                             DRAM_CS_N;
inout                         [31:0]               DRAM_DQ;
output                        [3:0]                DRAM_DQM;
output                                             DRAM_RAS_N;
output                                             DRAM_WE_N;

///////// EEP /////////
output                                             EEP_I2C_SCLK;
inout                                              EEP_I2C_SDAT;

///////// ENET /////////
output                                             ENET_GTX_CLK;
input                                              ENET_INT_N;
input                                              ENET_LINK100;
output                                             ENET_MDC;
inout                                              ENET_MDIO;
output                                             ENET_RST_N;
input                                              ENET_RX_CLK;
input                                              ENET_RX_COL;
input                                              ENET_RX_CRS;
input                         [3:0]                ENET_RX_DATA;
input                                              ENET_RX_DV;
input                                              ENET_RX_ER;
input                                              ENET_TX_CLK;
output                        [3:0]                ENET_TX_DATA;
output                                             ENET_TX_EN;
output                                             ENET_TX_ER;

///////// FAN /////////
inout                                              FAN_CTRL;

///////// FL /////////
output                                             FL_CE_N;
output                                             FL_OE_N;
input                                              FL_RY;
output                                             FL_WE_N;
output                                             FL_WP_N;
output                                             FL_RESET_N;
///////// FS /////////
inout                         [31:0]               FS_DQ;
output                        [26:0]               FS_ADDR;
///////// GPIO /////////
inout                         [35:0]               GPIO;

///////// G /////////
input                                              G_SENSOR_INT1;
output                                             G_SENSOR_SCLK;
inout                                              G_SENSOR_SDAT;

///////// HEX /////////
output                        [6:0]                HEX0;
output                        [6:0]                HEX1;
output                        [6:0]                HEX2;
output                        [6:0]                HEX3;
output                        [6:0]                HEX4;
output                        [6:0]                HEX5;
output                        [6:0]                HEX6;
output                        [6:0]                HEX7;

///////// HSMC /////////
input                                              HSMC_CLKIN0;
input                                              HSMC_CLKIN_N1;
input                                              HSMC_CLKIN_N2;
input                                              HSMC_CLKIN_P1;
input                                              HSMC_CLKIN_P2;
output                                             HSMC_CLKOUT0;
inout                                              HSMC_CLKOUT_N1;
inout                                              HSMC_CLKOUT_N2;
inout                                              HSMC_CLKOUT_P1;
inout                                              HSMC_CLKOUT_P2;
inout                         [3:0]                HSMC_D;
output                                             HSMC_I2C_SCLK;
inout                                              HSMC_I2C_SDAT;
inout                         [16:0]               HSMC_RX_D_N;
inout                         [16:0]               HSMC_RX_D_P;
inout                         [16:0]               HSMC_TX_D_N;
inout                         [16:0]               HSMC_TX_D_P;

///////// I2C /////////
output                                             I2C_SCLK;
inout                                              I2C_SDAT;

///////// IRDA /////////
input                                              IRDA_RXD;

///////// KEY /////////
input                         [3:0]                KEY;

///////// LCD /////////
inout                         [7:0]                LCD_DATA;
output                                             LCD_EN;
output                                             LCD_ON;
output                                             LCD_RS;
output                                             LCD_RW;

///////// LEDG /////////
output                        [8:0]                LEDG;

///////// LEDR /////////
output                        [17:0]               LEDR;

///////// PCIE /////////
`ifdef ENABLE_PCIE
input                                              PCIE_PERST_N;
input                                              PCIE_REFCLK_P;
input                         [0:0]                PCIE_RX_P;
output                        [0:0]                PCIE_TX_P;
output                                             PCIE_WAKE_N;
`endif 
///////// SD /////////
output                                             SD_CLK;
inout                                              SD_CMD;
inout                         [3:0]                SD_DAT;
input                                              SD_WP_N;

///////// SMA /////////
input                                              SMA_CLKIN;
output                                             SMA_CLKOUT;

///////// SSRAM /////////
output                                             SSRAM_ADSC_N;
output                                             SSRAM_ADSP_N;
output                                             SSRAM_ADV_N;
output                         [3:0]                SSRAM_BE;
output                                             SSRAM_CLK;
output                                             SSRAM_GW_N;
output                                             SSRAM_OE_N;
output                                             SSRAM_WE_N;
output                                             SSRAM0_CE_N;
output                                             SSRAM1_CE_N;

///////// SW /////////
input                         [17:0]               SW;

///////// TD /////////
input                                              TD_CLK27;
input                         [7:0]                TD_DATA;
input                                              TD_HS;
output                                             TD_RESET_N;
input                                              TD_VS;

///////// UART /////////
input                                             UART_CTS;
output                                              UART_RTS;
input                                              UART_RXD;
output                                             UART_TXD;

///////// VGA /////////
output                        [7:0]                VGA_B;
output                                             VGA_BLANK_N;
output                                             VGA_CLK;
output                        [7:0]                VGA_G;
output                                             VGA_HS;
output                        [7:0]                VGA_R;
output                                             VGA_SYNC_N;
output                                             VGA_VS;

//=======================================================
//  REG/WIRE declarations
//=======================================================



wire reset_n;

//=======================================================
//  Structural coding
//=======================================================

assign reset_n = 1'b1;


    de2i_150_qsys u0 (
        .clk_clk                                    (CLOCK_50),                                    //                        clk.clk
        .reset_reset_n                              (reset_n),                              //                      reset.reset_n
        .pcie_ip_refclk_export                      (PCIE_REFCLK_P),                      //             pcie_ip_refclk.export
        .pcie_ip_pcie_rstn_export                   (PCIE_PERST_N),                   //          pcie_ip_pcie_rstn.export
        .pcie_ip_rx_in_rx_datain_0                  (PCIE_RX_P[0]),                  //              pcie_ip_rx_in.rx_datain_0
        .pcie_ip_tx_out_tx_dataout_0                (PCIE_TX_P[0]),                //             pcie_ip_tx_out.tx_dataout_0
        //.led_external_connection_export             (LEDR[7:0]),
			//.debug_cs        (debug_cs)       ,
			//.debug_readdata  (debug_readdata) ,
			//.debug_address   (debug_address)  ,
			//.debug_byteeable (debug_byteeable),
			//.debug_write     (debug_write)    ,
			//.debug_writedata (debug_writedata),
			//.debug_clk_en   (debug_clk_en),
			//.debug_sw         (SW[14:0])

				  
			.query_data_debug(query_data_debug),
			.subject_data_debug(subject_data_debug),
			.subject_length(subject_length),
			.subject_ID(subject_ID),
			.memory_address_Q(memory_address_Q), 
			.memory_address_S(memory_address_S), 
			.memory_address_H(memory_address_H),
			.write_LCD(write_LCD),
			.debug_status(debug_status),
			._debug_(_debug_),
			.query_debug(query_debug)
    );
	 
	 
		wire [6*64 -1: 0] query_data_debug;
		wire [6*64 -1: 0] subject_data_debug;
		wire [31: 0]      subject_length;
		wire [31: 0]      subject_ID;
		wire [87:0] _debug_;
		wire [383:0] query_debug;
		wire [383:0] subject_debug;
	   wire  [25:0]       debug_status;
		
		assign PCIE_WAKE_N = 1'b1;	 // 07/30/2013, pull-high to avoid system reboot after power off

		wire         debug_cs      ; 
		wire  [63:0] debug_readdata ;
		wire  [13:0] debug_address  ;
		wire   [7:0] debug_byteeable;
		wire         debug_write    ;
		wire  [63:0] debug_writedata;
		wire         debug_clk_en  ;

      assign {LEDR,LEDG[7:0]} = { debug_status};

//      assign LEDR        = (SW[1:0] == 2'b00 ) ? memory_address_Q :
//							      (SW[1:0] == 2'b01 ) ? memory_address_S :
//							      (SW[1:0] == 2'b10 ) ? memory_address_H : 0;
//      assign LEDR        =  subject_ID[17:0];

		wire hb_50;
heart_beat	heart_beat_clk50(
	.clk(CLOCK_50),
	.led(hb_50)
);


      assign LEDG[8] = hb_50;
      wire [13:0]                    memory_address_Q; 
		wire [13:0]                    memory_address_S; 
	  	wire [13:0]                    memory_address_H;


		wire [3:0] data_temp[7:0];
		wire [6:0] HEX_temp[7:0];

		assign {HEX6,HEX7,HEX4,HEX5,HEX2,HEX3,HEX0,HEX1} = {HEX_temp[7],HEX_temp[6],HEX_temp[5],HEX_temp[4],HEX_temp[3],HEX_temp[2],HEX_temp[1],HEX_temp[0]};
		assign {data_temp[0],data_temp[1],data_temp[2],data_temp[3],data_temp[4],data_temp[5],data_temp[6],data_temp[7]} = (SW[10]) ? subject_ID: subject_length;
		genvar j;
		generate
			for ( j = 0; j < 8; j = j + 1) begin: genHEX
				led7_decoder   SEG( HEX_temp[j], 1, data_temp[j]);
			end
		endgenerate

		assign LCD_DATA = LCD_D_1;
		assign LCD_RW   = LCD_RW_1;
		assign LCD_EN   = LCD_EN_1;
		assign LCD_RS   = LCD_RS_1; 
		assign LCD_ON   = 1'b1;

		wire [7:0] LCD_D_1;
		wire       LCD_RW_1;
		wire       LCD_EN_1;
		wire       LCD_RS_1; 

		wire [255:0] LCD_char;
		wire [127:0] HEX_DATA;
		genvar i;
		generate 
			for(i = 0; i < 32; i= i + 1) begin: gen_LCDchar
				assign LCD_char[i*8 + 7: i*8] = (HEX_DATA[4*i+3:4*i] >= 4'b1010) ? 
														  {4'H4,{HEX_DATA[4*i+3:4*i] - 4'h9}}: 
														  {4'H3,HEX_DATA[4*i+3:4*i]};
			end
		endgenerate 

		assign HEX_DATA = (SW[17:14] == 0) ? query_data_debug[127:0] :
								(SW[17:14] == 1) ? query_data_debug[255:128] :
								(SW[17:14] == 2) ? query_data_debug[383:256] :								
								(SW[17:14] == 3) ? subject_data_debug[127:0] :
								(SW[17:14] == 4) ? subject_data_debug[255:128] :
								(SW[17:14] == 5) ? subject_data_debug[383:256] :
								(SW[17:14] == 6) ? _debug_ :
								(SW[17:14] == 7) ? query_debug[127:0]:
								(SW[17:14] == 8) ? query_debug[255:128]:
								(SW[17:14] == 9) ? query_debug[383:256]:
								(SW[17:14] == 10) ? subject_debug[127:0]:
								(SW[17:14] == 11) ? subject_debug[255:128]:
								(SW[17:14] == 12) ? subject_debug[383:256]: 0;
						
//	Reset Delay Timer
Reset_Delay		r0	(
						   .iCLK(CLOCK_50),
							.oRESET(DLY_RST),
							.iRST_n(KEY[0] &~write_LCD) 	
						);
						
LCD	u5	(	//	Host Side
            .iCLK    (CLOCK_50),
				.iRST_N  (DLY_RST),
				//	LCD Side
				.LCD_DATA(LCD_D_1),
				.LCD_RW  (LCD_RW_1),
				.LCD_EN  (LCD_EN_1),
				.LCD_RS  (LCD_RS_1),	
				.txt00(LCD_char[ 15 : 8 ]),
				.txt01(LCD_char[ 7 : 0 ]),
				
				.txt02(LCD_char[ 31 : 24 ]),
				.txt03(LCD_char[ 23 : 16 ]),
				
				.txt04(LCD_char[ 47 : 40 ]),
				.txt05(LCD_char[ 39 : 32 ]),
				
				.txt06(LCD_char[ 63 : 56 ]),
				.txt07(LCD_char[ 55 : 48 ]),
				
				.txt08(LCD_char[ 79 : 72 ]),
				.txt09(LCD_char[ 71 : 64 ]),
				
				.txt0A(LCD_char[ 95 : 88 ]),
				.txt0B(LCD_char[ 87 : 80 ]),
				
				.txt0C(LCD_char[ 111 : 104 ]),
				.txt0D(LCD_char[ 103 : 96 ]),
				
				.txt0E(LCD_char[ 127 : 120 ]),
				.txt0F(LCD_char[ 119 : 112 ]),
				
				.txt10(LCD_char[ 143 : 136 ]),
				.txt11(LCD_char[ 135 : 128 ]),
				
				.txt12(LCD_char[ 159 : 152 ]),
				.txt13(LCD_char[ 151 : 144 ]),
				
				.txt14(LCD_char[ 175 : 168 ]),
				.txt15(LCD_char[ 167 : 160 ]),
				
				.txt16(LCD_char[ 191 : 184 ]),
				.txt17(LCD_char[ 183 : 176 ]),
				
				.txt18(LCD_char[ 207 : 200 ]),
				.txt19(LCD_char[ 199 : 192 ]),
				
				.txt1A(LCD_char[ 223 : 216 ]),
				.txt1B(LCD_char[ 215 : 208 ]),
				
				.txt1C(LCD_char[ 239 : 232 ]),
				.txt1D(LCD_char[ 231 : 224 ]),
				
				.txt1E(LCD_char[ 255 : 248 ]),
				.txt1F(LCD_char[ 247 : 240 ])
);

endmodule
