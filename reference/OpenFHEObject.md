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
