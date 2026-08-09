# Execution Mode

Mirrors the C++ enum `ExecutionMode` in `pke/constants-defs.h`.

## Usage

``` r
ExecutionMode
```

## Value

A named `list` of 2 integer scalars, each the value of the OpenFHE C++
enumerator of the same name: `EXEC_EVALUATION` runs the computation
normally, while `EXEC_NOISE_ESTIMATION` runs it only to measure the
noise growth, which is the first of the two passes needed when
decryption uses noise flooding. Pass an element as the `execution_mode`
argument of
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
