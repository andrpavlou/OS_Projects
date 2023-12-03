#include "../include/threadfuncA.h"

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
    share->readA = 1;
}

void* inputA(void* data){
    struct shared_actions* share;
    share = (struct shared_actions*) data;
    pthread_t readfromA;

    int running = 1;
    while(share->running){

            share->readA = 0;
            share->readB = 0;
        
            printf("GIVE INPUT A:");

            pthread_create(&readfromA, NULL, fgets_tread, (void*)share);
            while(!share->readA && !share->readB);

            if(share->readB)
                pthread_cancel(readfromA);

            pthread_join(readfromA, NULL);
        
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
                
                printf("\n\n\nAFTER THIS MESSAGE BUFFER WILL FULL, ONLY %ld CHARACTERS REMAINING, TYPE %s OR TYPE A SMALLER MESSAGE.\n", remaining, EXIT_PROGRAM);
            }
            
            share->buff_full = 0;

            int lasti = strlen(share->inp) - 1;
            char temp[lasti + 1];
            share->last_sentence = lasti + 1;

            if(lasti <= 15){
                share->mes_splitsA ++;
                strcat(share->read, share->inp);
            }
            if(lasti > 15){
                int transfers = lasti / 15;
                int rems = lasti % 15;
                int itters = 0;
                while(itters < transfers){
                    strncpy(temp, share->inp + itters * 15, 15);
                    itters ++ ;
                    strcat(share->read, temp);
                    share->mes_splitsA ++;
                }
                if(rems >= 1){
                    char lasts[15];
                    strncpy(lasts, share->inp + (itters) * 15, 15);
                    strcat(share->read, lasts);
                    share->mes_splitsA ++;
                }
            }
        }
        
        sem_wait(&share->sem1);
        sem_post(&share->sem3);

        if(share->readB){
            share->mes_receivedA ++;
            int n = share->last_sentence;
            int size = strlen(share->read);
            int offset = size - n;
            
            char temp[TEXT_SZ];
            strncpy(temp, (share->read + offset), n + 1);

            if(share->buff_full != 1)
                printf("\nPROCESS A WROTE:%s", temp);
            else{
                printf("\n\n\nCOULD NOT LOAD MESSAGE, TOO LONG OR BUFFER IS FULL.");
                printf("\nIF YOU SENT WAY T0O LONG MESSAGES TYPE:%s\n", EXIT_PROGRAM);
            }

            char ex[EXIT_PROGRAM_CHARS];
            if(strlen(temp) == EXIT_PROGRAM_CHARS + 1)
                strncpy(ex, temp, EXIT_PROGRAM_CHARS);

            if(strcmp(ex, share->exit) == 0)
                share->running = 0;   
        }
        sem_wait(&share->sem1);
        sem_post(&share->sem3);
    }
}
