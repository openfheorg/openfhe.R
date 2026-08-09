# Base class for OpenFHE objects

All OpenFHE objects (CryptoContext, Ciphertext, Plaintext, Keys, etc.)
inherit from this class. It holds an external pointer to a C++
shared_ptr.

## Usage

``` r
OpenFHEObject(ptr = NULL)
```

## Arguments

- ptr:

  External pointer to C++ object (internal use)

## Value

An S7 object of class `OpenFHEObject`, the base class every object in
this package inherits from. It has a single property, `ptr`, holding an
external pointer to the underlying C++ `shared_ptr`. Constructing one
directly is of no use; the class exists so that methods can dispatch on
the common parent and so that the pointer is managed in one place.
