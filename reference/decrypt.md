# Decrypt a ciphertext

Decrypt a ciphertext

## Usage

``` r
decrypt(ct, key, ...)
```

## Arguments

- ct:

  A Ciphertext

- key:

  A PrivateKey

- ...:

  Additional arguments (cc = CryptoContext)

## Value

A Plaintext

## Examples

``` r
cc <- fhe_context("CKKS", multiplicative_depth = 2L,
                  scaling_mod_size = 50L, batch_size = 8L)
kp <- key_gen(cc, eval_mult = TRUE)
pt <- make_ckks_packed_plaintext(cc, c(0.25, 0.5, 0.75, 1))
ct <- encrypt(kp@public, pt, cc = cc)

## Add the encrypted vector to itself, then decrypt. Decryption
## returns a Plaintext padded out to the full slot count, so trim it
## back to the length that was encoded.
out <- decrypt(eval_add(ct, ct), kp@secret, cc = cc)
out <- set_length(out, 4L)
get_real_packed_value(out)
#> [1] 0.5 1.0 1.5 2.0
```
