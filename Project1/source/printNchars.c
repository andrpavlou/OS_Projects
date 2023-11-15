#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(){
    int n = 4;


    char s[] = "Hello worlds";
    int size = strlen(s);
    int offset = size - 4;

    char temp[1000];
    strncpy(temp, s + offset - 1, n + 1);


    printf("%s ", temp);


}