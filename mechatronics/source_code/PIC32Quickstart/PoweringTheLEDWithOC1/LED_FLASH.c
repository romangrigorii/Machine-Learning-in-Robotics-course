#include "NU32.h"
#define NUMSAMPS 1000
static volatile int Waveform[NUMSAMPS];
#define P2VAL 1249
#define P3VAL 3999


void makeWaveform(void){
  int i = 0, center = (P3VAL+1)/2, A = center/2;
  for(i=0;i<NUMSAMPS;++i){
    if (i<NUMSAMPS/2){
      Waveform[i]= center + A;
    }
    else {
      Waveform[i] = center - A;
    }
  }
}

void __ISR(_TIMER_2_VECTOR, IPL5SOFT) Controller(void){
  static int counter = 0;
  counter++;
  OC1RS = Waveform[counter];
  if(counter==NUMSAMPS){
    counter=0;
  }
  IFS0bits.T2IF=0;
}

int main(void) {
  NU32_Startup();
  __builtin_disable_interrupts();
  makeWaveform();
  T3CONbits.TCKPS = 0;
  PR3 = P3VAL;
  TMR3 = 0;
  OC1RS = 3000;
  OC1R = 3000;
  T3CONbits.ON = 1;

  T2CONbits.TCKPS = 6;
  PR2 =  P2VAL;
  TMR2 = 0;
  T2CONbits.TGATE = 0;
  T2CONbits.ON = 1;
  OC1CONbits.OCM = 0b110;
  OC1CONbits.ON = 1;
  OC1CONbits.OCTSEL = 1;
  IPC2bits.T2IP = 5;
  IPC2bits.T2IS = 0;
  IFS0bits.T2IF = 0;
  IEC0bits.T2IE = 1;


  __builtin_enable_interrupts();
  while(1) {
    ;                      // infinite loop
  }
  return 0;
}
