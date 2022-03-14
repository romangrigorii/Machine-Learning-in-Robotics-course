#include <stdio.h>
#include "NU32.h"
#include "Inv.h"
#include "io.h"
#include "calculate.h"

int main(void) {
  NU32_Startup();
  int inv;
  while(getUserInput(&inv)) {
    inv.invarray[0] = inv.inv0;
    calculateGrowth(&inv);
    sendOutput(inv.invarray,
               inv.years);
  }
  return 0;
}
