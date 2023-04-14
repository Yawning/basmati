#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#define VLEN 128

void addvec_c(uint32_t *r, const uint32_t *a, const uint32_t *b)
{
  size_t i;

  for(i=0;i<VLEN;i++)
    r[i] = a[i] + b[i];
}


extern void addvec_jasmin3x(uint32_t *r0, uint32_t *r1, uint32_t *r2, const uint32_t *a, const uint32_t *b);

int main(void)
{
  uint32_t a[VLEN], b[VLEN], r0[VLEN], r1[VLEN], r2[VLEN], rc[VLEN];
  size_t i;


  FILE *urandom = fopen("/dev/urandom", "r");
  fread(a, sizeof(uint32_t), VLEN, urandom);
  fread(b, sizeof(uint32_t), VLEN, urandom);
  fclose(urandom);

  addvec_c(rc, a, b);
  addvec_jasmin3x(r0, r1, r2, a, b);
  
  for(i=0;i<VLEN;i++)
  {
    if(rc[i] != r0[i])
    {
      printf("Error in r0 at position %lu\n", i);
      return -1;
    }
    if(rc[i] != r1[i])
    {
      printf("Error in r1 at position %lu\n", i);
      return -1;
    }
    if(rc[i] != r2[i])
    {
      printf("Error in r2 at position %lu\n", i);
      return -1;
    }
  }

  return 0;
}
