#include "NU32.h"
#include "LCD.h"
#include <math.h>
#include <cp0defs.h>
#define NUMSAMPS 1000 //Number of parts a waveform will be subdivided into
#define P2VAL 1249 //The period of interrupt signal 80MHz/((1249 + 1)*64)=1kHz
#define P3VAL 3999 //The PWM related period. 80Mhz/((399+1)*1)=20kHz
#define PLOTPTS 200 //The number of data points to plot
#define DECIMATION 10 //there will be one point plotted out of # DECIMATION
// points collected.

static volatile int Waveform[NUMSAMPS]; //The reference waveform
static volatile int ADCarray[PLOTPTS]; //The measured values to be plotted
static volatile int REFarray[PLOTPTS]; //The reference values to plot
static volatile int CRLarray[PLOTPTS]; // Duty cycle values being
static volatile int StoringData=0; //A flag that will stop interrupts to allow
// plotting to take place
static volatile float Kp=0, Ki=0; //Gain variables
static volatile int Eint = 0; //Integrated value so far in feedback

/* Prints the values of Kp and Ki on the CD screen */
void printGainsToLCD(void) {
  char msg[100];
  sprintf(msg,"Kp: %2.4f", Kp);
  LCD_WriteString(msg);
  LCD_Move(1,0);
  sprintf(msg,"Ki: %2.4f", Ki);
  LCD_WriteString(msg);
  LCD_Move(0,0); // Move the curcer to the beginning so the next vals get printed
}
/* A reference waveform that will set the the duty cycle of PWM on the LED
wherefore setting a refeence brightness */

void makeWaveform(int center, int A){ // makes a square Waveform at 1 Hz,
  // amplitude A, and vertical shift of center
  int i = 0;
  for(i=0;i<NUMSAMPS;++i){
    if (i<NUMSAMPS/2){
      Waveform[i]= center + A;
    }
    else {
      Waveform[i] = center - A;
    }
  }
}
/* Wave types that can be used for reference */

 void makeWaveformSIN(double T, int center, int A){ // makes sin Waveform with
  // period T, amplitude A, and vertical shift of center
  int i;
  for(i=0;i<NUMSAMPS;++i){
    Waveform[i] = (int) A*sin(2*3.14*i/T) + center;
    }
  }
  void makeWaveformSAWF(int center, int A){ //front sloping saw wave
    int i = 0;
    for(i=0;i<NUMSAMPS;++i){
      Waveform[i]= i*2*A/NUMSAMPS + (center-A);
    }
  }
  void makeWaveformSAWB(int center, int A){ //backward sloping saw wave
    int i = 0;
    for(i=0;i<NUMSAMPS;++i){
      Waveform[i]=(NUMSAMPS-i)*2*A/NUMSAMPS + (center-A);
    }
  }
  void makeWaveformMATLAB(int * array){ //waveform recieved from MATLAB
    int i = 0;
    for(i=0;i<NUMSAMPS;i++){
      Waveform[i]=array[i];
    }
  }

/* A controller used for feedback */
int PIcontroller(int ref, int act){ // a controller for out feedback
  Eint = Eint + (ref - act); // accumulating error for integral control
  return(Kp*(ref-act) + Ki*Eint);

}

void __ISR(_TIMER_2_VECTOR, IPL5SOFT) Controller(void){
  static int avg_num; // will set the number of times ADC values will be read,
  // and then averaged over.
  static int i; // generic index
  static double total = 0; // sum of all ADC values read per counter iteration
  static int counter = 0; // keeps track of interrupts issued
  static int plotind = 0; // an index to be used for plotting
  static int decctr = 0; // used to count up to DECIMATION to send data
  static int adcval = 0; //value of Vout ranging from 0 to 1023 (0 to 3.3 V)
  static int unew, u; // variables used for turning off integrator
  unsigned int start_time; // time when sampling begins
  unsigned int end_time; // time when sampling ends
  _CP0_SET_COUNT(0); // Start the timer
  total = 0;
  avg_num = 50;
  for (i=0; i<avg_num; i++){
    AD1CHSbits.CH0SA = 15; // Set Pin for data collection
    AD1CON1bits.SAMP = 1; // make SHA begin sampling
    start_time = _CP0_GET_COUNT(); // Get clock count for sampling time
    end_time = start_time + 20; // Sampling for 20*25ns=500ns
        while(_CP0_GET_COUNT() < end_time){
      ;
    }
    AD1CON1bits.SAMP = 0; // make SHA stop sampling
    while(!AD1CON1bits.DONE){ // wait for cnversion
      ;
    }
    total = ADC1BUF0 + total;
  }
  adcval = (int) total/avg_num ; // Get the average value from ADC
  u = PIcontroller(Waveform[counter], adcval); // send refference and actual
  // duty cycle values

  unew = u + 50; //center unew
  if (unew > 100.0){ //set upper limit
    unew = 100.0;
  } else if (unew < 0.0){//set lower limit
    unew = 0.0;
  }
  OC1RS = (unsigned int) ((unew/100.0)*P3VAL); // set the clock cycle to close
  // the feedback loop

  if (StoringData) {
    decctr++; // store data every 10 points
    if (decctr == DECIMATION) {
      decctr = 0;
      ADCarray[plotind] = adcval;
      REFarray[plotind] = Waveform[counter];
      CRLarray[plotind] = OC1RS;
      plotind++;
    }
    if (plotind == PLOTPTS) { //once PLOTPTS number of data points is sent, the
      //program will stop storing data
      plotind = 0;
      StoringData = 0;
    }
  }
  counter++;
  if(counter==NUMSAMPS){
    counter=0;
  }
  IFS0bits.T2IF=0; // interrupt has been handles, flag turns off
}

int main(void) {
  char message[100]; // this message will contain gain values, as well as wave type
  char msg2[10]; // this message will contain values along specific wave specified
  // by MATLAB
  float kptemp = 0, kitemp = 0; // Temporary gain factors
  int MATLABval; // value read from MATLAB to assign to
  int center, AMP;
  int WaveType = 1; // Determines which reference wave will be used
  // The default is square wave
  int i = 0; // generic index
  NU32_Startup();
  __builtin_disable_interrupts();
  AD1PCFGbits.PCFG15 = 0; //set pin 15 to be analog input
  AD1CON1bits.ON = 1;  // enable ADC
  AD1CON3bits.ADCS = 2; // set ADC clock period to 75ns
  T3CONbits.TCKPS = 0; // timer 3 prescalar is 1
  PR3 = P3VAL; // set period to (3999+1)*1*12.5 = 50us (20kHz)
  TMR3 = 0; // set timer 3 to 0
  OC1RS = 2000; //(P3VAL+1)/2;
  OC1R = 2000; // (P3VAL+1)/2; // preset duty cycle to 50%
  T3CONbits.ON = 1; // turn the timer on

  T2CONbits.TCKPS = 6; // timer 3 prescalar is 64
  PR2 =  P2VAL; // set period to (1249 + 1)*64*12.5 = 1ms (1kHz)
  TMR2 = 0; // set timer 2 to 0
  T2CONbits.TGATE = 0; // timer doesn't stop based on signal high or low
  T2CONbits.ON = 1; // turn timer 2 on
  OC1CONbits.OCM = 0b110; //PWM mode without fault pin
  OC1CONbits.ON = 1; // eanbles output compare module
  OC1CONbits.OCTSEL = 1; // Timer 2 chosen for comparison
  IPC2bits.T2IP = 5; // prority level 5
  IPC2bits.T2IS = 0; // subpriority level 0
  IFS0bits.T2IF = 0; // interrupt flag off
  IEC0bits.T2IE = 1; // interrupt enable
  __builtin_enable_interrupts();
  LCD_Setup(); // Begin communicating with LCD
  LCD_Clear(); // Clear the LCD
  LCD_Move(0,0); // Move the cursor to the start
  while(1) {
    NU32_ReadUART3(message,sizeof(message)); //wait to recieve a message from
   // MATLAB
    sscanf(message,"%f %f %d %d %d", &kptemp, &kitemp, &WaveType, &center, &AMP);
    switch(WaveType){ // make a reference wave based on user's choice
      case 1:
        makeWaveform(center,AMP);
        break;
      case 2:
        makeWaveformSIN(500,center,AMP);
        break;
      case 3:
        makeWaveformSAWF(center,AMP);
        break;
      case 4:
        makeWaveformSAWB(center,AMP);
        break;
      case 5:
        for (i=0;i<NUMSAMPS;i++){
          NU32_ReadUART3(msg2,sizeof(msg2));
          sscanf(msg2,"%d", &Waveform[i]);
        }
        break;
      }
    __builtin_disable_interrupts(); // disable interrupts which we set gains
    Kp=kptemp; // set gain values
    Ki=kitemp;
    Eint = 0; // Integrator reset
    __builtin_enable_interrupts();
    _CP0_SET_COUNT(0); //Set clock count
    StoringData = 1; // message to ISR to store data
    printGainsToLCD();
    while(StoringData){ //wait here until interrupt issued
    ; //Don't do anything
    }
    for(i=0 ; i<PLOTPTS ; i++){
      sprintf(message,"%d %d %d %d\r\n", PLOTPTS-i, ADCarray[i], REFarray[i], CRLarray[i]);
      NU32_WriteUART3(message); //send plot data to MATLAB
  }
  }
  return 0;
}
