#define TEXT_SZ 2048
#define TEXT_EX 5
#define EXIT_PROGRAM "#BYE#"
#define KEY 101011



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


void* input(void* data);
void* output(void* data);

#define SEM_PERMS (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP)
#define INITIAL_VALUE 0

struct shared_actions{
    int readA;
    int readB;
    int last_sentence;
    char write[TEXT_SZ];
    char read[TEXT_SZ];
    char exit[TEXT_EX];
    sem_t sem1;
    sem_t sem2;
};

long th_ret = 0; 

int main(){

    struct shared_actions actions0;
    struct shared_actions* actions ;
    actions = &actions0;
    actions->readA = 0;
    actions->readA = 0;
    strcpy(actions->exit, EXIT_PROGRAM);
    char buffer[BUFSIZ];
    key_t  key = KEY; 

    // if(key = ftok("proccessA", 'A') == - 1){    
    //     fprintf(stderr, "Key Creation Failed\n");
    //     exit(EXIT_FAILURE);
    // }

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
    actions->readA = 0;


    //1 is to be shared across other proccesses
    //TODO: elegox gia fail
    sem_init(&actions->sem1, 1, INITIAL_VALUE);
    sem_init(&actions->sem2, 1, INITIAL_VALUE);

    pthread_t th_input, th_output;

    //free at the end
    int *th_ret;
    int running = 1;
    while(running != 4){
        // printf("BLOCKED A: \n");        

        sem_wait(&actions->sem1);
        pthread_create(&th_input, NULL, input, (void*)actions);
        // if(actions->ReadB)
        //     pthread_cancel(th_input); 
        
        while(!actions->readB && !actions->readA);
        
        if(actions->readB)
            pthread_cancel(th_input);

        pthread_join(th_input, (void**)&th_ret);

        // printf("UNBLOCKED A: \n");
        
        if(actions->readA)
            sem_wait(&actions->sem2);

        if(actions->readB){
            pthread_create(&th_output, NULL, output, (void*)actions);
            sem_post(&actions->sem2);
        }
        pthread_join(th_output, NULL);

        running++;
        actions->readA = 0;
        // sem_wait(&actions->sem1);
    }



    //TODO: create thread to exit
    if (shmdt(shared_memory) == -1) {
		fprintf(stderr, "shmdt failed\n");
		exit(EXIT_FAILURE);
	}
}

void* output(void* data){   
    struct shared_actions* share;
    share = (struct shared_actions*) data;

    printf("YOU WROTE: %s", share->read);
}



void* input(void* data){
    // char* inp = malloc(sizeof(BUFSIZ));
    // inp = (char*)data;
    char outp[BUFSIZ];

    struct shared_actions* share;
    share = (struct shared_actions*) data;
    

    printf("GIVE INPUT A:\n");


	fgets((char*)outp, BUFSIZ, stdin);

    share->readA = 1;

    int lasti = 0;
    char last = outp[lasti];
    while(last != '\0'){
        lasti++;
        last = outp[lasti];
    }

    char temp[BUFSIZ];
    lasti -= 1;
    share->last_sentence = lasti;

    if(lasti <= 15)
        strcat(share->read, outp);

    if(lasti > 15){
        int transfers = lasti / 15;
        int rems = lasti % 15;
        int itters = 0;

        while(itters < transfers){
            strncpy(temp, outp + itters * 15, 15);
            itters ++ ;
            strcat(share->read, temp);
        }
        if(rems >= 1){
            char lasts[rems];

            strncpy(lasts, outp + (itters) * 15, 14);
            strcat(share->read, lasts);
            
        }
    }

    
    int* outp1 = malloc(sizeof(int));
    int num = 1;
    *outp1 = num;
  
    return (void*) outp1;    
}
