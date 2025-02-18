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
    "segregated free list",
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
#define PSIZE (sizeof(void*))
#define ALIGNMENT 8
#define CHUNKSIZE (1<<12)

/* rounds up to the nearest multiple of ALIGNMENT */
#define ALIGN(size) (((size) + (ALIGNMENT-1)) & ~0x7)

#define MAX(x,y) ((x)>(y)? (x):(y))
#define MIN(x,y) ((x)<(y)? (x):(y))

#define SIZE_T_SIZE (ALIGN(sizeof(size_t)))

#define PACK(size,alloc) ((size)|(alloc))

#define GET(p)      (*(unsigned int*)(p))
#define PUT(p,val)  (*(unsigned int*)(p) = ((unsigned int)(val)))
#define PUTL(p,val) (*(unsigned long*)(p) = ((unsigned long)(val)))

#define GET_SIZE(p)     (GET(p) & ~0x7)
#define GET_ALLOC(p)    (GET(p) & 0x1)

#define HDRP(bp)        ((char*)(bp) - WSIZE)
#define FTRP(bp)        ((char*)(bp) + GET_SIZE(HDRP(bp)) - DSIZE)

#define NEXT_BLKP(bp)   ((char*)(bp) + GET_SIZE((char*)(bp) - WSIZE))
#define PREV_BLKP(bp)   ((char*)(bp) - GET_SIZE((char*)(bp) - DSIZE))

#define PREDP(bp)       ((char*)(bp))
#define SUCCP(bp)       ((char*)(bp) + PSIZE)

#define PRED_BLKP(bp)        ((char*)GET(bp))
#define SUCC_BLKP(bp)        ((char*)GET((char*)(bp) + PSIZE))

static char* heap_listp;
static char* segr_listp;

static void* extend_heap(size_t words);
static void* coalesce(void * bp);
static void* find_fit(size_t asize);
static void place(void* bp, size_t asize);
static void insert_frblk(void* bp);
static void remove_frblk(void* bp);
static int get_class(size_t asize);
static int mm_check();
/* 
 * mm_init - initialize the malloc package.
 */
int mm_init(void)
{
    // printf("In imx\n");
    if((heap_listp = mem_sbrk(50*WSIZE)) == (void*)-1){
        return -1;
    }
    PUT(heap_listp,0);
    segr_listp = heap_listp + 2*WSIZE;
    heap_listp += WSIZE;
    for(size_t i=0;i<12;i++){
        PUT(heap_listp, PACK(16,1));
        PUT(heap_listp + WSIZE, 0);
        PUT(heap_listp + 2*WSIZE, 0);
        PUT(heap_listp + 3*WSIZE, PACK(16,1));    
        heap_listp += 4*WSIZE;
    }
    PUT(heap_listp, PACK(0,1));
    heap_listp -= 3*WSIZE;
    // mm_check();
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
        // printf("In mm_malloc (fit)\n");
        // mm_check();
        return bp;
    }
    size_t extendsize = MAX(1<<12,asize);

    if((bp = extend_heap(extendsize/WSIZE)) == NULL){
     
        return NULL;
    }
    place(bp,asize);
    // printf("In mm_malloc (extend)\n");
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
    insert_frblk(ptr);
    coalesce(ptr);
    // printf("In mm_free\n");
    // mm_check();       
}

/*
 * mm_realloc - Implemented simply in terms of mm_malloc and mm_free
 */
void *mm_realloc(void *ptr, size_t size)
{
    /*
    possible optimization:
    look at prev and next blk
    still buggy!!!!
    */
    if (ptr == NULL){
        return mm_malloc(size);
    }
    else if (size == 0){
        mm_free(ptr);
    }
    size_t asize,csize;
    char* oldptr, *newptr;
    if (size <= DSIZE)
        asize = 2*DSIZE;
    else
        asize = ALIGN(size) + DSIZE;

    if ((csize = GET_SIZE(HDRP(ptr))) >=asize){
        return ptr;
    }
    void* nbp = NEXT_BLKP(ptr);
    size_t next_alloc = GET_ALLOC(HDRP(nbp));
    size_t next_size = GET_SIZE(HDRP(nbp));
    if(!next_alloc &&  (next_size) >= (asize - csize + 16)){
        // printf("In realloc (next):\n");
        // printf("csize: %d next_size: %d asize: %d\n",csize,next_size,asize);
        remove_frblk(nbp);
        next_size -= (asize - csize);
        nbp = (char*)nbp + asize - csize;
        PUT(HDRP(nbp),PACK(next_size,0));
        PUT(FTRP(nbp),PACK(next_size,0));
        insert_frblk(nbp);


        PUT(HDRP(ptr),PACK(asize,1));
        PUT(FTRP(ptr),PACK(asize,1));
        return ptr;
    }
    // void* pbp = PREV_BLKP(ptr);
    // size_t prev_alloc = GET_ALLOC(HDRP(pbp));
    // size_t prev_size = GET_SIZE(HDRP(pbp));
    // if(!prev_alloc && (prev_size) >= (asize - csize + 16)){
    //     // printf("In realloc (next):\n");
    //     // printf("csize: %d next_size: %d asize: %d\n",csize,next_size,asize);
    //     remove_frblk(pbp);
    //     prev_size -= (asize - csize);
    //     pbp = (char*)pbp;
    //     PUT(HDRP(pbp),PACK(prev_size,0));
    //     PUT(FTRP(pbp),PACK(prev_size,0));
    //     insert_frblk(pbp);

    //     newptr = (char*)ptr - asize + csize;
    //     oldptr = (char*)ptr;
    //     PUT(HDRP(newptr),PACK(asize,1));
    //     PUT(FTRP(newptr),PACK(asize,0));
    //     for(size_t i=0;i<csize-2;i++){
    //         newptr[i] = oldptr[i];
    //     }
    //     return newptr;
    // }
    oldptr = (char*)ptr;
    newptr = (char*)mm_malloc(size);
    if (newptr == NULL) return NULL;
    size_t min_size = MIN(GET_SIZE(HDRP(oldptr)),asize);
    // printf("original block size: %d\tnew block size: %d\n",GET_SIZE(HDRP(oldptr)),GET_SIZE(HDRP(newptr)));
    memcpy(newptr,oldptr,min_size-2);
    mm_free(ptr);
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
    insert_frblk(bp);
    PUT(HDRP(NEXT_BLKP(bp)),PACK(0,1));
    // printf("In extend_heap (success)\n");
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
        void* nbp = NEXT_BLKP(bp);
        remove_frblk(nbp);
        remove_frblk(bp);
        size += GET_SIZE(HDRP(nbp));
        PUT(HDRP(bp),PACK(size,0));
        PUT(FTRP(bp),PACK(size,0));
        insert_frblk(bp);
    }
    else if(!prev_alloc && next_alloc){
        void* pbp = PREV_BLKP(bp);
        remove_frblk(pbp);
        remove_frblk(bp);
        size += GET_SIZE(HDRP(pbp));
        PUT(FTRP(bp),PACK(size,0));
        PUT(HDRP(pbp),PACK(size,0));
        
        bp = pbp;
        insert_frblk(bp);
    }
    else{
        void* pbp = PREV_BLKP(bp);
        void* nbp = NEXT_BLKP(bp);
        remove_frblk(pbp);
        remove_frblk(nbp);
        remove_frblk(bp);
        size += GET_SIZE(HDRP(pbp)) + GET_SIZE(HDRP(nbp));
        PUT(HDRP(PREV_BLKP(bp)),PACK(size,0));
        PUT(FTRP(NEXT_BLKP(bp)),PACK(size,0));
        
        bp = PREV_BLKP(bp);
        insert_frblk(bp);
    }
    // printf("In coalesce\n");
    // mm_check();
    return bp;
}

static void* find_fit(size_t asize){
    /*segregated-fit*/
    size_t _class = get_class(asize);
    char* bp;
    size_t size;
    for(size_t i=_class;i<12;i++){
        bp = (char*)segr_listp + (i<<4);
        while(bp != NULL){
            size = GET_SIZE(HDRP(bp));
            if(!GET_ALLOC(HDRP(bp)) && size >= asize){
                // printf("In find_fit (success)\n");
                // mm_check();
                return bp;
            }
            bp = SUCC_BLKP(bp);
        }         
    }

    // printf("In find_fit (fail)\n");
    // mm_check();
    return NULL;
}

static void place(void* bp, size_t asize){
    size_t bsize = GET_SIZE(HDRP(bp));
    // printf("In place\n");
    if(bsize >= 16 + asize){
        remove_frblk(bp);
        PUT(HDRP(bp),PACK(asize,1));
        PUT(FTRP(bp),PACK(asize,1));
        void* nbp =NEXT_BLKP(bp);
        // printf("nbp: %p\t bp: %p\n",nbp,bp);
        PUT(HDRP(nbp),PACK(bsize-asize,0));
        PUT(FTRP(nbp),PACK(bsize-asize,0));

        insert_frblk(nbp);

        // mm_check();
    }
    else{
        remove_frblk(bp);
        PUT(HDRP(bp),PACK(bsize,1));
        PUT(FTRP(bp),PACK(bsize,1));

        // mm_check();
    }
}

static int mm_check(){
    void* bp = heap_listp;
    size_t size;
    printf("All blocks:\n");
    while((size = GET_SIZE(HDRP(bp)))>0){
        printf("pos:%p\t size: %d\t ",bp,size);
        if(GET_ALLOC(HDRP(bp))){
            printf("allocated\n");
        }
        else printf("free\n");
        bp = NEXT_BLKP(bp);
    }
    printf("Free blocks:\n");
    bp = SUCC_BLKP(heap_listp);
    while(bp!=NULL){
        size = GET_SIZE(HDRP(bp));
        printf("pos:%p\t size: %d\n",bp,size);
        bp = SUCC_BLKP(bp);
    }
    return 0;
}

static void insert_frblk(void* bp){
    void* sbp,* sentinel;
    size_t _class = get_class(GET_SIZE(HDRP(bp)));
    sentinel = (char*)segr_listp + (_class << 4);
    if((sbp = SUCC_BLKP(sentinel)) != NULL){
        PUT(SUCCP(bp),sbp);
        PUT(PREDP(sbp),bp);
        PUT(SUCCP(sentinel),bp);
        PUT(PREDP(bp),sentinel);
    }
    else{
        PUT(SUCCP(sentinel),bp);
        PUT(PREDP(bp),sentinel);
        PUT(SUCCP(bp),0);
    }
}

static void remove_frblk(void* bp){
    void* pbp,*sbp;
    pbp = PRED_BLKP(bp);
    sbp = SUCC_BLKP(bp);
    if(pbp!=NULL) PUT(SUCCP(pbp),sbp);
    if(sbp!=NULL) PUT(PREDP(sbp),pbp);
}
static int get_class(size_t asize){
    size_t _class = 0;
    size_t size = MAX(asize-8,0);
    while (size)
    {
        size >>=1;
        _class++;
    }
    return MIN(MAX(_class-2, 0),11);
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

/*
possible optimization:
first fit -->
best fit
*/










