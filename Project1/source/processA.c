#define TEXT_SZ 2048
#define EXIT_PROGRAM "#BYE#"


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




#define SEM_PERMS (S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP)
#define INITIAL_VALUE 0

struct shared_actions{
    int readi;
    char write[TEXT_SZ];
    char read[TEXT_SZ];
    char exit[5];
    sem_t sem1;
    sem_t sem2;
};



void* input(void* data);


int main(){

    char* buffer = malloc(sizeof(BUFSIZ));
    // struct shared_actions actions0;
    struct shared_actions* actions = malloc(sizeof(struct shared_actions));
    // actions = &actions0;

    strcpy(actions->exit, EXIT_PROGRAM);

    //key??
    key_t key; 

    int shmid;
    shmid = shmget((key_t)12345, sizeof(struct shared_actions), 0666 | IPC_CREAT);
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
    int running = 1;


    actions = (struct shared_actions *)shared_memory;

    //1 is to be shared across other proccesses
    //TODO: elegox gia fail
    sem_init(&actions->sem1, 1, INITIAL_VALUE);
    sem_init(&actions->sem2, 1, INITIAL_VALUE);
    


    // pthread_t th_input;
    // int it = 0;


    // actions->readi = 1;

    // pthread_cancel(th_input);

    ////////////////////////////////


    while(running){
        printf("BLOCKED A: \n");        
        // sem_wait(&actions->sem1);
        int value;
        sem_getvalue(&actions->sem1, &value);
        printf("%d\n",value);

        // while(actions->readi){
        //     pthread_create(&th_input, NULL, input, (void*)actions);
        //     pthread_join(th_input, NULL);
        // }

        //Randevou point.

        printf("EXITING A: \n");
        running = 1;
    }


    //TODO: create thread to exit
    //destroy sems
    if (shmdt(shared_memory) == -1) {
		fprintf(stderr, "shmdt failed\n");
		exit(EXIT_FAILURE);
	}
	if (shmctl(shmid, IPC_RMID, 0) == -1) {
		fprintf(stderr, "shmctl(IPC_RMID) failed\n");
		exit(EXIT_FAILURE);
	}
}


void* input(void* data){
    // char* inp = malloc(sizeof(BUFSIZ));
    // inp = (char*)data;
    struct shared_actions* share = malloc(sizeof(struct shared_actions));
    share = (struct shared_actions*) data;
    

    printf("FROM THREAD\n");

    while(share->readi){
	    fgets((char*)share->read, BUFSIZ, stdin);
        share->readi = 0;
    }
}
