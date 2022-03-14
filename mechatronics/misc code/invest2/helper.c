#include <stdio.h>
#include "NU32.h"
#include "helper.h"

void calculateGrowth(Investment *invp) {

  int i;

  for (i = 1; i <= invp->years; i= i + 1) {
    invp->invarray[i] = invp->growth * invp->invarray[i-1];
  }
}

int getUserInput(Investment *invp) {
  char msg[100]={}; //msg will store all the transiting messages
  int valid;
  sprintf(msg,"Enter investment, growth rate, number of yrs (up to %d):\n\r",MAX_YEARS);
  NU32_WriteUART3(msg); // The initial message is sent to the PIC
  NU32_ReadUART3(msg,100); // The input is read
  sscanf(msg,"%lf %lf %d", &(invp->inv0), &(invp->growth), &(invp->years));
  // the informtion stored in msg is broken down to be used
  valid = (invp->inv0 > 0) && (invp->growth > 0) &&
    (invp->years > 0) && (invp->years <= MAX_YEARS);
  sprintf(msg,"Valid input?  %d\n\r",valid);
  NU32_WriteUART3(msg);//the message is sent to the pic

  if (!valid) {
    sprintf(msg,"Invalid input; exiting.\n\r");
    NU32_WriteUART3(msg);
  }
  return(valid);
}

void sendOutput(double *arr, int yrs) {
  char msg[100]={};
  int i;
  char outstring[100];

  sprintf(msg,"\nRESULTS:\n\n\r");
  NU32_WriteUART3(msg);
  for (i=0; i<=yrs; i++) {
    sprintf(outstring,"Year %3d:  %10.2f\n\r",i,arr[i]);
    sprintf(msg,"%s",outstring);
    NU32_WriteUART3(msg);
  }
    printf(msg,"\n\r");
    NU32_WriteUART3(msg);
}
