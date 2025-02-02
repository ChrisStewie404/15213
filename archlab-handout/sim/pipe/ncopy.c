#include <stdio.h>
#include<stdlib.h>
typedef long word_t;

//word_t src[8], dst[8];

/* $begin ncopy */
/*
 * ncopy - copy src to dst, returning number of positive ints
 * contained in src array.
 */
word_t ncopy(word_t *src, word_t *dst, word_t len)
{
    word_t count = 0;
    word_t val;
    word_t r1,r2,r3,r4,r5,r6;
    while (len > 5) {
        r1=*src;
        r2=*(src+1);
        r3=*(src+2);
        r4=*(src+3);
        r5=*(src+4);
        r6=*(src+5);
        *dst=r1;
        *(dst+1)=r2;
        *(dst+2)=r3;
        *(dst+3)=r4;
        *(dst+4)=r5;
        *(dst+5)=r6;
        count =r1>0? count+1:count;
        count =r2>0? count+1:count;
        count =r3>0? count+1:count;
        count =r4>0? count+1:count;
        count =r5>0? count+1:count;
        count =r6>0? count+1:count;
        src+=6;
        dst+=6;
    }
    while(len>0){
        r1=*(src);
        *dst=r1;
        count =r1>0? count+1:count;
        src++;
        dst++;
    }
    return count;
}
/* $end ncopy */

/*int main()
{
    word_t i, count;

    for (i=0; i<8; i++)
	src[i]= i+1;
    count = ncopy(src, dst, 8);
    printf ("count=%ld\n", count);
    exit(0);
}*/


