#include "kernel/types.h"
#include "user/user.h"
#include "kernel/pstat.h"

#define LARGE_TIME 1222122550
#define SMALL_TIME 122212325

// Comment out to use setpriority syscall
// setpriority syscall in proc.c, default priority = 10, 
//initialized in proc.c as well.
// int setpriority(int num)
// {
//   return -1;
// }

uint64 useless_calc(uint64 z, uint64 time)
{
  volatile uint64 t = z;  // volatile to not be optimized out
  volatile uint64 sum = 0;
  for (;;) {
    t += 2;
    sum += t;
    t -= 1;
    if (t == time)
      break;
  }
  return sum;
}

int
useless(int priority, uint64 time)
{
  if (setpriority(priority) == -1) {
    fprintf(2, "setpriority error\n");
  }

  sleep(1);
  uint64 sum = useless_calc(0, time);
  char* spent = (time == LARGE_TIME) ? "large" : "small";
  // Need to print uselesss sum to suppress warning.
  printf("Child pid %d, %s, with priority %d finished. Useless sum: %d\n", getpid(), spent,  priority, sum);
  exit(0);
}


 int main(int argc, char *argv[])
{
  int id = 0;
  // Fix parent to high priority, so that forking is done
  if (setpriority(1) == -1) {
    fprintf(2, "setpriority error\n");
  }

  // Create 4 long running children with low priorities
  for (int i=0; i < 4; i++)
  {
    id = fork();
    if(id < 0)
      printf("%d failed in fork!\n", getpid());
    else if(id == 0) {
      // Child
      int pid = getpid();
      int priority = pid % 5 + 16; // Priority range: 15-19
      useless(priority, LARGE_TIME); // never returns
    }
  }

  // Create 40 small processes with varying priorities
  int n = 40;
  for (int i=0; i<n; i++) {
    id = fork();
    if(id < 0)
      printf("%d failed in fork!\n", getpid());
    else if(id == 0) {
      // Child
      sleep(1);
      int pid = getpid();
      int priority = pid % 19 + 2; // Priority range: 2-20
      useless(priority, SMALL_TIME); // never returns
    }
  }

  // Father waits for all the children (n+4)
  if (id > 0) {
    for (int i = 0; i < n+4; i++) {
      wait((int*)0);
    }
  }
  exit(0);
}


