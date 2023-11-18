#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(){
    int n = 10;


    char s[] = "Hello worlds";
    int size = strlen(s);
    int offset = size - n;

    char* temp = malloc(sizeof(n));
    //n + 1 for '\0'
    strncpy(temp, s + offset - 1, n);


    printf("%s ", temp);
    printf("%ld ", strlen(temp));

    free(temp);
}