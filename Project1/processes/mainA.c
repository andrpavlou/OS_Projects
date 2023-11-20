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

int main(){
    struct shared_actions actions0;
    struct shared_actions* actions ;
    actions = &actions0;

    actions->readA = 0;
    actions->readA = 0;
    actions->buff_full = 0;
    actions->running = 1;

    actions->mes_receivedA = 0;
    actions->mes_receivedB = 0;
    actions->mes_sentA = 0;
    actions->mes_sentB = 0;

    actions->mes_splitsA = 0;
    actions->mes_splitsB = 0;

    strncpy(actions->exit, EXIT_PROGRAM, EXIT_PROGRAM_CHARS);

    key_t  key = KEY; 

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
    sem_init(&actions->sem3, 1, INITIAL_VALUE);

    pthread_t th_input, th_output;

    int *th_ret;
    actions->running = 1;
    int running = 1;

    
    while(running){

        sem_wait(&actions->sem1);
        sem_post(&actions->sem3);

        if(!actions->running)
            break;

        pthread_create(&th_input, NULL, inputA, (void*)actions);
        
        while(!actions->readB && !actions->readA);
        
        if(actions->readB)
            pthread_cancel(th_input);

        pthread_join(th_input, (void**)&th_ret);

        
        if(actions->readA)
            sem_wait(&actions->sem2);
        
        if(actions->readB){
            pthread_create(&th_output, NULL, outputA, (void*)actions);
            sem_post(&actions->sem2);
            actions->mes_receivedA ++;
        }
        if(actions->readB)
            pthread_join(th_output, NULL);

        actions->readA = 0;
    }

    float splitspmsg = 0;
    if(actions->mes_sentA !=0)
        splitspmsg = (float)actions->mes_splitsA / actions->mes_sentA;
    
    sem_post(&actions->sem2);
    sem_wait(&actions->sem1);
    printf("\n\n\n\n\n\n\n");
    printf("---------- CHAT SUMMARRY ----------\n");
    printf("MESSAGE SENT:%d\n", actions->mes_sentA);
    printf("MESSAGE RECEIVED:%d\n", actions->mes_receivedA);
    printf("MESSAGE SPLITS IN TOTAL:%d\n", actions->mes_splitsA);
    printf("MESSAGE SPLITS PER MESSAGE:%f\n", splitspmsg);


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