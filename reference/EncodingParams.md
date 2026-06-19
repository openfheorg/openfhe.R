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
