#include<signal.h>
#include<unistd.h>
#include<stdio.h>
#include<stdlib.h>
typedef void (*__sighandler_t)(int);
void sigint_handler(int sig){
    return;
}
void snooze(unsigned int secs){
    int left;
    left=sleep(secs);
    printf("Slept for %d of %d secs\n",secs-left,secs);
    return;
}
int main(int argc, char*argv[]){
    if(signal(SIGINT,sigint_handler)==SIG_ERR){
        exit(1);
    }
    snooze(atoi(argv[1]));
    signal(SIGINT,SIG_DFL);
    return 0;
}