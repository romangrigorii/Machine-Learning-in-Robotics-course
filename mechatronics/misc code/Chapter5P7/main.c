#include <stdio.h>
#include <math.h>

int BreakingStack(int u){
  if(u<100000){
    int i = BreakingStack(u+1);
    }
  else{
    return u;
  }
}

int main(void){
int i = BreakingStack(0);
return 0;
}
