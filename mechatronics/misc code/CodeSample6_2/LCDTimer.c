#include "NU32.h"          // constants, funcs for startup and UART
#include <cp0defs.h>
#include "LCD.h"

unsigned int TIMERSTART = 0;
unsigned int TIMERSTOP = 0;
void __ISR(_EXTERNAL_2_VECTOR, IPL6SRS) Ext0ISR(void) { // step 1: the ISR
  LATFINV=0x3;                 // Setting the bits to be turned off
  char msg[100];
if(TIMERSTART == TIMERSTOP) {
  sprintf(msg,"Press USER to"); // Writing to LCD
  LCD_Clear();
  LCD_Move(0,0);
  LCD_WriteString(msg);
  LCD_Move(1,0);
  sprintf(msg,"stop timer");
  LCD_WriteString(msg);
  _CP0_SET_COUNT(0);
  while(_CP0_GET_COUNT() < 10000000 ) {;}
  TIMERSTOP = _CP0_GET_COUNT()*25.0/1000000.0; //Making TIMERSTOP different to
} //make sure the second condition is used on next interrupt

  else {
    TIMERSTOP = _CP0_GET_COUNT()*25.0/1000000.0+TIMERSTART;
    TIMERSTART = TIMERSTOP;
    sprintf(msg,"%3.2f s elapsed.", TIMERSTOP/1000.0);
    LCD_Clear();
    LCD_Move(0,0);
    LCD_WriteString(msg);
    _CP0_SET_COUNT(0);
    while(_CP0_GET_COUNT() < 10000000) {;}
  }
  IFS0bits.INT2IF = 0;     // clear interrupt flag IFS0<3>
}

int main(void) {
  char msg[100];
  NU32_Startup(); // cache on, min flash wait, interrupts on, LED/button init, UART init
  LCD_Setup();
  LCD_Clear();
  LCD_Move(0,0);
  __builtin_disable_interrupts(); // step 2: disable interrupts
  INTCONbits.INT2EP = 0;          // step 3: INT2 triggers on falling edge
  IPC2bits.INT2IP = 6;            // step 4: interrupt priority 2
  IPC2bits.INT2IS = 1;            // step 4: interrupt priority 1
  IFS0bits.INT2IF = 0;            // step 5: clear the int flag
  IEC0SET=0x800;                  // step 6: enable INT2 by setting IEC0<3>
  __builtin_enable_interrupts();  // step 7: enable interrupts
  sprintf(msg,"Press USER to");
  LCD_WriteString(msg);
  LCD_Move(1,0);
  sprintf(msg,"start timer");
  LCD_WriteString(msg);
  LATFSET=0x3;
  while(1) {
  }
  return 0;
}
