#include<stdio.h>
#include<string.h>
#define MAX(x,y) ((x) > (y)? x:y)
static int get_class(size_t size){
    size_t _class = 0;
    while (size)
    {
        size >>=2;
        _class++;
    }
    return MAX(_class-2, 0);
}
int main(){
    // int a[5] = {1,5,2,1,3};
    // int b[5] = {8,4,7,8,6};
    // memcpy(b,a,5);
    // for(int i=0;i<5;i++){
    //     printf("%d ",b[i]);
    // }
    // printf("\n");
    printf("%ld\n",sizeof(long));
	return 0;
} 
