#include "../include/threadfuncA.h"


//Thread function, responsible to get user's input.(Used it as thread to cancel fgets if neeeded).
void* fgets_tread(void* data){

    struct Shared_actions* share = (struct Shared_actions*) data;
    char outp[TEXT_SZ];
    while(share->running){

        fgets((char*)outp, TEXT_SZ, stdin);
        strncpy(share->inp, outp, TEXT_SZ);
        share->mes_sentA ++;

        share->readA = 1;

        sem_post(&share->sem1);
        sem_post(&share->sem2);
    }
}


void* outputA(void* data){
    struct Shared_actions* share;
    share = (struct Shared_actions*) data;
    struct timeval curr_time;
    char ex[EXIT_PROGRAM_CHARS + 2];

    //Variable ex contains the string that terminates the processes, with the addition of change line at the end.
    //(as each input is registered with enter).
    strncpy(ex, share->exit, EXIT_PROGRAM_CHARS);
    strcat(ex, "\n");

    printf("---------- START CHATTING ----------\n");
    while(share->running){
        //Checks if the other process has registered an input.
        if(share->readB){
            //Wait for all the batches to arive, before printing the whole message.
            while(share->max_transfers > share->current_transfers && share->buff_full == 0){
                if(share->current_transfers == 1){
                    gettimeofday(&curr_time, NULL);
                    share->end_time = curr_time.tv_usec;
                }
            }

            if(share->end_time == 0 || share->max_transfers == 1){
                gettimeofday(&curr_time, NULL);
                share->end_time = curr_time.tv_usec;
            }


            int n = share->last_sentence;
            int size = strlen(share->read);
            int offset = size - n;
            
            char msg[TEXT_SZ]; //Contains the message
            strncpy(msg, (share->read + offset), n + 1);
            
            //Prints message depending on if it will cause buffer overflow.
            if(share->buff_full != 1){
                printf("PROCESS B WROTE:%s", msg);
                share->mes_receivedA ++;
            }
            else{
                printf("\n\n\nCOULD NOT LOAD MESSAGE, TOO LONG OR BUFFER IS FULL.");
                printf("\nIF YOU SENT WAY T0O LONG MESSAGES TYPE:%s\n", EXIT_PROGRAM);
            }

            //User has given the string that terminates the conversation.
            if(strcmp(msg, ex) == 0)
                share->running = 0;   

            share->readB = 0;

            if(strcmp(msg, "\n") != 0 && share->buff_full ==0)
                share->dif_timeA += abs(share->end_time - share->start_time);

            //Unblocks the input threads.
            sem_post(&share->sem1);
            sem_post(&share->sem2);
        }
    }
}

void* inputA(void* data){
    struct Shared_actions* share;
    share = (struct Shared_actions*) data;
    struct timeval current_time;
    
    pthread_t readfromA;
    pthread_create(&readfromA, NULL, fgets_tread, (void*)share);

    char ex[EXIT_PROGRAM_CHARS + 1];        
    strncpy(ex, share->exit, EXIT_PROGRAM_CHARS);
    strcat(ex, "\n");      
    

    while(share->running){
        share->max_transfers = 1;
        share->current_transfers = 0;
        share->end_time = 0;
        share->start_time = 0;
        share->buff_full = 0;
        share->readA = 0;
        share->readB = 0;
        

        //Rendez vous point between inputA and inputB.
        sem_wait(&share->sem1);
        sem_post(&share->sem2);

        //Waits untill the input is given.
        sem_wait(&share->sem1);


        //Splits the message into batches of 15 characters.
        if(share->readA){
            
            //Checks if the next message will cause buffer overflow and does not accept it, if it is too long.
            if(strlen(share->read) + strlen(share->inp) > BUFF_SIZE - 2 * EXIT_PROGRAM_CHARS  && strcmp(ex, share->inp) != 0){
                share->buff_full = 1;
                
                printf("\n\n\nAFTER THIS MESSAGE BUFFER WILL FULL, TYPE %s OR TYPE A SMALLER MESSAGE.\n", EXIT_PROGRAM);
            }

            long lasti = strlen(share->inp);

            char batch[BATCH_SIZE + 1]; 
            share->last_sentence = lasti;

            //If the message is less than 15 characters just add it to the end of the buffer.
            if(lasti <= 15){
                share->max_transfers = 1;
                share->mes_splitsA ++;
                strcat(share->read, share->inp);
                share->current_transfers ++;

                gettimeofday(&current_time, NULL);
                share->start_time = current_time.tv_usec;
            }

            //The message needs to be split.
            if(lasti > 15 && share->buff_full == 0){

                int transfers = lasti / 15;
                int rems = lasti % 15; //Remaining characters
                int itters = 0;

                if(rems == 0)
                    share->max_transfers = transfers;
                else   
                    share->max_transfers = transfers + 1;

                //Splits the message into batches of 15.
                while(itters < transfers){
                    strncpy(batch, share->inp + itters * 15, 15);
                    strcat(share->read, batch);
                    itters ++ ;
                    share->mes_splitsA ++;

                    share->current_transfers ++;
                    gettimeofday(&current_time, NULL);
                    share->start_time = current_time.tv_usec;
                }
                //Add the remaining none 15 characters the buffer.
                if(rems >= 1){
                    strncpy(batch, share->inp + (itters) * 15, 15);
                    strcat(share->read, batch);

                    share->mes_splitsA ++;
                    share->current_transfers ++;
                }
            }
        }
        //Waits until the threads, responsible for the print of the message unblock.
        sem_wait(&share->sem1);
    }
    pthread_cancel(readfromA);

    pthread_join(readfromA, NULL);
}
