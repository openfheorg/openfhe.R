# Square, rescale or relinearize a ciphertext in place

The in-place forms of
[`eval_square()`](https://openfheorg.github.io/openfhe.R/reference/eval_square.md),
[`rescale()`](https://openfheorg.github.io/openfhe.R/reference/rescale.md)
and
[`relinearize()`](https://openfheorg.github.io/openfhe.R/reference/relinearize.md):
the result replaces the contents of the ciphertext.

## Usage

``` r
eval_square_in_place(ct)

rescale_in_place(ct)

relinearize_in_place(ct)
```

## Arguments

- ct:

  A `Ciphertext` (modified in place).

## Value

`ct`, invisibly.
