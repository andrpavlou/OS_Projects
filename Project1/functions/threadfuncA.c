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
    char exit[TEXT_EX];
    sem_t sem1;
    sem_t sem2;
    sem_t sem3;
};

void* outputA(void* data){   
    struct shared_actions* share;
    share = (struct shared_actions*) data;

    int n = share->last_sentence;

    int size = strlen(share->read);
    int offset = size - n;
    
    char* temp = malloc((n) * sizeof(char));

    strncpy(temp, (share->read + offset), n);

    if(share->buff_full != 1)
        printf("\nPROCESS B WROTE:%s", temp);
    else{
        printf("\n\n\nCOULD NOT LOAD MESSAGE, TOO LONG OR BUFFER IS FULL.");
        printf("\nIf YOU SENT WAY TOO LONG MESSAGES TYPE:%s\n", EXIT_PROGRAM);
    }

    char ex[EXIT_PROGRAM_CHARS];
    if(strlen(temp) == EXIT_PROGRAM_CHARS + 1)
        strncpy(ex, temp, EXIT_PROGRAM_CHARS);

    if(strcmp(ex, share->exit) == 0)
        share->running = 0;

    free(temp);
}

void* inputA(void* data){
    char outp[BUFF_SIZE];

    struct shared_actions* share;
    share = (struct shared_actions*) data;
    
    printf("GIVE INPUT A:");

	fgets((char*)outp, BUFSIZ, stdin);
    share->readA = 1;

    char ex[EXIT_PROGRAM_CHARS + 1];
    char ex1[EXIT_PROGRAM_CHARS];
    if(strlen(outp) == EXIT_PROGRAM_CHARS + 1){
        strcat(ex1, outp);
        strncpy(ex, ex1, EXIT_PROGRAM_CHARS);
    }


    if(strlen(share->read) + strlen(outp) > BUFF_SIZE - EXIT_PROGRAM_CHARS  && strcmp(ex, share->exit) != 0){
        long remaining = BUFF_SIZE - strlen(share->read) - EXIT_PROGRAM_CHARS - 1;

        share->buff_full = 1;
        
        printf("\n\n\nAFTER THIS MESSAGE BUFFER WILL FULL, ONLY %ld CHARACTERS REMAINING, TYPE %s OR TYPE A SMALLER MESSAGE.\n", remaining, EXIT_PROGRAM);
        return 0;
    }
    
    share->buff_full = 0;

    int lasti = strlen(outp) - 1;
    char temp[lasti + 1];
    share->last_sentence = lasti + 1;

    if(lasti <= 15){
        share->mes_splitsA ++;
        strcat(share->read, outp);
    }
    if(lasti > 15){
        int transfers = lasti / 15;
        int rems = lasti % 15;
        int itters = 0;
        while(itters < transfers){
            strncpy(temp, outp + itters * 15, 15);
            itters ++ ;
            strcat(share->read, temp);
            share->mes_splitsA ++;
        }
        if(rems >= 1){
            char lasts[15];
            strncpy(lasts, outp + (itters) * 15, 15);
            strcat(share->read, lasts);
            share->mes_splitsA ++;
        }
    }
    return 0;    
}
