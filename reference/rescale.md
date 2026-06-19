# Rescale a CKKS ciphertext (alias for ModReduce)

Reduces the modulus chain by one level. Required after `eval_mult` under
`FIXEDMANUAL` scaling; automatic under `FIXEDAUTO` / `FLEXIBLEAUTO`.

## Usage

``` r
rescale(ct, ...)
```

## Arguments

- ct:

  A Ciphertext

- ...:

  Reserved for future method-specific arguments

## Value

A Ciphertext at one lower level
