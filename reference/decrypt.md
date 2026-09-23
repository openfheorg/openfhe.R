# Decrypt a ciphertext

`decrypt` dispatches on both arguments and accepts them in either order,
as the C++ header does: `Decrypt(ciphertext, privateKey)` is the primary
form and `Decrypt(privateKey, ciphertext)` forwards to it
(`cryptocontext.h`, both overloads). The key-first order lets code that
is written around the holder of the key, such as a party object in a
protocol, put that holder first, the same way
[`encrypt()`](https://openfheorg.github.io/openfhe.R/reference/encrypt.md)
puts the key first.

## Usage

``` r
decrypt(ct, key, ...)
```

## Arguments

- ct:

  A `Ciphertext`, or a `PrivateKey` when the key-first order is used.

- key:

  A `PrivateKey`, or a `Ciphertext` when the key-first order is used.

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

## The same call with the key first:
out2 <- decrypt(kp@secret, eval_add(ct, ct), cc = cc)
get_real_packed_value(set_length(out2, 4L))
#> [1] 0.5 1.0 1.5 2.0
```
