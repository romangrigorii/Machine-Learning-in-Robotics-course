#ifndef encoder
#define encoder
#include <xc.h>
static volatile int encoderDeg = 0, encoderCounts = 0; // encoder data

static int encoder_command(int read);
int encoder_counts(void);
void encoder_reset(void);
void encoder_init(void);

#endif
