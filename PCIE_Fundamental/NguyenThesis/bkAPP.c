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