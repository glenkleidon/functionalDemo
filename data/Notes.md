# Functional Programming Demo

## Steps

### 1. Immutability.  Elements/variables should be immutable

     (a).  remove public setters from the class
     (b).  set the filename in the constructor
     (c).  call set header directly ?  Is it really just getHeader when (it loads the body and checks if the file exists??
     (d).  remove Body property - enherently mutable Object of TString lost some functionality - but were we really doing anything with it anyway??

### 2. Code Honesty. A function does what it says and only what is says

There are a number of aspects here.  Side effects (generally) are things that happen when there is nothing in the method signature to suggest it.  Althought there is a more string definition (get to it later).  

     (a). getHeader - Property getter is not just getting the header (with concessions), we would rather like it to just get the header and the actual loading of the file should be made more 
     obvious.
          (i). FileLoaded & LoadFileSuccessfully 
          (ii). Now loadHeader is a little more honest.


