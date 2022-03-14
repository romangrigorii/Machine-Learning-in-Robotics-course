#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define modeLength 10
static char MODE[modeLength];

void setMode (char * mode){
  strcpy(MODE,mode); //sets the mode
}

char* getMode(void){
  return MODE; // returns the current mode the user has set
}

char getModeSimple(void){ // returns the mode in characters, for easy switch statements
  char* mode = getMode();
  if (strcmp(mode, "IDLE") == 0)
{
  return 'a';
}
else if (strcmp(mode, "PWM") == 0)
{
 return 'b';
}
else if (strcmp(mode, "ITEST") == 0)
{
 return 'c';
}
else if (strcmp(mode, "HOLD") == 0)
{
 return 'd';
}
else if (strcmp(mode, "TRACK") == 0)
{
 return 'e';
 }
else return 'x';
}
