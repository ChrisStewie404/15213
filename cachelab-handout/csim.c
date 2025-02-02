#include "cachelab.h"
#include <getopt.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
typedef long data_t;
typedef struct{
    data_t valid;
    data_t time;
    data_t tag;
}line;
typedef line *line_entry;
typedef line_entry *set_entry;
data_t hits=0,misses=0,evictions=0;
data_t verbose=0,s_key=0,t_key=0;
void printUsage();
// void cache_create(set_entry cache,data_t S,data_t E);
// void cache_free(set_entry cache,data_t S);
void simulate_cache(FILE* fptr,set_entry cache,data_t S,data_t E,data_t b);
void simulate_set(char op,line_entry set,data_t addr,data_t E);
int main(int argc,char*argv[]){
    data_t operator;
    FILE* fptr=NULL;
    set_entry cache=NULL;
    data_t s,S,E,b;
    while((operator=getopt(argc,argv,"hvs:E:b:t:"))!=-1){
        switch (operator)
        {
        case 'h':
            printUsage();
            break;
        case 'v':
            verbose=1;
            break;
        case 's':
            s=atoi(optarg);
            S=1<<s;
            break;
        case 'E':
            E=atoi(optarg);
            break;
        case 'b':
            b=atoi(optarg);
            break;
        case 't':
            fptr=fopen(optarg,"r");
            break;
        }
    }
    s_key=(1<<(s+b))-(1<<b);
    t_key=-(1<<(s+b));
    printf("%lx %lx\n",S,E);
    cache=(set_entry)malloc(S*sizeof(line_entry));
    for(int i=0;i<S;i++){
        cache[i]=(line_entry)malloc(E*sizeof(line));
        for(int j=0;j<E;j++){
            cache[i][j].time=0;
            cache[i][j].valid=1;
        }
    }
    // for(int i=0;i<S;i++){
    //     for(int j=0;j<E;j++){
    //         printf("[%d][%d] %lx ",i,j,cache[i][j].time);
    //     }
    //     printf("\n");
    // }
    simulate_cache(fptr,cache,S,E,b);

    for(int i=0;i<S;i++) free(cache[i]);
    free(cache);
    fclose(fptr);
    printSummary(hits,misses,evictions);
    return 0;
}
// void cache_create(set_entry cache,data_t S,data_t E){

// }
// void cache_free(set_entry cache,data_t S){
    
// }
void simulate_cache(FILE* fptr,set_entry cache,data_t S,data_t E,data_t b){
    char op;
    data_t addr,stride,set_idx;
    while(fscanf(fptr," %c %lx,%lx\n",&op,&addr,&stride)>0){
        set_idx=(addr&s_key)>>b;
        //printf(" %c %lx\n",op,verbose);
        switch (op)
        {
        case 'L':
            simulate_set('L',cache[set_idx],addr,E);
            break;
        case 'S':
            simulate_set('S',cache[set_idx],addr,E);
            break;
        case 'M':
            simulate_set('M',cache[set_idx],addr,E);
            break;
        }
    }
}
void simulate_set(char op,line_entry set,data_t addr,data_t E){
    data_t tag=addr&t_key;
    data_t t_max=0;
    data_t t_min=set[0].time,idx_min=0;
    for(int i=0;i<E;i++){
        if(set[i].valid==0&&set[i].time>t_max){
            t_max=set[i].time;
        }
    }
    //printf("current time: %lx ",t_max);
    for(int i=0;i<E;i++){
        if(set[i].valid==1){
            set[i].tag=tag;
            set[i].valid=0;
            set[i].time=t_max+1;
            misses++;
            if(op=='M') hits++;
            if(verbose==1){
                if(op=='L'||op=='S') printf("%c %lx miss\n",op,addr);
                if(op=='M') printf("%c %lx miss hit\n",op,addr);
            }
            return;
        }
        else if(set[i].tag==tag){
            set[i].time=t_max+1;
            hits++;
            if(op=='M') hits++;
            if(verbose==1){
                if(op=='L'||op=='S') printf("%c %lx hit\n",op,addr);
                if(op=='M') printf("%c %lx hit hit\n",op,addr);
            }
            return;
        }
    }
    for(int i=0;i<E;i++){
        if(set[i].time<t_min){
            t_min=set[i].time;
            idx_min=i;
        }
    }
    evictions++;
    misses++;
    if(op=='M') hits++;
    set[idx_min].tag=tag;
    set[idx_min].time=t_max+1;
    if(verbose==1){
        if(op=='L'||op=='S') printf("%c %lx miss eviction\n",op,addr);
        if(op=='M') printf("%c %lx miss eviction hit\n",op,addr);
    }
}
void printUsage(){
    const char *help_message = "Usage: \"Your complied program\" [-hv] -s <s> -E <E> -b <b> -t <tracefile>\n" \
                                 "<s> <E> <b> should all above zero and below 64.\n" \
                                "Complied with std=c99\n";
    printf("%s",help_message);
}