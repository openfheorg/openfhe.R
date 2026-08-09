# Element Parameters (opaque)

Wraps `std::shared_ptr<typename DCRTPoly::Params>` on the C++ side. Used
by the `params` argument of CKKS plaintext factories and returned by
[`get_element_params()`](https://openfheorg.github.io/openfhe.R/reference/get_element_params.md).
This class ships as scaffolding only: no constructor surface other than
wrapping an existing external pointer.

## Usage

``` r
ElementParams(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `ElementParams`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++
`DCRTPoly::Params`. It is an opaque token describing the ring the
polynomials live in, obtained from
[`get_element_params()`](https://openfheorg.github.io/openfhe.R/reference/get_element_params.md)
and passed on to the CKKS plaintext factories.
