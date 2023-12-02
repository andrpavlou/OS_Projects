#include "../include/threadfuncB.h"

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
    char inp[TEXT_SZ];
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


    sem_post(&actions->sem1);
    sem_wait(&actions->sem3);

    pthread_create(&th_input, NULL, inputB, (void*)actions);
    pthread_join(th_input, (void**)&th_ret);


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
 
