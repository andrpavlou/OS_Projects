#include "../include/threadfuncB.h"

struct shared_actions{
    int readA;
    int readB;
    int last_sentence;
    int running;
    int buff_full;

    int mes_receivedA;
    int mes_sentA;
    int mes_receivedB;
    int mes_sentB;
    int max_transfers;
    int current_transfers; 
    
    int mes_splitsA;
    int mes_splitsB;

    char read[BUFSIZ];
    char inp[TEXT_SZ];
    char exit[TEXT_EX];
    
    sem_t sem1;
    sem_t sem2;
    sem_t sem3;
};

void* fgets_tread(void* data){
    char outp[TEXT_SZ];
    struct shared_actions* share = (struct shared_actions*) data;

    fgets((char*)outp, TEXT_SZ, stdin);
    strncpy(share->inp, outp, TEXT_SZ);
    share->readB = 1;
}


void* outputB(void* data){
    struct shared_actions* share;
    share = (struct shared_actions*) data;
    char ex[EXIT_PROGRAM_CHARS + 2];
    strncpy(ex, share->exit, EXIT_PROGRAM_CHARS);
    strcat(ex, "\n");
    
    while(share->running){
        if(share->readA){
            while(share->max_transfers > share->current_transfers);

            share->mes_receivedB ++;
            int n = share->last_sentence;
            int size = strlen(share->read);
            int offset = size - n;
            
            char temp[TEXT_SZ];
            strncpy(temp, (share->read + offset), n + 1);
            
            //Prints the message if it will not cause buffer overflow.
            if(share->buff_full != 1)
                printf("\nPROCESS A WROTE:%s", temp);
            else{
                printf("\n\n\nCOULD NOT LOAD MESSAGE, TOO LONG OR BUFFER IS FULL.");
                printf("\nIF YOU SENT WAY T0O LONG MESSAGES TYPE:%s\n", EXIT_PROGRAM);
            }


            if(strcmp(temp, ex) == 0)
                share->running = 0;   

            share->readA = 0;
            sem_post(&share->sem1);
            sem_post(&share->sem2);
        }
    }
}

void* inputOutputB(void* data){
    struct shared_actions* share;
    share = (struct shared_actions*) data;

    pthread_t readfromB;
    while(share->running){
       
        share->max_transfers = 1;
        share->current_transfers = 0;

        printf("GIVE INPUT B:");
        pthread_create(&readfromB, NULL, fgets_tread, (void*)share);
        
        while(!share->readA && !share->readB);

        if(share->readA)
            pthread_cancel(readfromB);

        pthread_join(readfromB, NULL);

        sem_post(&share->sem1);
        sem_wait(&share->sem2);

        if(share->readB){    
            share->mes_sentB ++;
            char ex[EXIT_PROGRAM_CHARS + 1];
            char ex1[EXIT_PROGRAM_CHARS];

            if(strlen(share->inp) == EXIT_PROGRAM_CHARS + 1){
                strcat(ex1, share->inp);
                strncpy(ex, ex1, EXIT_PROGRAM_CHARS);
            }

            if(strlen(share->read) + strlen(share->inp) > BUFF_SIZE - EXIT_PROGRAM_CHARS && strcmp(ex, share->exit) != 0){
                long remaining = BUFF_SIZE - strlen(share->read) - EXIT_PROGRAM_CHARS - 1;

                share->buff_full = 1;

                printf("\n\n\nAFTER THIS MESSAGE BUFFER WILL FULL, TYPE %s OR TYPE A SMALLER MESSAGE.\n", EXIT_PROGRAM);
            }
            share->buff_full = 0;

            int lasti = strlen(share->inp) - 1;
            char temp[lasti + 1];

            share->last_sentence = lasti + 1;
            if(lasti <= 15){
                share->max_transfers = 1;
                share->mes_splitsB ++;
                strcat(share->read, share->inp);
                share->current_transfers ++;
            }
            if(lasti > 15){
                int transfers = lasti / 15;
                int rems = lasti % 15;
                if(!rems)
                    share->max_transfers = transfers;
                else   
                    share->max_transfers = transfers + 1;

                int itters = 0;

                while(itters < transfers){
                    strncpy(temp, share->inp + itters * 15, 15);
                    itters ++ ;
                    strcat(share->read, temp);
                    share->mes_splitsB ++;
                    share->current_transfers = itters;
                }
                if(rems >= 1){
                    char lasts[15];
                    strncpy(lasts, share->inp + (itters) * 15, 15);
                    strcat(share->read, lasts);
                    share->mes_splitsB ++;
                    share->current_transfers ++;
                }
            }
        }
        sem_wait(&share->sem2);
    }
}
