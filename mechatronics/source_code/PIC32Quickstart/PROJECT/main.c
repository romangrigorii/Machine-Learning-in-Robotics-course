#include "NU32.h"
#include "LCD.h"
#include <math.h>
#include "encoder.h"
#include "isense.h"
#define BUF_SIZE 200 //Size of the buffer to be sent between PIC32 and MATLAB
#define IcountMax 99 // The size of samples for TEST option
static volatile int PHASE = 1; // Spin direction of the motor. o = CW 1 = CCW
static int PWM = 0; // value between 0 and 4000 that will set DS of 20kHz PWM
static volatile int Icount = 0 ,IIcount = 0; // counters for TEST option
static volatile int Iref = 200, Iact = 0; // current values for TEST option
static volatile int IrefArray[IcountMax+1], IactArray[IcountMax+1]; // current
// arrays for TEST option
static volatile float IKp = 0,IKi = 0,PKp = 0,PKd = 0,PKi = 0, Kt = 1;
// The gain values. IKp and IKi are current proportional and integral gains.
// PKp, PKd, PKi are position proportional, derivative and integral gains.
// Kt is the Feedforward gain.
static char mesg[20]; // Used to write on to LCD
static char buffer[BUF_SIZE]; // buffer for data exchange between PIC32 and MATLAB
static volatile int Ie, INTIe; // Current error and integral error respectively
static volatile int Pe = 0, Pde = 0, Pie = 0, Pelast; // Position error,
// derivative error, integral error and previous value of the error respectively
static volatile int DataReady = 0, TrajDataReady = 0, FFon = 0, dataSend = 0;
// Data Ready is used to tell PIC32 to send acquired data during TEST to MATLAB
// for ploting. TrajDataReady has the same functon, but for TRACK option. FFon
// turns FeedForward on and off.
static volatile int uI,uP; //used to unwind the current and position integrators
static volatile int refAngle, refCounts; // refAngle will be read for the HOLD
// option. refCounts will be used as reference in the controls.
static volatile int i,c; // generic indeces for loop operations
static volatile int Current; // This variable will be set by Pcontrol and used as
// reference value for current by Icontrol
static volatile int trajP, Position, traj_size; // tracking the trajectory
// information in the TRACK mode.
static volatile int traj[2000], trajActual[2000]; // data of reference and actual
// degree values ecieved and sent during TRACK mode
static volatile int ThetaV=0, ThetaA = 0, oldThetaV=0, oldTheta = 0,Theta = 0;
//Angle information used for feed forward.
static volatile int setTrack = 0;
/* FFAngleInfo updates angle information for feed forward */
static volatile int avg_num = 100; // will set the number of times ADC values will be read,
// and then averaged over.
static volatile double total; // sum of all ADC values read per counter iteration
unsigned volatile int start_time; // time when sampling begins
unsigned volatile int end_time; // time when sampling ends

/* FFangleInfo will calculate angle, angular velocity, and angular accelaration
of the motor when called, based on the last and new readings of the motor */

void FFAngleInfo(void){
  oldTheta = Theta; // keep old angle
  Theta = encoder_counts();
  Theta = encoder_counts(); //update new angle
  oldThetaV = ThetaV; //keep old velocity
  ThetaV = Theta - oldTheta; //update new velocity
  ThetaA = ThetaV - oldThetaV; //update acceleration
}
/* FFangleInit initializes the angles of the motor. This should be called in main
before any feedforward control is being done */
void FFAngleInit(void)
{
  oldTheta = 0;
  Theta = 0;
  oldThetaV = 0;
  ThetaV = 0;
  ThetaA = 0;
}
/* unitADC initlaizes the ADC counts */
void initADC(void){
  ADC = 0; //reset the ADC count
}

/* ADCtoCurrent converts ADC counts to current (mA) based on the equation
I have derived by applying various currents to the current amplifier, and
reading the counts from the ADC */

int ADCtoCurrent(void){
  return (int) (2.2436*ADC - 1135);
}

/* readADC reads and averages ADC counts, to get an accurate reading of the
current currently being supplied to the motor */

int readADC(void){
  _CP0_SET_COUNT(0); // Start the timer
  total = 0; // Initialize the total ADC count
  for (i=0; i<avg_num; i++){
    AD1CON1bits.SAMP = 1;  // make SHA begin sampling
    start_time = _CP0_GET_COUNT(); // Get clock count for sampling time
    end_time = start_time + 20; // Sampling for 20*25ns=500ns
        while(_CP0_GET_COUNT() < end_time){
      ;
    }
    AD1CON1bits.SAMP = 0; // make SHA stop sampling
    while(!AD1CON1bits.DONE){ // wait for cnversion
      ;
    }
    total = ADC1BUF0 + total; //add the new reading to the total
  }
  ADC = (int) total/avg_num ; // Get the average value from ADC
  return ADC;
}

/* Icontrol is the current control. When called, it will set the PWM cycles
that will set the current across the motor, using Current value that is set by
Pcontrol as reference current. */
void Icontrol(int Iref, int Iact){

  Ie = Iref-Iact; //Computing the proportional, derivative errors
  INTIe = INTIe + Ie;
  uI = Ie*IKp + INTIe*IKi; // The control value is calculated

  PHASE = 1; // Phase = 1 will get motor rolling in CCw direction

  if (uI<0){ //If the control value is negative, that means the actual current is
    // too high, and the motor needs some current to be applied in the other
    // direction
    uI = -uI;
    PHASE = 0; //Phase = 0 will get the motor moving in CW direction
  }
  NU32_LED2 = PHASE; // The LED and the directional pin are set

  if (uI > 400){//Integrator antiwindup
    uI = 400;
  }
  OC1RS = (unsigned int) uI*10; // the PWM driving the motor is set
}
/* Pcontrol updates Current value, based on its control gains and the position
of the bar relative to the referecne trajectory */


void Pcontrol(int Pref, int Pact){
  PHASE = 1;
  Pelast = Pe; //proportional, derivative, and integral errors are computed
  Pe = Pref - Pact;
  Pie = Pie + Pe;
  Pde = Pe - Pelast;

  //FFAngleInfo(); // This is where the angles for feed forward would be recomputed
  uP = PKp*Pe + PKd*Pde + PKi*Pie/1000;  //(int) FFon*(1/Kt * (ThetaA + sin(Theta) + ThetaV));
  PHASE = 1;
  if (uP<0){
    PHASE = 0;
    uP = -uP;
  }
  if (uP > 400){ // integrator antiwindup
    uP = 400;
  }
    NU32_LED2 = PHASE;

  if (PHASE){ //depending on the phase, the current will change signs
    Current  = (int) uP*10;
  }
  else{
    Current  = (int) -uP*10;
  }
  INTIe = 0; //current integrator reset
}

/* printtoLCD will print the current mode, along with the gains set by
the user */
void printToLCD(char * msg) {
  LCD_WriteString(msg);
  LCD_WriteString(" ");
  sprintf(mesg,"Kp:%1.1fi:%1.1f", IKp, IKi);
  LCD_WriteString(mesg);
  LCD_Move(1,0);
  sprintf(mesg,"Kp:%1.1fd:%1.1fi:%1.1f ", PKp, PKd, PKi);
  LCD_WriteString(mesg);
  LCD_Move(0,0);
}

/* PCONTROLinit initilizes the 200Hz ISR that will be used for position control */

void PCONTROLinit(void){
  TRISDbits.TRISD1 = 0;
  T4CONbits.TCKPS = 6; // timer 3 prescalar is 64
  PR4 =  6249; // set period to (6249 + 1)*64*12.5 = 5ms (200Hz)
  TMR4 = 0; // set timer 2 to 0
  T4CONbits.TGATE = 0; // timer doesn't stop based on signal high or low
  IPC4bits.T4IP = 4; // priority level 4
  IPC4bits.T4IS = 0; // subpriority level 0
  IFS0bits.T4IF = 0; // interrupt flag off
  IEC0bits.T4IE = 1; // interrupt enable
  T4CONbits.ON = 1; // turn timer  on
}

/* ICONTROLinit initilizes the 20kHz PWM as well as 5kHz ISR for the current
control */

void ICONTROLinit(void){
  // Timer 3 will be utilized for 20kHZ PWM
  PR3 = 3999; // set period to (3999+1)*1*12.5 = 50us (20kHz)
  TMR3 = 0; // set timer 3 to 0
  OC1CONbits.OCM = 0b110; //PWM mode without fault pin
  OC1CONbits.ON = 1; // eanbles output compare module
  OC1CONbits.OCTSEL = 1; // Timer 3 chosen for OC
  OC1RS = 0;
  OC1R = 0;
  T3CONbits.ON = 1; // turn the timer on

  // Timer 2 will be utilized for 5kHZ ISR
  T2CONbits.TCKPS = 6; // timer 3 prescalar is 64
  PR2 =  249; // set period to (249 + 1)*64*12.5 = .2ms (5kHz)
  TMR2 = 0; // set timer 2 to 0
  T2CONbits.TGATE = 0; // timer doesn't stop based on signal high or low
  IPC2bits.T2IP = 5; // priority level 5
  IPC2bits.T2IS = 0; // subpriority level 0
  IFS0bits.T2IF = 0; // interrupt flag off
  IEC0bits.T2IE = 1; // interrupt enable
  T2CONbits.ON = 1; // turn timer 2 on
}


void __ISR(_TIMER_4_VECTOR, IPL4SOFT) PController(void){
  switch(getModeSimple()){
    case 'd':{ //HOLD MODE
      if (setTrack==1){ // if the reference count has been found once, it will
        // not be recomupted unti refAnge changes */
      refCounts = 32768 + (int) (refAngle*1760/360);
      setTrack = 0;
      }

      if(refCounts<encoderCounts){
            c = 1;
          }
      else {
            c = -1;
       }
       /* unwind the counts, so the motor doesn't have to spin back
       to the reference encoder counts, rather to the closest reference angle */
      while(abs(refCounts-encoderCounts)>1760){
            refCounts = refCounts + c*1760;
          }

      Pcontrol(refCounts,encoderCounts); // reference current gets set

/* If there is data to send, it will be sent to matlab in small increments */
      if (TrajDataReady){
        dataSend = 0;
        while(dataSend<5){
        if(Position<traj_size){
          sprintf(buffer,"%d\n",trajActual[Position]);
          NU32_WriteUART3(buffer);
          Position++;
          }
          else {
          Position = 0;
          TrajDataReady = 0;
        }
        dataSend++;
      }
    }
      break;
    }
    case 'e':{//TRACK MODE
      if(Position<traj_size){
        encoderCounts = encoder_counts();
        encoderCounts = encoder_counts(); // encoderCounts computed twice due to bug
        trajActual[Position] = encoderCounts; // atual position
        Pcontrol(traj[Position],encoderCounts); // Current gets updated based
        // on reference position
        Position++;
      }
      else{
        refCounts = traj[traj_size - 1];
        setMode("HOLD");
        TrajDataReady = 1; //get ready to send data
        Position = 0; //Position ges reset to send data in the right order
        setTrack = 1;
      }
      break;
    }
  }
    LATDINV = 0x02; // 200Hz Heartbeat to be observed.
    IFS0bits.T4IF=0; // turn flag off
}

void __ISR(_TIMER_2_VECTOR, IPL5SOFT) Controller(void){
  switch(getModeSimple()){
    case 'a':{ //IDLE MODE
      OC1RS = 0;
      if (DataReady){ // If there is current test data ready, it will be sent over
        __builtin_disable_interrupts();
        sprintf(buffer,"%d\n",IcountMax+1);
        NU32_WriteUART3(buffer);
        while(Icount<=IcountMax){
          sprintf(buffer,"%d %d\n",IrefArray[Icount],IactArray[Icount]);
          NU32_WriteUART3(buffer);
          Icount++;
        }
        DataReady = 0; // data is no longer available to send
        Icount = 0; //The index at which te data is being acessed is reset
      }
      __builtin_enable_interrupts();

      printToLCD("IDLE"); // print the mode to LCD
      break;
    }
    case 'b':{ //PWM MODE
      printToLCD("PWM");
      NU32_LED2 = PHASE; //the phase is set to match the needed direction
      OC1RS = PWM*40; // input PWM ranging from 0 to 100 will set the duty cycle
      break;
    }
    case 'c':{ //ITEST MODE
     if(IIcount == 25){ // a square wave is created to be used as current reference
        Iref = -Iref;
        IIcount = 0;
      }

      ADC = readADC();
      Iact = ADCtoCurrent();
      IrefArray[Icount]=Iref;
      IactArray[Icount]=Iact;
      Icontrol(Iref,Iact); //use the current control to get to necessary reference
      // current
      Icount++;
      IIcount++;

      if (Icount == IcountMax){
        setMode("IDLE"); //after current test, the motor is powered off
        Icount = 0;
        IIcount = 0;
        DataReady = 1; // There is data to be sent to MATLAB for plotting
      }
      break;
    }
    case 'd':{ //HOLD MODE
      Icontrol((int) Current,ADCtoCurrent()); //PWM duty cycle is updated constantly
      printToLCD("HOLD"); // print the mode to the screen
      break;
    }
    case 'e':{ //TRACK MODE
      Icontrol((int) Current,ADCtoCurrent());  //PWM duty cycle is updated constantly
      printToLCD("TRACK"); //print the mode to the screen
      break;
    }

  }
  IFS0bits.T2IF=0; // interrupt has been handled, flag turns off
};

int main()
{
  __builtin_disable_interrupts();
  PCONTROLinit(); //Initialize 200 Hz position controller ISR
  ICONTROLinit(); //Intitilize 5kHz current controller ISR
  LCD_Setup(); // Begin communicating with LCD
  LCD_Clear(); // Clear the LCD
  LCD_Move(0,0);
  ADCinitialize(); //The ADC counts are reset, and ADC pin is initialized
  setMode("IDLE"); //power the moter off at startup
  NU32_Startup(); // cache on, min flash wait, interrupts on, LED/button init, UART init
  encoder_init(); //intialize the encoder
  __builtin_enable_interrupts();
  // in future, initialize modules or peripherals here

  while(1)
  {
    NU32_ReadUART3(buffer,BUF_SIZE); // we expect the next character to be a menu command
    INTIe = 0; //reset the current integrator
    Pie = 0; //reset the position integrator
    switch (buffer[0]) {
      case 'a':
      {
        __builtin_disable_interrupts();
        sprintf(buffer,"%d\r\n",readADC()); // send ADC reading to MATLAB
        NU32_WriteUART3(buffer);
        __builtin_enable_interrupts();
        break;
      }
      case 'b':
      {
        __builtin_disable_interrupts();
        sprintf(buffer,"%d\r\n",readADC());
        sprintf(buffer,"%d\r\n", ADCtoCurrent());
        __builtin_enable_interrupts();
        NU32_WriteUART3(buffer); //send current readings across the motor
        break;
      }
      case 'c':
      {
        __builtin_disable_interrupts();
        sprintf(buffer,"%d\r\n",encoder_counts());
        sprintf(buffer,"%d\r\n",encoder_counts());
        __builtin_enable_interrupts();
        NU32_WriteUART3(buffer); // send display encoder counts
        break;
      }
      case 'd':  // dummy command for demonstration purposes
      {
        sprintf(buffer,"%d\n",encoder_counts());
        sprintf(buffer,"%d\n",encoder_counts());
        NU32_WriteUART3(buffer);
        break;
      }
      case 'e':
      {
        encoder_reset(); //reset encoder count
        break;
      }
      case 'f':
      {
        LCD_Clear();
        NU32_ReadUART3(buffer,BUF_SIZE);
        sscanf(buffer,"%d", &PWM); // get PWM duty cycle
        PHASE = 1;
        if(PWM<0){ // set the direction of the motor
          PWM = -1*PWM;
          PHASE = 0;
        }
        setMode("PWM"); // change the mode
        break;
      }
      case 'g':
      {
        NU32_ReadUART3(buffer,BUF_SIZE);
        sscanf(buffer,"%f %f", &IKp, &IKi); // get the current control gains from MATLAB
        break;
      }
      case 'h':
      {
        break;
      }
      case 'i':
      {
        NU32_ReadUART3(buffer,BUF_SIZE);
        sscanf(buffer,"%f %f %f", &PKp, &PKd, &PKi); // get position control gains from MATLAB
        break;
      }
      case 'j':
      {
        break;
      }
      case 'k':
      {
        setMode("ITEST");
        break;
      }
      case 'l':
      {
        NU32_ReadUART3(buffer,BUF_SIZE);
        sscanf(buffer,"%d\n", &refAngle); // set the reference Angle
        setMode("HOLD");
        setTrack = 1; // used for feed forward
        break;
      }
      case 'm':{
        __builtin_disable_interrupts();
        NU32_ReadUART3(buffer,BUF_SIZE);
        sscanf(buffer,"%d\n", &traj_size); //read the size of incoming array
        for (i=0;i<traj_size;i++){
          NU32_ReadUART3(buffer,BUF_SIZE);
          sscanf(buffer,"%d\n", &trajP);
          traj[i] = trajP; // save the reference points
        }
        __builtin_enable_interrupts();
        break;
      }
      case 'n':{
        __builtin_disable_interrupts();
        NU32_ReadUART3(buffer,BUF_SIZE);
        sscanf(buffer,"%d\n", &traj_size); // read the size of incoming array
        for (i = 0;i < traj_size;i++){
          NU32_ReadUART3(buffer,BUF_SIZE);
          sscanf(buffer,"%d\n", &trajP);
          traj[i] = trajP;// save the reference points
        }
        __builtin_enable_interrupts();
        break;
      }
      case 'o':{
        FFAngleInit(); // reset angle values
        Position = 0;
        setMode("TRACK"); //tracking the set path
        break;
      }
      case 'p':
      {
        LCD_Clear();
        setMode("IDLE"); // power off
        break;
      }
      case 'q':
      {
        LCD_Clear();
        setMode("IDLE"); // power off
        break;
      }
      case 'r':
      {
        sprintf(buffer,"%s\r\n",getMode()); //find the current mode
        NU32_WriteUART3(buffer);
        break;
      }
      case 'y':
      {
        NU32_ReadUART3(buffer,BUF_SIZE);
        sscanf(buffer,"%d%d\n", &Kt, &FFon); // get feedforward gaisn from MATLAB
        break;
      }
      default:
      {
        break;
      }
    }
  }
  return 0;
}
