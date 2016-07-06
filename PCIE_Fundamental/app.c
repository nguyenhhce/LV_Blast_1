
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include "PCIE.h"
#include "converter.h"

#define DEMO_PCIE_USER_BAR         PCIE_BAR0
#define DEMO_PCIE_IO_LED_ADDR      0x00
#define DEMO_PCIE_IO_BUTTON_ADDR   0x20
#define DEMO_PCIE_FIFO_WRITE_ADDR  0x40
#define DEMO_PCIE_FIFO_STATUS_ADDR 0x60
#define DEMO_PCIE_FIFO_READ_ADDR   0x80
#define DEMO_PCIE_MEM_QUERY_ADDR   0x20000    //256/3 = (#query byte)
                                              // (#query byte)/64 = #address
#define DEMO_PCIE_MEM_SUBJECT_ADDR (DEMO_PCIE_MEM_QUERY_ADDR + QUERY_ENTRIES_64)
#define DEMO_PCIE_MEM_SCORE_ADDR   (DEMO_PCIE_MEM_SUBJECT_ADDR + DATABASE_BLOCK_SIZE)

#define QUERY_ENTRIES_64    (12*8)                   // 256 *3 /64
#define MEM_SIZE           (128*1024) //128KB
#define FIFO_SIZE          (16 *1024) // 2KBx8

#define MAX_QUERY_SIZE_CHAR         256
#define MAX_QUERY_SIZE_BYTE         MAX_QUERY_SIZE_CHAR/3 + 1

#define  MAX_SCORE_SIZE_BYTE        (DEMO_PCIE_MEM_QUERY_ADDR + MEM_SIZE - DEMO_PCIE_MEM_SCORE_ADDR)

#define DATABASE_FILENAME "nc1130_flat"  // 4689005 byte of data
#define DATABASE_LINEWIDTH 100
#define DATABASE_CONVERT_BYTE DATABASE_LINEWIDTH/3 + 1

#define DATABASE_BLOCK_SIZE (127*1024)
#define DATABASE_LINE_SIZE   62

#define WRITE_QUERY          0xAA
#define WRITE_SUBJECT        0xBB
// file area
   char database_line[DATABASE_LINEWIDTH] = "";
   char database_convert_byte[DATABASE_LINEWIDTH / 3 + 1] = "";
   
   int  linecounter = 0; 
   char delimiter[] = " ";
   char startMakerdata[] = "ORIGIN";
   char endMakerdata[] = "//";
   int  StartMarkersize = sizeof(startMakerdata)-1;
   int  EndMarkersize   = sizeof(endMakerdata)-1;
//query area
   char inQueryADN   [MAX_QUERY_SIZE_CHAR] = "";
   char inQueryByte  [MAX_QUERY_SIZE_BYTE] = "";
   char outQueryByte [MAX_QUERY_SIZE_BYTE] = "";

//database area
   BOOL full_buffer = FALSE;
   char indatabaseblock[DATABASE_BLOCK_SIZE] = "";
   char outdatabaseblock[DATABASE_BLOCK_SIZE] = "";
   int  subject_ID = 0;
   int  subject_length;
   
// Score
   char scoreblock[MAX_SCORE_SIZE_BYTE]  = "";   
   
// Command
   int command = 0;
   
typedef enum{
   //MENU_LED = 0,
   MENU_READ_ALL_MEMORY = 0,
   MENU_READ_HIT_SCORE,
   MENU_READ_DATABASE_FILE,
   MENU_WRITE_DATABASE,
   MENU_READ_DATABASE,
   MENU_DMA_WRITE_MEMORY,
   MENU_DMA_READ_MEMORY,
   MENU_DMA_FIFO,
   MENU_QUIT = 99
}MENU_ID;

void UI_ShowMenu(void){
   
   printf("==============================\r\n");
   printf("[%d]: Read ALL MEMORY\r\n", MENU_READ_ALL_MEMORY);
   //printf("[%d]: Led control\r\n", MENU_LED);
   printf("[%d]: Read HIT SCORE\r\n", MENU_READ_HIT_SCORE);
   //printf("[%d]: Read ALL MEMORY\r\n", MENU_READ_DATABASE_FILE);
   
   printf("[%d]: Write SUBJECT database\n", MENU_WRITE_DATABASE);
   printf("[%d]: Read-back SUBJECT database\n", MENU_READ_DATABASE);
   printf("[%d]: Write QUERY\r\n", MENU_DMA_WRITE_MEMORY );
   printf("[%d]: Read-back QUERY\r\n", MENU_DMA_READ_MEMORY);
   //printf("[%d]: DMA Fifo Test\r\n", MENU_DMA_FIFO);
   printf("[%d]: Quit\r\n", MENU_QUIT);
   printf("Please input your selection:");
}

int UI_UserSelect(void){
   int nSel;
   scanf("%d",&nSel);
   return nSel;
}


/* BOOL TEST_LED(PCIE_HANDLE hPCIe){
   BOOL bPass;
   int   Mask;
   
   printf("Please input led conrol mask:");
   scanf("%d", &Mask);

   bPass = PCIE_Write32(hPCIe, DEMO_PCIE_USER_BAR, DEMO_PCIE_IO_LED_ADDR,(DWORD)Mask);
   if (bPass)
      printf("Led control success, mask=%xh\r\n", Mask);
   else
      printf("Led conrol failed\r\n");

   
   return bPass;
}
*/
BOOL TEST_READ_SCORES(PCIE_HANDLE hPCIe){
   BOOL bPass=TRUE;
   int i;
   strcpy(scoreblock,"");
   const PCIE_LOCAL_ADDRESS LocalAddr = DEMO_PCIE_MEM_SCORE_ADDR;

   // read back test pattern and verify

   
   if (bPass){
      bPass = PCIE_DmaRead(hPCIe, LocalAddr, scoreblock, MAX_SCORE_SIZE_BYTE);
        
      if (!bPass){
         printf("06:DMA Memory:PCIE_DmaRead failed\r\n");
      }else{
         for(i=0; i<MAX_SCORE_SIZE_BYTE && bPass; i++){
			printf("%2X ",(unsigned char)scoreblock[i]);
         }
		 printf("\n");
      }
     if(bPass){
        printf("Read successful\n");
     }
     //printHexString(outdatabaseblock);
   }
    
   return bPass;
} 

BOOL TEST_DMA_WRITE_QUERY_MEMORY(PCIE_HANDLE hPCIe){
   BOOL bPass=TRUE;

   const PCIE_LOCAL_ADDRESS LocalAddr = DEMO_PCIE_MEM_QUERY_ADDR;
   printf("Input your query (maximum %d):", MAX_QUERY_SIZE_CHAR);
   
   //clear query
   strcpy(inQueryADN, "");
   
   scanf("%s",inQueryADN);
   CovertQuery2Bit(inQueryADN, MAX_QUERY_SIZE_CHAR,
                                 inQueryByte, MAX_QUERY_SIZE_BYTE);
   printHexString(inQueryByte);

   // write test pattern
   if (bPass){
      bPass = PCIE_DmaWrite(hPCIe, LocalAddr, inQueryByte, MAX_QUERY_SIZE_BYTE);
      if (!bPass)
         printf("05:DMA Memory:PCIE_DmaWrite failed\r\n");
   }      

   //send write query command
   command = WRITE_QUERY;
   bPass = PCIE_Write32(hPCIe, DEMO_PCIE_USER_BAR, DEMO_PCIE_IO_LED_ADDR, command);
   if (bPass){
      printf("Command =%Xh\n", command);
	  subject_ID = 0;
   }
   else
      printf("Failed to write command %X\n",command);
    
   return bPass;
}

BOOL TEST_DMA_READ_QUERY_MEMORY(PCIE_HANDLE hPCIe){
   BOOL bPass=TRUE;
   int i;
   
   const PCIE_LOCAL_ADDRESS LocalAddr = DEMO_PCIE_MEM_QUERY_ADDR;
    
   // read back test pattern and verify
   stpcpy(outQueryByte,"");
   
   if (bPass){
      bPass = PCIE_DmaRead(hPCIe, LocalAddr, outQueryByte, MAX_QUERY_SIZE_BYTE);
        
      if (!bPass){
         printf("06:DMA Memory:PCIE_DmaRead failed\r\n");
      }else{
         for(i=0; i<MAX_QUERY_SIZE_BYTE && bPass; i++){
            //if (outQueryByte[i] != inQueryByte[i]){
            //   bPass = FALSE;
               // printf("01:unmatch, index = %d, read=%2X, expected=%2X\n", 
                       // i,(unsigned char)outQueryByte[i], (unsigned char)inQueryByte[i]);
			   printf("%2X ",(unsigned char)outQueryByte[i]);
            //}
         }
      }
     if(bPass){
        printf("Read successful\n");
     }
   }
    
   return bPass;
}

BOOL TEST_LOAD_DATABASE(FILE *ptr_file)
{
   BOOL number_flag = TRUE;  
   char buf[DATABASE_LINE_SIZE];
   char *database_temp;
   BOOL found = FALSE;

   strcpy(indatabaseblock, "AAAAAAAA"); // space 8 bytes to write subject_ID(4bytes) and subject_length(4byte)
   
   while (!full_buffer)
   //while (fgets(buf, 1000, ptr_file) != NULL)
   {
      if(subject_length + DATABASE_LINE_SIZE > DATABASE_BLOCK_SIZE)
      {
         full_buffer = TRUE;
         subject_length = 0;
      }
      else
      {
         //printf("%s", buf);
       if(fgets(buf, DATABASE_LINE_SIZE, ptr_file) == NULL){
          printf("07: Cant read file\n");
          return FALSE;
       }
         linecounter++;
         if (found)
         {
           if (strncmp(buf, endMakerdata, EndMarkersize) == 0)
           {
             //printf("[Binh]%s", buf);
			 indatabaseblock[7] =  subject_ID & 0xFF;
			 indatabaseblock[6] = (subject_ID>> 8) & 0xFF;
			 indatabaseblock[5] = (subject_ID>>16) & 0xFF;
			 indatabaseblock[4] = (subject_ID>>24) & 0xFF;
			 indatabaseblock[3] =  subject_length & 0xFF;
			 indatabaseblock[2] = (subject_length>> 8) & 0xFF;
			 indatabaseblock[1] = (subject_length>>16) & 0xFF;
			 indatabaseblock[0] = (subject_length>>24) & 0xFF;
			 printf("SubjectID:%d, length:%d\n", subject_ID, subject_length);
             found = FALSE;
			 break;
           }
           else
           {
              /* get the first token */
              database_temp = strtok(buf, delimiter);
              number_flag = TRUE;
              /* walk through other tokens */
              strcpy(database_line, "");
              while (database_temp != NULL){

                 if (number_flag == FALSE){
                    //printf("%s", database_temp);
                    strcat(database_line, database_temp);
                 }
                 else
                 {
                    number_flag = FALSE;
                 }
                 database_temp = strtok(NULL, delimiter);
              }
              //printf(database_line);
              CovertQuery2Bit(database_line, strlen(database_line),
                              database_convert_byte, strlen(database_line) / 3 + 1);
              //printHexString(database_convert_byte);
              strncat(indatabaseblock, database_convert_byte, strlen(database_convert_byte));
              subject_length += strlen(database_convert_byte);
           }
        }
        else if (strncmp(buf, startMakerdata, StartMarkersize) == 0){
          //printf("[Binh] %s", buf);
		  subject_ID = subject_ID + 1;
          found = TRUE;
        }
      }
   }
   //printHexString(indatabaseblock);
   full_buffer = FALSE; //reset for next reading
   printf("#line: %d", linecounter);
   return TRUE;
}


BOOL TEST_DMA_WRITE_DATABASE_MEMORY(PCIE_HANDLE hPCIe , FILE *ptr_file){
   BOOL bPass=TRUE;
   const PCIE_LOCAL_ADDRESS LocalAddr = DEMO_PCIE_MEM_SUBJECT_ADDR;

   TEST_LOAD_DATABASE(ptr_file);
   
   // write test pattern
   if (bPass){
      bPass = PCIE_DmaWrite(hPCIe, LocalAddr, indatabaseblock, DATABASE_BLOCK_SIZE);
      if (!bPass)
         printf("05:DMA Memory:PCIE_DmaWrite failed\r\n");
   }      

   //send write subject command
   command = WRITE_SUBJECT;
   bPass = PCIE_Write32(hPCIe, DEMO_PCIE_USER_BAR, DEMO_PCIE_IO_LED_ADDR, command);
   if (bPass)
      printf("Command =%xh\n", command);
   else
      printf("Failed to write command %X\n",command);
  
   return bPass;
}

BOOL TEST_DMA_READ_DATABASE_MEMORY(PCIE_HANDLE hPCIe){
   BOOL bPass=TRUE;
   int i;
   strcpy(outdatabaseblock,"");
   
   const PCIE_LOCAL_ADDRESS LocalAddr = DEMO_PCIE_MEM_SUBJECT_ADDR;

   // read back test pattern and verify

   
   if (bPass){
      bPass = PCIE_DmaRead(hPCIe, LocalAddr, outdatabaseblock, DATABASE_BLOCK_SIZE);
        
      if (!bPass){
         printf("06:DMA Memory:PCIE_DmaRead failed\r\n");
      }else{
         for(i=0; i<DATABASE_BLOCK_SIZE && bPass; i++){
          /*   if (outdatabaseblock[i] != indatabaseblock[i]){
               bPass = FALSE;
               printf("02:unmatch, index = %d, read=%2X, expected=%2X\n",
               i, (unsigned char)outdatabaseblock[i], (unsigned char)indatabaseblock[i]);
            } */
			printf("%2X ",(unsigned char)outdatabaseblock[i]);
         }
		 printf("\n");
      }
     if(bPass){
        printf("Read successful\n");
     }
     //printHexString(outdatabaseblock);
   }
    
   return bPass;
}

char all_memory_data[MEM_SIZE];

BOOL READ_ALL_MEMORY(PCIE_HANDLE hPCIe){
   BOOL bPass=TRUE;
   int i;
   
   FILE *fp;
   
   strcpy(all_memory_data,"");   
   const PCIE_LOCAL_ADDRESS LocalAddr = DEMO_PCIE_MEM_QUERY_ADDR;

   // read back test pattern and verify

   
   if (bPass){
      bPass = PCIE_DmaRead(hPCIe, LocalAddr, all_memory_data, MEM_SIZE);
        
      if (!bPass){
         printf("06:DMA Memory:PCIE_DmaRead failed\r\n");
      }else{
         for(i=0; i<MEM_SIZE && bPass; i++){
          /*   if (outdatabaseblock[i] != indatabaseblock[i]){
               bPass = FALSE;
               printf("02:unmatch, index = %d, read=%2X, expected=%2X\n",
               i, (unsigned char)outdatabaseblock[i], (unsigned char)indatabaseblock[i]);
            } */
			//printf("%2X ",(unsigned char)all_memory_data[i]);
         }
		 printf("\n");
      }
     if(bPass){
        printf("Read successful\n");
		   

        fp = fopen("ALL_MEMORY.HEX", "w+");
		for (i = 0 ; i < MEM_SIZE; i ++) {
			if( i %16 == 0) {
				fprintf(fp, "\n");
			}
			fprintf(fp, "%02X ",(unsigned char)all_memory_data[i]);
		}
        fclose(fp);
     }
     //printHexString(outdatabaseblock);
   }
    
   return bPass;
}
/* BOOL TEST_DMA_FIFO(PCIE_HANDLE hPCIe){
   BOOL bPass=TRUE;
   int i;
   const int nTestSize = FIFO_SIZE;
   const PCIE_LOCAL_ADDRESS FifoID_Write = DEMO_PCIE_FIFO_WRITE_ADDR;
   const PCIE_LOCAL_ADDRESS FifoID_Read = DEMO_PCIE_FIFO_READ_ADDR;
   char *pBuff;
   char szError[256];


   pBuff = (char *)malloc(nTestSize);
   if (!pBuff){
      bPass = FALSE;
      sprintf(szError, "DMA Fifo: malloc failed\r\n");
   }
   

   // init test pattern
   if (bPass){
      for(i=0;i<nTestSize;i++)
         *(pBuff+i) = PAT_GEN(170);
   }

   // write test pattern into fifo
   if (bPass){
      bPass = PCIE_DmaFifoWrite(hPCIe, FifoID_Write, pBuff, nTestSize);
      if (!bPass)
         sprintf(szError, "DMA Fifo: PCIE_DmaFifoWrite failed\r\n");
   }      

   // read back test pattern and verify
   if (bPass){
      memset(pBuff, 0, nTestSize); // reset buffer content
      bPass = PCIE_DmaFifoRead(hPCIe, FifoID_Read, pBuff, nTestSize);

      if (!bPass){
         sprintf(szError, "DMA Fifo: PCIE_DmaFifoRead failed\r\n");
      }else{
         for(i=0;i<nTestSize && bPass;i++){
            if (*(pBuff+i) != PAT_GEN(i)){
               bPass = FALSE;
               sprintf(szError, "DMA Fifo: Read-back verify unmatch, index = %d, read=%xh, expected=%xh\r\n", i, *(pBuff+i), PAT_GEN(i));
            }
         }
      }
   }


   // free resource
   if (pBuff)
      free(pBuff);
   
   if (!bPass)
      printf("%s", szError);
   else
      printf("DMA-Fifo (Size = %d byes) pass\r\n", nTestSize);


   return bPass;
}
 */

int main(void)
{
   void *lib_handle;
   PCIE_HANDLE hPCIE;
   BOOL bQuit = FALSE;
   int nSel;

   //file handle
   FILE *ptr_file;

   ptr_file = fopen(DATABASE_FILENAME, "r");
   if (!ptr_file){
      printf("00: Cant open %s database file", DATABASE_FILENAME);
      return 1;
   }
   
   printf("== Terasic: PCIe Demo Program ==\r\n");

   lib_handle = PCIE_Load();
   if (!lib_handle){
      printf("PCIE_Load failed!\r\n");
      return 0;
   }

   hPCIE = PCIE_Open(0,0,0);
   if (!hPCIE){
      printf("PCIE_Open failed\r\n");
   }else{
      while(!bQuit){
         UI_ShowMenu();
         nSel = UI_UserSelect();
         switch(nSel){   
//             case MENU_LED:
//               TEST_LED(hPCIE);
//               break;
            case MENU_READ_ALL_MEMORY:
			   READ_ALL_MEMORY(hPCIE);
			   break;
            case MENU_READ_HIT_SCORE:
               TEST_READ_SCORES(hPCIE);
               break;
//            case MENU_READ_DATABASE_FILE:
//               TEST_LOAD_DATABASE(ptr_file);
//               break; */
            case MENU_WRITE_DATABASE:
               TEST_DMA_WRITE_DATABASE_MEMORY(hPCIE, ptr_file);
               break;
            case MENU_READ_DATABASE:
               TEST_DMA_READ_DATABASE_MEMORY(hPCIE);
               break;
            case MENU_DMA_WRITE_MEMORY:
               TEST_DMA_WRITE_QUERY_MEMORY(hPCIE);
               break;
            case MENU_DMA_READ_MEMORY:
               TEST_DMA_READ_QUERY_MEMORY(hPCIE);
               break;
/*             case MENU_DMA_FIFO:
               TEST_DMA_FIFO(hPCIE);
               break; */
            case MENU_QUIT:
               bQuit = TRUE;
               printf("Bye!\r\n");
               break;
            default:
               printf("Invalid selection\r\n");
         } // switch

      }// while

      PCIE_Close(hPCIE);
      fclose(ptr_file);
   }


   PCIE_Unload(lib_handle);
   return 0;
}
