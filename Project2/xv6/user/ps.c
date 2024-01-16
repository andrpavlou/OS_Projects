#include "kernel/types.h"
#include "user/user.h"
#include "kernel/pstat.h"


int main(int argc, char *argv[]){

    struct pstat stats;
    if(getpinfo((&stats)) != 0){
        exit(0);
    }

    for(uint64 i = 0; i < NPROC; i++){
        if(stats.state[i] != UNUSED){
            printf("NAME: %s \t   ID: %d \t   PARENT ID: %d \t   PRIORITY: %d   \tSTATE: %d   \n", stats.name[i], 
            stats.pid[i], stats.ppid[i], stats.priority[i], stats.state[i]);
        }
    }
    exit(0);
}