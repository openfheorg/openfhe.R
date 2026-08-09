# Crypto Parameters (opaque)

Wraps `std::shared_ptr<CryptoParametersBase<DCRTPoly>>` on the C++ side.
Returned by `get_crypto_parameters(cc)` and used as an opaque token for
RNS-level parameter accessors such as `get_scaling_factor_real`,
`get_key_switch_technique`, etc. This class ships as scaffolding only:
the S7 class definition is in place so that the getter wiring can treat
it as already defined, but there is no constructor path from R.

## Usage

``` r
CryptoParameters(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `CryptoParameters`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++
`CryptoParametersBase<DCRTPoly>`. It is an opaque token: its contents
are read with the RNS-level accessors rather than from R, and it is
obtained from
[`get_crypto_parameters()`](https://openfheorg.github.io/openfhe.R/reference/get_crypto_parameters.md)
rather than by calling this constructor directly.
