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
int main(){
    struct shared_actions actions0;
    struct shared_actions* actions;

    actions = &actions0;
    strcpy(actions->exit, EXIT_PROGRAM);

    char buffer[BUFSIZ];
    key_t key = KEY; 
    // if(key = ftok("proccessB", 'B') == - 1){    
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


    int running = 1;
    actions = (struct shared_actions *)shared_memory;
    pthread_t th_input, th_output;
    int *th_ret;

    while(running != 4){
        // printf("B IS TRYING TO UNBLOCK A \n");

        sem_post(&actions->sem1);
        pthread_create(&th_input, NULL, input, (void*)actions);

        while(!actions->readB && !actions->readA);

        if(actions->readA)
            pthread_cancel(th_input);

        pthread_join(th_input, (void**)&th_ret);

        if(actions->readB)
            sem_wait(&actions->sem2);

        if(actions->readA){
            pthread_create(&th_output, NULL, output, (void*)actions);
            sem_post(&actions->sem2);
        }
        pthread_join(th_output, NULL);

        actions->readB = 0;
        // printf("PROCB IS EXITING....\n");
        running++;
        // printf(" %s ", actions->read);
    }

    //TODO: create thread to exit
    if (shmdt(shared_memory) == -1) {
		fprintf(stderr, "shmdt failed\n");
		exit(EXIT_FAILURE);
	}
	if (shmctl(shmid, IPC_RMID, 0) == -1) {
		fprintf(stderr, "shmctl(IPC_RMID) failed\n");
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
    
    printf("GIVE INPUT B:\n");

	fgets((char*)outp, BUFSIZ, stdin);

    share->readB = 1;

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



