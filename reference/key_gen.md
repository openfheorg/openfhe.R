# Generate key pair

Generate key pair

## Usage

``` r
key_gen(cc, ...)
```

## Arguments

- cc:

  A CryptoContext

- ...:

  Method-specific arguments (eval_mult, rotations)

## Value

A KeyPair

## Examples

``` r
cc <- fhe_context("CKKS", multiplicative_depth = 2L,
                  scaling_mod_size = 50L, batch_size = 8L)

## Encryption keys only:
kp <- key_gen(cc)
kp
#> <KeyPair> [public + secret]

## Also generate the relinearization key homomorphic multiplication
## needs and the rotation keys for shifts by one slot either way.
## These are stored inside the context, not in the returned pair.
kp <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, -1L))
kp@public
#> <PublicKey> [active]
kp@secret
#> <PrivateKey> [active]
```
