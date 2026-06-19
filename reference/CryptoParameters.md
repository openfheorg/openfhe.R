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
