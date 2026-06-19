# Element Parameters (opaque)

Wraps `std::shared_ptr<typename DCRTPoly::Params>` on the C++ side. Used
by the `params` argument of CKKS plaintext factories and returned by
[`get_element_params()`](https://bnaras.github.io/openfhe.R/reference/get_element_params.md).
This class ships as scaffolding only: no constructor surface other than
wrapping an existing external pointer.

## Usage

``` r
ElementParams(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)
