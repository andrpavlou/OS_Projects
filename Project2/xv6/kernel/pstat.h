#ifndef _PSTAT_H_
#define _PSTAT_H_

#define NPROC 64
enum procstate { UNUSED, USED, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };

//Useful information for ps.c
struct pstat{
  int pid[NPROC];                       //Process id.
  int ppid[NPROC];                      //Parent's process id.
  int priority[NPROC];                  //Priority.
  char name[NPROC][16];                 //Process name.
  enum procstate state[NPROC];          //State of process.
};


#endif // _PSTAT_H_