#include "../include/threadfuncA.h"



int main(){
    struct Shared_actions actions0;
    struct Shared_actions* actions ;
    actions = &actions0;

    actions->running = 1;

    strncpy(actions->exit, EXIT_PROGRAM, EXIT_PROGRAM_CHARS);
    strcat(actions->exit, "\n");

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

    //Unnamed semaphores, initialization for shared memory for the use of both processes.
    sem_init(&actions->sem1, 1, INITIAL_VALUE);
    sem_init(&actions->sem2, 1, INITIAL_VALUE);
    sem_init(&actions->sem3, 1, INITIAL_VALUE);

    pthread_t th_readPrint, th_output;

    int *th_ret;
    actions->running = 1;

    //First rendezvous point between the two processes, before creating threads.
    sem_wait(&actions->sem1);
    sem_post(&actions->sem3);

    //Thread creations that will be responsible for getting/printing the input/output of the other process.
    pthread_create(&th_readPrint, NULL, inputA, (void*)actions);
    pthread_create(&th_output, NULL, outputA, (void*)actions);
    pthread_join(th_readPrint, (void**)&th_ret);
    pthread_join(th_output, (void**)&th_ret);


    //In case of dividing with 0.
    float splitspmsg = 0, wait_time;
    if(actions->mes_sentA !=0){
        splitspmsg = (float)actions->mes_splitsA / actions->mes_sentA;
        // wait_time = (float)actions->dif_timeA / actions->mes_receivedA;
    }

    
    sem_post(&actions->sem2);
    sem_wait(&actions->sem1);

    //Statistics of the conversation.
    printf("\n\n\n\n\n\n\n");
    printf("---------- CHAT SUMMARRY ----------\n");
    printf("MESSAGE SENT:%d\n", actions->mes_sentA);
    printf("MESSAGE RECEIVED:%d\n", actions->mes_receivedA);
    printf("MESSAGE SPLITS IN TOTAL:%d\n", actions->mes_splitsA);
    printf("MESSAGE SPLITS PER MESSAGE:%f\n", splitspmsg);
    // printf("AVERAGE WAIT TIME FOR THE FIRST BATCH %0.2f MS\n\n", wait_time);

    if (shmdt(shared_memory) == -1) {
		fprintf(stderr, "shmdt failed\n");
		exit(EXIT_FAILURE);
	}
    if (shmctl(shmid, IPC_RMID, 0) == -1) {
		fprintf(stderr, "shmctl(IPC_RMID) failed\n");
		exit(EXIT_FAILURE);
	}
    sem_destroy(&actions->sem1);
    sem_destroy(&actions->sem2);
    sem_destroy(&actions->sem3);
}