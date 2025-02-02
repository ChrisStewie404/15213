#include<stdio.h> 
#include<stdlib.h>
#include<string.h>
unsigned cookie=0x59b997fa;
int hexmatch(unsigned val, char* sval){
	char cbuf[110];
	char *s=cbuf+4%100;
	sprintf(s,"%.8x",val);
	return strncmp(sval,s,9)==0;
}
void touch3(char *sval){
	if(hexmatch(cookie,sval)){
		printf("Touch3!: You called touch3(\"%s\")\n",sval);	
	}
	else{
		printf("Misfire: You called touch3(\"%s\")\n",sval);
	}
}
int main(){
	char cbuf[110]="59b997fa";
	touch3(cbuf);
	return 0; 
}
