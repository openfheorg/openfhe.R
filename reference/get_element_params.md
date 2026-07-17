# Element parameters of a CryptoContext

Returns the `ElementParams` S7 object wrapping
`std::shared_ptr<typename DCRTPoly::Params>`. This is the object that
can be passed as the `params` argument to
[`make_ckks_packed_plaintext()`](https://openfheorg.github.io/openfhe.R/reference/make_ckks_packed_plaintext.md)
to build a plaintext against a specific parameter set rather than the
context default.

## Usage

``` r
get_element_params(cc, ...)
```

## Arguments

- cc:

  A `CryptoContext`.

- ...:

  Reserved for future method-specific arguments.

## Value

An `ElementParams` S7 object.

## Details

This is the first R-side way to obtain a non-default `ElementParams`
(the class itself has existed as a scaffold but had no constructor path
until now).
