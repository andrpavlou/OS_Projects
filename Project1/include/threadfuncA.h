
#ifndef THREADFUNCA_H_   /* Include guard */
#define THREADFUNCA_H_

#define TEXT_SZ 2048
#define TEXT_EX 5
#define BATCH_SIZE 15
#define EXIT_PROGRAM "#BYE#"
#define EXIT_PROGRAM_CHARS 5
#define BUFF_SIZE  BUFSIZ / 2 //4096 default buffersize
#define KEY 3333335

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
#include <sys/time.h>

#define SEM_PERMS (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP)
#define INITIAL_VALUE 0



typedef struct Shared_actions{
    int readA;
    int readB;
    int last_sentence;
    int running;
    int buff_full;
    int max_transfers;
    int current_transfers; 

    int mes_receivedA;
    int mes_sentA;
    int mes_receivedB;
    int mes_sentB;
    
    int mes_splitsA;
    int mes_splitsB;

    long start_time;
    long end_time;
    long dif_timeA;
    long dif_timeB;
    
    char read[BUFSIZ];
    char inp[TEXT_SZ];
    char exit[TEXT_EX];

    sem_t sem1;
    sem_t sem2;
    sem_t sem3;
}Shared_actions;


void* inputA(void* data);
void* outputA(void* data);

#endif 

