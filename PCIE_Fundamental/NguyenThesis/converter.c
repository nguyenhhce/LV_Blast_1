#include <stdio.h>
#include "converter.h"
#include <string.h>

void printHexString(char indata[]){
	int i = 0;
	printf("Query in HEX: ");
	for (i = 0; indata[i] != 0; i++){
		printf("%02X ", (unsigned char)indata[i]);
	}
	printf("\nEND OF HEX STRING[%d]\n",i);
}
int CovertQuery2Bit(char indata[], int indata_size,
	char outdata[], int begin_idx){
	int i;
	int temp_base;
	int temp_offset;
	int temp_value;

	//clear outdata
	for(i = 0; i <indata_size/3 + 1; i ++)
	{
		outdata[i] = 0;
	}
	if(begin_idx > 0){
		strncpy(outdata, indata, begin_idx);
	}
	temp_base = begin_idx;
	temp_offset = 0;
	for (i = 0; i < indata_size && indata[i] != 0 && indata[i] != 10; i++){

		if (indata[i] == 'a')      { indata[i] = 'A'; }
		else if (indata[i] == 'g') { indata[i] = 'G'; }
		else if (indata[i] == 't') { indata[i] = 'T'; }
		else if (indata[i] == 'c') { indata[i] = 'C'; }
		else if (indata[i] == 'n') { indata[i] = 'N'; }

		if (indata[i] == 'A')      { temp_value = A_ADN << temp_offset; }
		else if (indata[i] == 'G') { temp_value = G_ADN << temp_offset; }
		else if (indata[i] == 'T') { temp_value = T_ADN << temp_offset; }
		else if (indata[i] == 'C') { temp_value = C_ADN << temp_offset; }
		else if (indata[i] == 'N') { temp_value = N_ADN << temp_offset; }
		else {
			printf("00:invalid query at index %d, content [%d]", i, indata[i]);
			return -1;
		}
		outdata[temp_base] |= temp_value;
		//printf("[%d][%c][BASE %d][offset %d][CONVERT %d][TEMP VALUE %d]\n",i, indata[i],temp_base, temp_offset, outdata[temp_base], temp_value );
		if (temp_offset == 6){
			temp_base++;
			temp_offset = 1;
			if (indata[i] == 'A')      { temp_value = A_ADN >> 2; }
			else if (indata[i] == 'G') { temp_value = G_ADN >> 2; }
			else if (indata[i] == 'T') { temp_value = T_ADN >> 2; }
			else if (indata[i] == 'C') { temp_value = C_ADN >> 2; }
			else if (indata[i] == 'N') { temp_value = N_ADN >> 2; }
			else {
				printf("01:invalid query at index %d, content [%c]", i, indata[i]);
				return -1;
			}
			outdata[temp_base] |= temp_value;
		}
		else if (temp_offset == 7){
			temp_base++;
			temp_offset = 2;
			if (indata[i] == 'A')      { temp_value = A_ADN >> 1; }
			else if (indata[i] == 'G') { temp_value = G_ADN >> 1; }
			else if (indata[i] == 'T') { temp_value = T_ADN >> 1; }
			else if (indata[i] == 'C') { temp_value = C_ADN >> 1; }
			else if (indata[i] == 'N') { temp_value = N_ADN >> 1; }
			else {
				printf("02:invalid query at index %d, content [%c]", i, indata[i]);
				return -1;
			}
			outdata[temp_base] |= temp_value;
		}
		else{
			temp_offset += 3;
			if (temp_offset == 8){
				temp_base++;
				temp_offset = 0;
			}
		}
		//printf("  [%d][%c][BASE %d][offset %d][CONVERT %d][TEMP VALUE %d]\n",i, indata[i],temp_base, temp_offset, outdata[temp_base], temp_value );
	}
	if(outdata[temp_base] != 0) {
		outdata[temp_base + 1] = 0;
	}
	return 0;
}