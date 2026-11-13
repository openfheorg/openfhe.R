# Multiply two ciphertexts and reduce the modulus

Multiplies, relinearizes, and then reduces the modulus of the product by
one level, in one call. Needs the relinearization key.

## Usage

``` r
composed_eval_mult(ct1, ct2)
```

## Arguments

- ct1, ct2:

  `Ciphertext` objects.

## Value

A `Ciphertext`.
