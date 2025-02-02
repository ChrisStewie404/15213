#include<bits/stdc++.h>
using namespace std;
int main(){
	unsigned cookie=0x59b997fa;
	char *s;
	sprintf(s,"%.8x",cookie);
	s="15-213CMU";
	int i=0;
	while(s[i]){
		 cout<<s[i];
		 i++;
	}
	return 0;
} 
