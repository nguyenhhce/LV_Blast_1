#include <stdio.h>
#include <string.h>

#define DATABASE_FILENAME "nc1130_flat"  // 4689005 byte of data
#define DATABASE_LINEWIDTH 100
#define DATABASW_CONVERT_BYTE DATABASE_LINEWIDTH/3 + 1


int main()
{
	bool found = false;
	bool number_flag = true;
	FILE *ptr_file;
	char buf[1000];
	char *database_temp;
	char database_line[DATABASE_LINEWIDTH] = "";
	char database_convert_byte[DATABASE_LINEWIDTH / 3 + 1] = "";
	char delimiter[] = " ";
	char startMakerdata[] = "ORIGIN";
	char endMakerdata[] = "//";
	int  StartMarkersize = sizeof(startMakerdata)-1;
	int  EndMarkersize = sizeof(endMakerdata)-1;

	int  bytecounter = 0;
	int  linecounter = 0;
	ptr_file = fopen(DATABASE_FILENAME, "r");
	if (!ptr_file){
		printf("00: Cant open %s file", DATABASE_FILENAME);
		return 1;
	}
	int i = 0;
	while (fgets(buf, 1000, ptr_file) != NULL)

		//   while (i <=10000)
	{
		//   fgets(buf, 1000, ptr_file);
		//printf("%s", buf);
		i++;
		linecounter++;
		if (found)
		{
			if (strncmp(buf, endMakerdata, EndMarkersize) == 0)
			{
				//printf("[Binh]%s", buf);
				found = false;
			}
			else
			{
				/* get the first token */
				database_temp = strtok(buf, delimiter);
				number_flag = true;
				/* walk through other tokens */
				strcpy(database_line, "");
				while (database_temp != NULL){

					if (number_flag == false){
						//printf("%s", database_temp);
						strcat(database_line, database_temp);
					}
					else
					{
						number_flag = false;
					}
					database_temp = strtok(NULL, delimiter);
				}
				//            //printf(database_line);
				CovertQuery2Bit(database_line, strlen(database_line),
					database_convert_byte, strlen(database_line) / 3 + 1);
				print(database_convert_byte);
				bytecounter += strlen(database_line);
			}
		}
		else if (strncmp(buf, startMakerdata, StartMarkersize) == 0){
			//printf("[Binh] %s", buf);
			found = true;
		}
	}

	printf("#line: %d", linecounter);
	printf("#byte: %d", bytecounter);

	fclose(ptr_file);
	return 0;

}