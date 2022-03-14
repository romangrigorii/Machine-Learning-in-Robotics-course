#include "isense.h"
#include "NU32.h"

void ADCinitialize(){
  initADC(); // reset ADC counts 
  AD1CHSbits.CH0SA = 15; // Set Pin for data collection
  AD1PCFGbits.PCFG15 = 0; //set pin 15 to be analog input
  AD1CON1bits.ON = 1;  // enable ADC
  AD1CON3bits.ADCS = 2; // set ADC clock period to 75ns
}
