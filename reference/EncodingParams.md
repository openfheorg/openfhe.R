# Encoding Parameters (opaque)

Wraps `std::shared_ptr<EncodingParamsImpl>` on the C++ side. Returned by
`get_encoding_params(cc)` and by `Plaintext::GetEncodingParams()` once
the corresponding Plaintext accessor lands. This class ships as
scaffolding only: the S7 class definition is in place so that the getter
wiring can treat it as already defined, but there is no constructor path
from R.

## Usage

``` r
EncodingParams(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `EncodingParams`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++
`EncodingParamsImpl`. It is an opaque token describing how values are
packed into a plaintext, obtained from
[`get_encoding_params()`](https://openfheorg.github.io/openfhe.R/reference/get_encoding_params.md)
rather than by calling this constructor directly.
