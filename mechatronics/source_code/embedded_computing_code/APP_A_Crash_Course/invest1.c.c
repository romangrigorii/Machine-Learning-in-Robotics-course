#include <stdio.h>
#include "NU32.h"
#define MAX_YEARS 100
typedef struct {
  double inv0;
  double growth;
  int years;
  double invarray[MAX_YEARS+1];
} Investment;
int getUserInput(Investment *invp);     // invp is a pointer to type ...
void calculateGrowth(Investment *invp); // ... Investment ==SecA.4.6, A.4.8==
void sendOutput(double *arr, int years);
int main(void) {

  Investment inv;

  while(getUserInput(&inv)) {
    inv.invarray[0] = inv.inv0;
    calculateGrowth(&inv);
    sendOutput(inv.invarray,
               inv.years);
  }
  return 0;
}
void calculateGrowth(Investment *invp) {

  int i;

  for (i = 1; i <= invp->years; i= i + 1) {
    invp->invarray[i] = invp->growth * invp->invarray[i-1];
  }
}
int getUserInput(Investment *invp) {

  int valid;
  char msg[100]={};
  sprintf(msg,"Enter investment, growth rate, number of yrs (up to %d): ",MAX_YEARS);
  NU32_WriteUART3(msg);
  NU32_ReadUART3(msg,100);
  sscanf(msg,"%lf %lf %d", &(invp->inv0), &(invp->growth), &(invp->years));

  valid = (invp->inv0 > 0) && (invp->growth > 0) &&
    (invp->years > 0) && (invp->years <= MAX_YEARS);
  sprintf(msg,"Valid input?  %d\n",valid);
  NU32_WriteUART3(msg);

  if (!valid) {
    sprintf(,"Invalid input; exiting.\n");
    NU32_WriteUART3(msg);
  }
  return(valid);
}

void sendOutput(double *arr, int yrs) {

  int i;
  char outstring[100];

  sprintf(msg,"\nRESULTS:\n\n");
  NU32_WriteUART3(msg);
  for (i=0; i<=yrs; i++) {
    sprintf(outstring,"Year %3d:  %10.2f\n",i,arr[i]);
    sprintf(msg,"%s",outstring);
    NU32_WriteUART3(msg);
  }
    printf(msg,"\n");
    NU32_WriteUART3(msg);
}
