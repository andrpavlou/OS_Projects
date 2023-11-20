
#ifndef THREADFUNCB_H_   /* Include guard */
#define THREADFUNCB_H_

#define TEXT_SZ 2048
#define TEXT_EX 5
#define EXIT_PROGRAM "#BYE#"
#define EXIT_PROGRAM_CHARS 5
#define BUFF_SIZE  BUFSIZ / 2 //4096 default buffersize
#define KEY 12121

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

void* outputB(void* data);
void* inputB(void* data);

#endif 

