#include "../include/threadfuncB.h"



int main(){
    struct Shared_actions actions0;
    struct Shared_actions* actions;
    actions = &actions0;

    key_t key = KEY; 

    //Creates a new shared memory segment, givem a key.
    int shmid;
    shmid = shmget(key, sizeof(struct Shared_actions), 0666 | IPC_CREAT);
    if (shmid == -1) {
        fprintf(stderr, "Shmget Failed\n");
        exit(EXIT_FAILURE);
    }
    
    //Attach shared memory.
    void *shared_memory = (void *)0;
    shared_memory = shmat(shmid, (void *)0, 0);

    if (shared_memory == (void *)-1) {
        fprintf(stderr, "Shmat Failed\n");
        exit(EXIT_FAILURE);
    }
    printf("Shared memory segment with id %d attached at %p\n", shmid, shared_memory);


    actions = (struct Shared_actions *)shared_memory;
    strncpy(actions->exit, EXIT_PROGRAM, EXIT_PROGRAM_CHARS);
    strcat(actions->exit, "\n");

    pthread_t th_readPrint, th_output;
    int *th_ret;

    //First rendezvous point between the two processes, before creating threads.
    sem_post(&actions->sem1);
    sem_wait(&actions->sem3);

    //Threads creation that will be responsible for getting/printing the input/output of the other process.
    pthread_create(&th_readPrint, NULL, inputB, (void*)actions);
    pthread_create(&th_output, NULL, outputB, (void*)actions);
    pthread_join(th_readPrint, (void**)&th_ret);
    pthread_join(th_output, (void**)&th_ret);

    //In case of dividing with 0.
    float splitspmsg = 0, wait_time;
    if(actions->mes_sentB !=0){
        splitspmsg = (float)actions->mes_splitsB / actions->mes_sentB;
        wait_time = (float)actions->dif_timeB / actions->mes_receivedA;
    }

    sem_wait(&actions->sem2);

    //Statistics of the conversation.
    //Process B needs to print statistics first in case process A frees shared memory, before of B's chat summary.
    printf("\n\n\n\n\n\n\n");
    printf("---------- CHAT SUMMARRY ----------\n");
    printf("MESSAGE SENT:%d\n", actions->mes_sentB);
    printf("MESSAGE RECEIVED:%d\n", actions->mes_receivedB);
    printf("MESSAGE SPLITS IN TOTAL:%d\n", actions->mes_splitsB);
    printf("MESSAGE SPLITS PER MESSAGE:%f\n", splitspmsg);
    printf("AVERAGE WAIT TIME FOR THE FIRST BATCH %0.2f MS\n\n", wait_time);

    sem_post(&actions->sem1);
}
 
