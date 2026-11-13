# CKKS bootstrapping with slots-to-coefficients first

The slots-encoding variant of CKKS bootstrapping: the
slots-to-coefficients transform comes first, then the modulus raise, the
coefficients-to-slots transform and the approximate modular reduction.
It needs
[`eval_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_setup.md)
to have been called with `bt_slots_encoding = TRUE`; after such a setup
[`eval_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap.md)
calls this variant itself.

## Usage

``` r
eval_bootstrap_stc_first(ct, num_iterations = 1L, precision = 0L)
```

## Arguments

- ct:

  A `Ciphertext`.

- num_iterations:

  Integer; number of iterations. Default `1L`.

- precision:

  Integer; precision of the initial bootstrapping, `0L` (default) for
  the library's choice.

## Value

A refreshed `Ciphertext`.

## Details

Do not call it on a context with a regular setup. At OpenFHE 1.6.1 the
library does not check the kind of setup, and the error it then raises
ends the R session.

## See also

[`eval_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap.md)
