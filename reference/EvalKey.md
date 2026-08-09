# EvalKey class for multi-party key operations

EvalKey class for multi-party key operations

## Usage

``` r
EvalKey(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `EvalKey`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++
`EvalKey<DCRTPoly>`. An evaluation key is the public material that lets
the computing party carry out one operation — a relinearization, a
rotation, or a re-encryption — without the secret key. Obtain one from
[`multi_key_switch_gen()`](https://openfheorg.github.io/openfhe.R/reference/multi_key_switch_gen.md)
or the rest of the `multi_*()` family rather than by calling this
constructor directly.
