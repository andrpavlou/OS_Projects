#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(){


    char string[9999];


	fgets(string, BUFSIZ, stdin);
    
    printf("%s ", string);
    int lasti = 0;
    char last = string[lasti];

    while(last != '\0'){
        lasti++;
        last = string[lasti];
    }
    printf("%d \n", lasti);

    char temp[100];
    char final[100];
    lasti -= 1;
    if(lasti > 15){
        int transfers = lasti / 15;
        int rems = lasti % 15;

        int itters = 0;
        while(itters < transfers){
            strncpy(temp, string + itters * 15, 15);
            itters ++ ;
            strcat(final, temp);
        }
        if(rems >= 1){
            char lasts[rems];

            strncpy(lasts, string + (itters) * 15, 14);
            strcat(final, lasts);
            
        }
        printf(" %s ", final);
    }



}
