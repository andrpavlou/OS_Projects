#include "kernel/types.h"
#include "user/user.h"
#include "kernel/pstat.h"


int main(int argc, char *argv[]){
    struct pstat pstats;
    
    if(getpinfo((&pstats)) != 0){
        exit(0);
    }

    for(uint64 i = 0; i < NPROC; i++){
        if(pstats.state[i] != UNUSED){
            printf("NAME: %s \t   ID: %d \t   PARENT ID: %d \t   PRIORITY: %d   \tSTATE: %d   \n", 
            pstats.name[i], pstats.pid[i], pstats.ppid[i], pstats.priority[i], pstats.state[i]);
        }
    }
    exit(0);
}