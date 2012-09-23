// foo.c
// include either bar.h or bar1.h
                                 
#ifdef BAR1
  #include "bar1.h"
#else
  #include "bar.h"
#endif

int foo() { return MY_CONST; }
