#include<stdio.h>
int main(){
	unsigned cookie=0x59b997fa;
	char *s;
	sprintf(s,"%.8x",cookie);
	printf("%s",s);
	return 0;
} 
