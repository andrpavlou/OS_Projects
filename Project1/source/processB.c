#define TEXT_SZ 2048
#define TEXT_EX 5
#define EXIT_PROGRAM "#BYE#"
#define EXIT_PROGRAM_CHARS 5
#define KEY 1010556

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
    int running;
    int total_size;
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

    actions->running = 1;
    actions->total_size = 0;
    int running = 1;

    while(running){

        sem_post(&actions->sem1);
        sem_wait(&actions->sem3);

        if(!actions->running)
            break;

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
        if(actions->readA)
            pthread_join(th_output, NULL);
        
        actions->readB = 0;
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

    int n = share->last_sentence;

    int size = strlen(share->read);
    int offset = size - n;

    char* temp = malloc((n) * sizeof(char));

    strncpy(temp, (share->read + offset), n);


    printf("\nPROCESS A WROTE: %s", temp);

    char ex[EXIT_PROGRAM_CHARS];
    strncpy(ex, temp, EXIT_PROGRAM_CHARS);

    if(strcmp(ex, share->exit) == 0)
        share->running = 0;

    temp = NULL;
    free(temp);
}

void* input(void* data){
    char outp[BUFSIZ];

    struct shared_actions* share;
    share = (struct shared_actions*) data;
    
    printf("GIVE INPUT B:");

	fgets((char*)outp, BUFSIZ, stdin);
    share->readB = 1;
    
    if(strlen(share->read) + strlen(outp) > BUFSIZ - EXIT_PROGRAM_CHARS){
        long remaining = BUFSIZ - strlen(share->read) - EXIT_PROGRAM_CHARS - 1;
        printf("AFTER THIS MESSAGE BUFFER WILL FULL, ONLY %ld CHARACTERS REMAINING, TYPE #BYE# OR TYPE A SMALLER MESSAGE", remaining);
        return 0;
    }

    int lasti = strlen(outp) - 1;
    char temp[lasti + 1];

    share->last_sentence = lasti + 1;
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
            char lasts[15];
            strncpy(lasts, outp + (itters) * 15, 15);
            strcat(share->read, lasts);
        }
    }

    return 0;    
}
  



