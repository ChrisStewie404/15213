#include<stdio.h>
int main(){
	unsigned cookie=0x59b997fa;
	char cbuf[110]={'C','M','U'};
	char *s=cbuf;
	sprintf(s,"%.8x",cookie);
	int i=0;
	while(s[i]){
		 printf("%c",s[i]);
		 i++;
	}
	return 0;
} 
