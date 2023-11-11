#define TEXT_SZ 2048


#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/shm.h>

struct shared_actions{
    char write[TEXT_SZ];
    char read[TEXT_SZ];
};

int main(){

    struct shared_actions* actions;
    char buffer[BUFSIZ];

    key_t key; 
    if(key = ftok("proccessB", 'B') == - 1){    
        fprintf(stderr, "Key Creation Failed\n");
        exit(EXIT_FAILURE);
    }

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



    
}