/*
 * mm-naive.c - The fastest, least memory-efficient malloc package.
 * 
 * In this naive approach, a block is allocated by simply incrementing
 * the brk pointer.  A block is pure payload. There are no headers or
 * footers.  Blocks are never coalesced or reused. Realloc is
 * implemented directly using mm_malloc and mm_free.
 *
 * NOTE TO STUDENTS: Replace this header comment with your own header
 * comment that gives a high level description of your solution.
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>

#include "mm.h"
#include "memlib.h"

/*********************************************************
 * NOTE TO STUDENTS: Before you do anything else, please
 * provide your team information in the following struct.
 ********************************************************/
team_t team = {
    /* Team name */
    "initial version",
    /* First member's full name */
    "Harry Bovik",
    /* First member's email address */
    "bovik@cs.cmu.edu",
    /* Second member's full name (leave blank if none) */
    "",
    /* Second member's email address (leave blank if none) */
    ""
};

/* single word (4) or double word (8) alignment */
#define WSIZE 4
#define DSIZE 8
#define ALIGNMENT 8
#define CHUNKSIZE (1<<12)

/* rounds up to the nearest multiple of ALIGNMENT */
#define ALIGN(size) (((size) + (ALIGNMENT-1)) & ~0x7)

#define MAX(x,y) ((x)>(y)? (x):(y))

#define SIZE_T_SIZE (ALIGN(sizeof(size_t)))

#define PACK(size,alloc) ((size)|(alloc))

#define GET(p)      (*(unsigned int*)(p))
#define PUT(p,val)  (*(unsigned int*)(p)=(val))

#define GET_SIZE(p)     (GET(p) & ~0x7)
#define GET_ALLOC(p)    (GET(p) & 0x1)

#define HDRP(bp)        ((char*)(bp) - WSIZE)
#define FTRP(bp)        ((char*)(bp) + GET_SIZE(HDRP(bp)) - DSIZE)

#define NEXT_BLKP(bp)   ((char*)(bp) + GET_SIZE((char*)(bp) - WSIZE))
#define PREV_BLKP(bp)   ((char*)(bp) - GET_SIZE((char*)(bp) - DSIZE))

static char* heap_listp;

static void* extend_heap(size_t words);
static void* coalesce(void * bp);
static void* find_fit(size_t asize);
static void place(void* bp, size_t asize);
static int mm_check();
/* 
 * mm_init - initialize the malloc package.
 */
int mm_init(void)
{
    // printf("In imi\n");
    if((heap_listp = mem_sbrk(4*WSIZE)) == (void*)-1){
        return -1;
    }
    PUT(heap_listp, 0);
    PUT(heap_listp + WSIZE, PACK(8,1));
    PUT(heap_listp + 2*WSIZE, PACK(8,1));
    PUT(heap_listp + 3*WSIZE, PACK(0,1));
    heap_listp += 2*WSIZE;
    if(extend_heap(CHUNKSIZE/WSIZE) == NULL){
        return -1;
    }
    return 0;
}

/* 
 * mm_malloc - Allocate a block by incrementing the brk pointer.
 *     Always allocate a block whose size is a multiple of the alignment.
 */
void *mm_malloc(size_t size)
{
    // int newsize = ALIGN(size + SIZE_T_SIZE);
    // void *p = mem_sbrk(newsize);
    // if (p == (void *)-1)
	// return NULL;
    // else {
    //     *(size_t *)p = size;
    //     return (void *)((char *)p + SIZE_T_SIZE);
    // }
    size_t asize;       /*adjusted block size*/
    char* bp;

    if (size == 0){
        // printf("In mm_malloc\n");
        // mm_check();
        return NULL;
    }

    if (size <= DSIZE)
        asize = 2*DSIZE;
    else
        asize = ALIGN(size) + DSIZE;
    
    if ((bp = find_fit(asize)) != NULL){
        place(bp,asize);

        return bp;
    }
    size_t extendsize = MAX(CHUNKSIZE,asize);

    if((bp = extend_heap(extendsize/WSIZE)) == NULL){
     
        return NULL;
    }
    place(bp,asize);
    // printf("In mm_malloc\n");
    // mm_check();
    return bp;
}

/*
 * mm_free - Freeing a block does nothing.
 */
void mm_free(void *ptr)
{
    size_t size = GET_SIZE(HDRP(ptr));

    PUT(HDRP(ptr),PACK(size,0));
    PUT(FTRP(ptr),PACK(size,0));
    // printf("In mm_free\n");
    // mm_check();
    coalesce(ptr);

}

/*
 * mm_realloc - Implemented simply in terms of mm_malloc and mm_free
 */
void *mm_realloc(void *ptr, size_t size)
{
    void *oldptr = ptr;
    void *newptr;
    size_t copySize;
    
    newptr = mm_malloc(size);
    if (newptr == NULL)
      return NULL;
    copySize = *(size_t *)((char *)oldptr - SIZE_T_SIZE);
    if (size < copySize)
      copySize = size;
    memcpy(newptr, oldptr, copySize);
    mm_free(oldptr);

    return newptr;
}


static void* extend_heap(size_t words){
    char* bp;
    size_t size;
    size = (words%2)? words+1:words;
    size*= WSIZE;
    if((long)(bp=mem_sbrk(size)) == -1){
        // printf("In extend_heap (fail)\n");
        // mm_check();
        return NULL;
    }
    PUT(HDRP(bp),PACK(size,0));
    PUT(FTRP(bp),PACK(size,0));
    PUT(HDRP(NEXT_BLKP(bp)),PACK(0,1));
    // printf("In find_fit (success)\n");
    // mm_check();
    return coalesce(bp);
}

static void* coalesce(void * bp){
    size_t prev_alloc = GET_ALLOC(HDRP(PREV_BLKP(bp)));
    size_t next_alloc = GET_ALLOC(HDRP(NEXT_BLKP(bp)));
    size_t size = GET_SIZE(HDRP(bp));

    if(prev_alloc && next_alloc){
        // printf("In coalesce\n");
        // mm_check();
        return bp;
    }
    else if(prev_alloc && !next_alloc){
        size += GET_SIZE(HDRP(NEXT_BLKP(bp)));
        PUT(HDRP(bp),PACK(size,0));
        PUT(FTRP(bp),PACK(size,0));
    }
    else if(!prev_alloc && next_alloc){
        size += GET_SIZE(HDRP(PREV_BLKP(bp)));
        PUT(FTRP(bp),PACK(size,0));
        PUT(HDRP(PREV_BLKP(bp)),PACK(size,0));
        
        bp = PREV_BLKP(bp);
    }
    else{
        size += GET_SIZE(HDRP(PREV_BLKP(bp))) + GET_SIZE(HDRP(NEXT_BLKP(bp)));
        PUT(HDRP(PREV_BLKP(bp)),PACK(size,0));
        PUT(FTRP(NEXT_BLKP(bp)),PACK(size,0));

        bp = PREV_BLKP(bp);
    }
    // printf("In coalesce\n");
    // mm_check();
    return bp;
}

static void* find_fit(size_t asize){
    /*first-fit*/
    void* bp = heap_listp;
    size_t size;
    while((size = GET_SIZE(HDRP(bp))) > 0){
        if(!GET_ALLOC(HDRP(bp)) && size >= asize){
            // printf("In find_fit (success)\n");
            // mm_check();
            return bp;
        }
        bp = NEXT_BLKP(bp);
    }
    // printf("In find_fit (fail)\n");
    // mm_check();
    return NULL;
}

static void place(void* bp, size_t asize){
    size_t bsize = GET_SIZE(HDRP(bp));
    if(bsize >= 16 + asize){
        /*
        possible optimization: 
        Place the requested block at the end of the free block
        Need to return modified bp
        */
       PUT(HDRP(bp),PACK(asize,1));
       PUT(FTRP(bp),PACK(asize,1));
       bp = NEXT_BLKP(bp);
       PUT(HDRP(bp),PACK(bsize-asize,0));
       PUT(FTRP(bp),PACK(bsize-asize,0));
        // bsize -= asize;
        // PUT(FTRP(bp),PACK(bsize,0));
        // PUT(HDRP(bp),PACK(asize,1));
        // PUT(FTRP(bp),PACK(asize,1));
        // PUT(FTRP(bp)+WSIZE,PACK(bsize,0));
    }
    else{
        PUT(HDRP(bp),PACK(bsize,1));
        PUT(FTRP(bp),PACK(bsize,1));
    }
}

static int mm_check(){
    void* bp = heap_listp;
    size_t size;
    size_t a_cnt = 0, f_cnt = 0,size_tot = 0;
    while((size = GET_SIZE(HDRP(bp)))>0){
        size_tot += size;
        if(GET_ALLOC(HDRP(bp))){
            a_cnt++;
        }
        else f_cnt++;
        bp = NEXT_BLKP(bp);
    }
    // printf("allocated: %d free: %d total size: %d\n",a_cnt,f_cnt,size_tot);
    return 0;
}

/*
possible optimization:
immediate free --> deferred free
*/

/*
possible optmization:
implicit free list -->
(explicite free list -->)
segregated free list
*/

/*
possible optimization:
hide boundary tag
*/










