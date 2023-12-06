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

//Function that will be called for pthread_create in order to be able to exit fgets.
void* fgets_tread(void* data){
    char outp[TEXT_SZ];
    struct shared_actions* share = (struct shared_actions*) data;

    fgets((char*)outp, TEXT_SZ, stdin);
    strncpy(share->inp, outp, TEXT_SZ);
    share->readA = 1;
}


void* inputOutputA(void* data){
    struct shared_actions* share;
    share = (struct shared_actions*) data;
    pthread_t readfromA;

    int running = 1;
    while(share->running){

            share->readA = 0;
            share->readB = 0;


            printf("GIVE INPUT A:");

            //Thread responsible to get the input of other process.
            pthread_create(&readfromA, NULL, fgets_tread, (void*)share);

            //Stucks inside while loop until one process gives input, so the other one can cancel fgets_tread to exit fgets.
            while(!share->readA && !share->readB);

            //Cancel the thread to exit fgets because the other process has given an input.
            if(share->readB)
                pthread_cancel(readfromA);

            pthread_join(readfromA, NULL);
        
        //If process A has given an input break the message into batches of 15 characters.
        if(share->readA){
            share->mes_sentA ++;
            char ex[EXIT_PROGRAM_CHARS + 1];
            char ex1[EXIT_PROGRAM_CHARS];

            if(strlen(share->inp) == EXIT_PROGRAM_CHARS + 1){
                strcat(ex1, share->inp);
                strncpy(ex, ex1, EXIT_PROGRAM_CHARS);
            }

            //Checks if the next message will cause buffer overflow, and prints the warning message.
            if(strlen(share->read) + strlen(share->inp) > BUFF_SIZE - EXIT_PROGRAM_CHARS  && strcmp(ex, share->exit) != 0){
                long remaining = BUFF_SIZE - strlen(share->read) - EXIT_PROGRAM_CHARS - 1;

                share->buff_full = 1;
                
                printf("\n\n\nAFTER THIS MESSAGE BUFFER WILL FULL, ONLY %ld CHARACTERS REMAINING, TYPE %s OR TYPE A SMALLER MESSAGE.\n", remaining, EXIT_PROGRAM);
            }
            
            share->buff_full = 0;

            int lasti = strlen(share->inp) - 1;
            char temp[lasti + 1];
            share->last_sentence = lasti + 1;

            //If the message is less than 15 characters just add it to the end of the buffer.
            if(lasti <= 15){
                share->mes_splitsA ++;
                strcat(share->read, share->inp);
            }

            if(lasti > 15){
                int transfers = lasti / 15;
                int rems = lasti % 15;
                int itters = 0;
                //Break the message into batches of 15.
                while(itters < transfers){
                    strncpy(temp, share->inp + itters * 15, 15);
                    itters ++ ;
                    strcat(share->read, temp);
                    share->mes_splitsA ++;
                }

                //Add the remaining none 15 characters the buffer.
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

        //Other process has given an input.
        if(share->readB){
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
