# Keys of the LWE scheme of a BinFHE context

`bin_key_gen_pair()` generates a public key and its secret key.
`bin_pub_key_gen()` generates a public key for an existing secret key.
`bin_key_gen_n()` generates a secret key of the large dimension `N`, and
`bin_key_switch_gen()` the key that switches ciphertexts under it
(modulus `Q`, dimension `N`) to ciphertexts under `sk` (modulus `q`,
dimension `n`).

## Usage

``` r
bin_key_gen_pair(ctx)

bin_pub_key_gen(ctx, sk)

bin_key_gen_n(ctx)

bin_key_switch_gen(ctx, sk, sk_n)
```

## Arguments

- ctx:

  A `BinFHEContext`.

- sk:

  An `LWEPrivateKey` of dimension `n`, from
  [`bin_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen.md).

- sk_n:

  An `LWEPrivateKey` of dimension `N`, from `bin_key_gen_n()`.

## Value

`bin_key_gen_pair()`: an
[LWEKeyPair](https://openfheorg.github.io/openfhe.R/reference/LWEKeyPair.md).
`bin_pub_key_gen()`: an
[LWEPublicKey](https://openfheorg.github.io/openfhe.R/reference/LWEPublicKey.md).
`bin_key_gen_n()`: an `LWEPrivateKey`. `bin_key_switch_gen()`: an
[LWESwitchingKey](https://openfheorg.github.io/openfhe.R/reference/LWESwitchingKey.md).

## See also

[`bin_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen.md),
[`bin_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/bin_encrypt.md),
[`switch_ct_to_qn()`](https://openfheorg.github.io/openfhe.R/reference/switch_ct_to_qn.md)

## Examples

``` r
ctx <- bin_fhe_context(BinFHEParamSet$TOY)
kp <- bin_key_gen_pair(ctx)
## Under the public key of the pair, in dimension N; no bootstrapping
## keys are needed for this form.
ct <- bin_encrypt(ctx, kp@public, 1L, BinFHEOutput$LARGE_DIM)
bin_decrypt(ctx, kp@secret, ct)
#> [1] 1
```
