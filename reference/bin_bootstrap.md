# Bootstrap an LWE ciphertext

Refreshes a ciphertext without applying a gate.

## Usage

``` r
bin_bootstrap(ctx, ct, extended = FALSE)
```

## Arguments

- ctx:

  A `BinFHEContext` with bootstrapping keys.

- ct:

  An `LWECiphertext`.

- extended:

  Logical; if `TRUE` the result is returned before key switching
  (modulus `Q`, dimension `N`). Default `FALSE`.

## Value

An `LWECiphertext`.

## See also

[`eval_bin_gate()`](https://openfheorg.github.io/openfhe.R/reference/eval_bin_gate.md)
