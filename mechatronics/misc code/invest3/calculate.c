#include <stdio.h>
#include "NU32.h"
#include "io.h"
#include "calculate.h"
#include "Inv.h"

void calculateGrowth(Investment *invp) {
  int i;
  for (i = 1; i <= invp->years; i= i + 1) {
    invp->invarray[i] = invp->growth * invp->invarray[i-1];
  }
}
