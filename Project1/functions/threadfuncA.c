#include "../include/threadfuncA.h"


//Function that will be called for pthread_create in order to be able to exit fgets.
void* fgets_tread(void* data){
    char outp[TEXT_SZ];
    struct Shared_actions* share = (struct Shared_actions*) data;

    fgets((char*)outp, TEXT_SZ, stdin);
    strncpy(share->inp, outp, TEXT_SZ);
    share->readA = 1;
}


void* outputA(void* data){
    struct Shared_actions* share;
    share = (struct Shared_actions*) data;

    char ex[EXIT_PROGRAM_CHARS + 2];
    strncpy(ex, share->exit, EXIT_PROGRAM_CHARS);
    strcat(ex, "\n");

    while(share->running){
        if(share->readB){
            while(share->max_transfers > share->current_transfers);
        

            share->mes_receivedA ++;
            int n = share->last_sentence;
            int size = strlen(share->read);
            int offset = size - n;
            
            char temp[TEXT_SZ];
            strncpy(temp, (share->read + offset), n + 1);
            
            //Prints the message if it will not cause buffer overflow.
            if(share->buff_full != 1)
                printf("\nPROCESS B WROTE:%s", temp);
            else{
                printf("\n\n\nCOULD NOT LOAD MESSAGE, TOO LONG OR BUFFER IS FULL.");
                printf("\nIF YOU SENT WAY T0O LONG MESSAGES TYPE:%s\n", EXIT_PROGRAM);
            }

            if(strcmp(temp, ex) == 0)
                share->running = 0;   
            

            share->readB = 0;
            sem_post(&share->sem1);
            sem_post(&share->sem2);
        }
    }
}

void* inputOutputA(void* data){
    struct Shared_actions* share;
    share = (struct Shared_actions*) data;
    pthread_t readfromA;

    int running = 1;
    while(share->running){
        share->max_transfers = 1;
        share->current_transfers = 0;
        
        
        //Thread responsible to get the input of other process.
        printf("GIVE INPUT A:");
        pthread_create(&readfromA, NULL, fgets_tread, (void*)share);

        //Stucks inside while loop until one process gives input, so the other one can cancel fgets_tread to exit fgets.
        while(!share->readA && !share->readB);

        //Cancel the thread to exit fgets because the other process has given an input.
        if(share->readB)
            pthread_cancel(readfromA);

        pthread_join(readfromA, NULL);

        sem_wait(&share->sem1);
        sem_post(&share->sem2);

        if(share->readA){
            share->mes_sentA ++;
            char ex[EXIT_PROGRAM_CHARS + 1];
            char ex1[EXIT_PROGRAM_CHARS];

            if(strlen(share->inp) == EXIT_PROGRAM_CHARS + 1){
                strcat(ex1, share->inp);
                strncpy(ex, ex1, EXIT_PROGRAM_CHARS);
            }

            if(strlen(share->read) + strlen(share->inp) > BUFF_SIZE - EXIT_PROGRAM_CHARS  && strcmp(ex, share->exit) != 0){
                long remaining = BUFF_SIZE - strlen(share->read) - EXIT_PROGRAM_CHARS - 1;

                share->buff_full = 1;
                
                printf("\n\n\nAFTER THIS MESSAGE BUFFER WILL FULL, TYPE %s OR TYPE A SMALLER MESSAGE.\n", EXIT_PROGRAM);
            }
            share->buff_full = 0;

            int lasti = strlen(share->inp) - 1;
            char temp[lasti + 1];
            share->last_sentence = lasti + 1;

            //If the message is less than 15 characters just add it to the end of the buffer.
            if(lasti <= 15){
                share->max_transfers = 1;
                share->mes_splitsA ++;
                strcat(share->read, share->inp);
                share->current_transfers ++;
            }

            if(lasti > 15){
                int transfers = lasti / 15;
                int rems = lasti % 15;
                int itters = 0;
                if(!rems)
                    share->max_transfers = transfers;
                else   
                    share->max_transfers = transfers + 1;

                //Break the message into batches of 15.
                while(itters < transfers){
                    strncpy(temp, share->inp + itters * 15, 15);
                    itters ++ ;
                    strcat(share->read, temp);
                    share->mes_splitsA ++;
                    share->current_transfers ++;
                }

                //Add the remaining none 15 characters the buffer.
                if(rems >= 1){
                    char lasts[15];
                    strncpy(lasts, share->inp + (itters) * 15, 15);
                    strcat(share->read, lasts);
                    share->mes_splitsA ++;
                    share->current_transfers ++;
                }
            }
        }
      
        sem_wait(&share->sem1);

    }
}
