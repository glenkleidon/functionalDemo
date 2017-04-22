# Functional Programming Demo

## 1. Immutability.  Elements/variables should be immutable

     (a).  remove public setters from the class
     (b).  set the filename in the constructor
     (c).  call set header directly ?  Is it really just getHeader when (it loads the body and checks if the file exists??
     (d).  remove Body property - enherently mutable Object of TString lost some functionality - but were we really doing anything with it anyway??

## 2. Code Honesty. A function does does what it says, uses only what you give it and returns only what it says 

There are a number of aspects here.  Side effects (generally) are things that happen when there is nothing in the method signature to suggest it.  Althought there is a more strict definition (get to it later).  Exceptions also come into play

     (a). getHeaders - Property getter is not just getting the header (with concessions), we would rather like it to just get the header and the actual loading of the file should be made more obvious.
          (i). FileLoaded & LoadFileSuccessfully 
          (ii). Now loadHeader is a little more honest.
     (b). GetFileLoaded
     (c). Remove LocateRow

## 3. Primitive Obsession

Validation can be handled at a concept level - a filename is not a string.  So we want encapsulate the concept
of a filename before passing it to our function so the function does not have
to worry about things it is not really interested in.

     (a). TValidated Filename class
     (b). TValidated FIlename as record
     (c). TValidRow as class


