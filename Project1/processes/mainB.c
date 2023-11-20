#define TEXT_SZ 2048
#define TEXT_EX 5
#define EXIT_PROGRAM "#BYE#"
#define EXIT_PROGRAM_CHARS 5
#define BUFF_SIZE BUFSIZ / 2 //4096 default buffer
#define KEY 12121

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/shm.h>
#include <fcntl.h>
#include <semaphore.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <pthread.h>
#include "../include/threadfuncB.h"



#define SEM_PERMS (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP)
#define INITIAL_VALUE 0

struct shared_actions{
    int readA;
    int readB;
    int last_sentence;
    int running;
    int buff_full;

    int mes_receivedA;
    int mes_receivedB;
    int mes_sentA;
    int mes_sentB;

    int mes_splitsA;
    int mes_splitsB;

    char read[BUFSIZ];
    char exit[TEXT_EX];
    sem_t sem1;
    sem_t sem2;
    sem_t sem3;
};

int main(){
    struct shared_actions actions0;
    struct shared_actions* actions;

    actions = &actions0;
    strncpy(actions->exit, EXIT_PROGRAM, EXIT_PROGRAM_CHARS);
    actions->running = 1;
    actions->buff_full = 0;

    actions->mes_receivedA = 0;
    actions->mes_sentA = 0;
    actions->mes_receivedB = 0;
    actions->mes_sentB = 0;

    actions->mes_splitsA = 0;
    actions->mes_splitsB = 0;

    key_t key = KEY; 


    int shmid;
    shmid = shmget(key, sizeof(struct shared_actions), 0666 | IPC_CREAT);
    if (shmid == -1) {
        fprintf(stderr, "Shmget Failed\n");
        exit(EXIT_FAILURE);
    }
    void *shared_memory = (void *)0;
    shared_memory = shmat(shmid, (void *)0, 0);
    if (shared_memory == (void *)-1) {
        fprintf(stderr, "Shmat Failed\n");
        exit(EXIT_FAILURE);
    }
    printf("Shared memory segment with id %d attached at %p\n", shmid, shared_memory);


    actions = (struct shared_actions *)shared_memory;
    pthread_t th_input, th_output;
    int *th_ret;

    strncpy(actions->exit, EXIT_PROGRAM, EXIT_PROGRAM_CHARS);


    int running = 1;
    while(running){

        sem_post(&actions->sem1);
        sem_wait(&actions->sem3);

        if(!actions->running)
            break;

        pthread_create(&th_input, NULL, inputB, (void*)actions);

        while(!actions->readB && !actions->readA);

        if(actions->readA)
            pthread_cancel(th_input);

        pthread_join(th_input, (void**)&th_ret);

        if(actions->readB){
            actions->mes_sentB ++;
            sem_wait(&actions->sem2);
        }
        if(actions->readA){
            pthread_create(&th_output, NULL, outputB, (void*)actions);
            sem_post(&actions->sem2);
            actions->mes_receivedB ++;
        }
        if(actions->readA)
            pthread_join(th_output, NULL);
        
        actions->readB = 0;
    }
     
    float splitspmsg = 0;
    if(actions->mes_sentB !=0)
        splitspmsg = (float)actions->mes_splitsB / actions->mes_sentB;

    sem_wait(&actions->sem2);
    printf("\n\n\n\n\n\n\n");
    printf("---------- CHAT SUMMARRY ----------\n");
    printf("MESSAGE SENT:%d\n", actions->mes_sentB);
    printf("MESSAGE RECEIVED:%d\n", actions->mes_receivedB);
    printf("MESSAGE SPLITS IN TOTAL:%d\n", actions->mes_splitsB);
    printf("MESSAGE SPLITS PER MESSAGE:%f\n", splitspmsg);

    sem_post(&actions->sem1);
}
 
