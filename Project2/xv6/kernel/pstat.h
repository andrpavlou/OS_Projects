#ifndef _PSTAT_H_
#define _PSTAT_H_

enum procstate { UNUSED, USED, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };

#define NPROC 64
//Useful information for ps.c
struct pstat{
  int pid[NPROC];
  int ppid[NPROC];
  int priority[NPROC];
  char name[NPROC][16];               // Process name (debugging)
  enum procstate state[NPROC];
};
#endif // _PSTAT_H_