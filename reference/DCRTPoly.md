# A ring element of a ciphertext

An element of the polynomial ring, in the double-CRT (RNS)
representation OpenFHE computes in. A ciphertext is a short list of
them. The class is an opaque handle, as in openfhe-python: it has no
methods of its own and exists so that the elements of one ciphertext can
be read with
[`get_elements()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md)
and written to another with
[`set_elements()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md).

## Usage

``` r
DCRTPoly(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `DCRTPoly`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md).
