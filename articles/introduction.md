# Introduction to openfhe.R: Fully Homomorphic Encryption in R

A statistician fitting a Cox model on hospital records, or a data
scientist pooling case counts across institutions, often hits the same
wall: the data cannot leave the institution that collected it. Privacy
regulations, consent agreements, and plain institutional caution all
conspire to keep the rows where they are. The usual workaround — summary
statistics shipped between sites — works for some questions and falls
short for others, especially anything that needs a joint likelihood, an
iterative optimizer, or a model owner who is not allowed to see the raw
features.

Fully Homomorphic Encryption (FHE) gives us another option. A data
holder encrypts the data once, ships the encrypted copy to whoever is
doing the computation, and that party can add, multiply, and otherwise
manipulate the encrypted values without ever seeing the underlying
numbers. Only the key holder can decrypt the final answer. The
`openfhe.R` package wraps the
[OpenFHE](https://github.com/openfheorg/openfhe-development) C++ library
so that R users can do this from the same environment they already use
for analysis.

## A few terms from the cryptography side

The package’s function names mirror the underlying C++ API, which means
a handful of crypto-world words show up in arguments and return values.
None of them require a cryptography background to use; this is the
dictionary you need to read the rest of this vignette.

- **Plaintext.** The *encoded* form of the numeric input — not raw R
  values but a packed object the encryption step knows how to read. You
  build one from a numeric vector with
  [`make_packed_plaintext()`](https://bnaras.github.io/openfhe.R/reference/make_packed_plaintext.md)
  (for the integer schemes) or
  [`make_ckks_packed_plaintext()`](https://bnaras.github.io/openfhe.R/reference/make_ckks_packed_plaintext.md)
  (for real-valued data). Think of it as the moral equivalent of
  [`as.numeric()`](https://rdrr.io/r/base/numeric.html) for the
  encryption pipeline.
- **Ciphertext.** What you get after encrypting a plaintext. All the
  encrypted-arithmetic functions operate on ciphertexts and return
  ciphertexts; the only way back to numbers is
  [`decrypt()`](https://bnaras.github.io/openfhe.R/reference/decrypt.md)
  plus an unpacker like
  [`get_packed_value()`](https://bnaras.github.io/openfhe.R/reference/get_packed_value.md)
  or
  [`get_real_packed_value()`](https://bnaras.github.io/openfhe.R/reference/get_real_packed_value.md).
- **CryptoContext.** A parameter bundle returned by
  [`fhe_context()`](https://bnaras.github.io/openfhe.R/reference/fhe_context.md).
  It pins down the scheme, the precision budget, and the layout of the
  slots. Almost every other call takes a context as the `cc =` argument.
- **Public and secret key.** Standard public-key roles.
  [`key_gen()`](https://bnaras.github.io/openfhe.R/reference/key_gen.md)
  returns a `KeyPair` with `@public` and `@secret` slots. Encryption
  uses the public key, decryption uses the secret key.
- **Evaluation keys.** Auxiliary keys that *authorize* specific
  encrypted-side operations — multiplication of two ciphertexts,
  summation across slots, rotation. They are generated alongside the
  secret key when you ask for them (`eval_mult = TRUE` to
  [`key_gen()`](https://bnaras.github.io/openfhe.R/reference/key_gen.md),
  for example) and travel with the public key when you ship encrypted
  data.
- **Slots.** Internally an encrypted vector has many more positions than
  the data you put in — typically thousands. You use the first few and
  call
  [`set_length()`](https://bnaras.github.io/openfhe.R/reference/set_length.md)
  on the decrypted result to trim back.

That is the whole vocabulary and the rest of this vignette describes the
package facilities using only those terms.

## Five Short Demonstrations

The rest of this introduction walks five short demonstrations, in the
order most R users will meet them:

1.  **Encrypted integer arithmetic.** The simplest case — adding and
    multiplying integer vectors that the computing party never sees.
    Useful for counts, ranks, and exact tallies.
2.  **Encrypted real arithmetic.** Most statistical work lives here:
    regression coefficients, likelihoods, gradients, sample variances.
    The CKKS scheme handles real numbers with controlled approximation
    error.
3.  **Boolean operations on encrypted bits.** When the computation needs
    comparisons, branching, or per-bit logic, a different scheme
    (BinFHE) takes over.
4.  **Serialization.** Distributed protocols need to send encrypted
    values and keys across processes or across the network. Every object
    in `openfhe.R` can be written to a file and read back.
5.  **Threshold (multi-party) decryption.** No single party needs to
    hold the full secret key. Two or more parties can each hold a share
    and jointly decrypt the result — the foundation for federated
    computation across institutions.

Each step builds on the previous one. By the end you will have seen the
full set of building blocks that the rest of the package’s vignettes —
and the companion `homomorpheR` application package (version \>= 1.0) —
assemble into worked examples.

## Encrypted integer arithmetic

The BFV scheme handles exact integer arithmetic modulo a plaintext
modulus. There is no rounding error: an addition of two encrypted
vectors decrypts to exactly the same vector the cleartext addition would
have produced.

A `CryptoContext` holds the scheme parameters; from it we generate a
public/secret key pair (and the evaluation keys that authorize
multiplication of encrypted values).

``` r

library(openfhe.R)

cc <- fhe_context("BFV",
  plaintext_modulus    = 65537,
  multiplicative_depth = 2
)
keys <- key_gen(cc, eval_mult = TRUE)
```

With keys in hand, encrypt two integer vectors. In `openfhe.R`,
encryption takes a *plaintext* object — a packed, scheme-aware
representation of the input — rather than a raw R vector, so the
workflow is “pack, then encrypt”.

``` r

x <- c(1, 2, 3, 4, 5, 6, 7, 8)
y <- c(10, 20, 30, 40, 50, 60, 70, 80)

ct_x <- encrypt(keys@public, make_packed_plaintext(cc, x), cc = cc)
ct_y <- encrypt(keys@public, make_packed_plaintext(cc, y), cc = cc)
```

`ct_x` and `ct_y` are the encrypted versions of `x` and `y`. A computing
party with no access to `keys@secret` can still add and multiply them.

``` r

ct_sum  <- ct_x + ct_y
ct_prod <- ct_x * ct_y
```

Decryption requires the secret key. The
[`set_length()`](https://bnaras.github.io/openfhe.R/reference/set_length.md)
call trims the result to the original input length, since the underlying
packed representation has many more slots than we used.

``` r

result_sum  <- decrypt(ct_sum,  keys@secret, cc = cc)
result_prod <- decrypt(ct_prod, keys@secret, cc = cc)
set_length(result_sum,  8)
set_length(result_prod, 8)

sum_vec  <- get_packed_value(result_sum)
prod_vec <- get_packed_value(result_prod)
sum_vec
#> [1] 11 22 33 44 55 66 77 88
prod_vec
#> [1]  10  40  90 160 250 360 490 640
```

The decrypted sum is exactly `x + y` and the decrypted product is
exactly `x * y` — element by element, no approximation. The first
entries are 11 and 10, matching `1 + 10` and `1 * 10`. BFV is the right
tool whenever the analytic quantity is an integer count, an exact
aggregate, or anything that should be reproduced bit-for-bit.

## Encrypted real arithmetic

Most statistical work involves real numbers. The CKKS scheme encrypts
vectors of doubles and supports addition, multiplication, and scalar
operations with bounded approximation error. The error is controlled by
a `scaling_mod_size` parameter at context construction; for the values
below it sits well under one part in a million.

``` r

cc <- fhe_context("CKKS",
  multiplicative_depth = 1,
  scaling_mod_size     = 50,
  batch_size           = 8
)
keys <- key_gen(cc, eval_mult = TRUE)
```

Encrypt a real-valued vector and run a few operations on it.

``` r

x  <- c(0.25, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0)
ct <- encrypt(keys@public, make_ckks_packed_plaintext(cc, x), cc = cc)

ct_doubled <- ct + ct
ct_squared <- ct * ct
ct_scaled  <- ct * 4.0
```

Decryption returns a packed plaintext;
[`get_real_packed_value()`](https://bnaras.github.io/openfhe.R/reference/get_real_packed_value.md)
extracts the underlying doubles.

``` r

result <- decrypt(ct_doubled, keys@secret, cc = cc)
set_length(result, 8)
doubled_vec <- get_real_packed_value(result)
doubled_vec
#> [1]  0.5  1.0  1.5  2.0  4.0  6.0  8.0 10.0
```

The decrypted “double” of `x` matches `2 * x` to within the CKKS
tolerance. The maximum elementwise error is

``` r

max_err <- max(abs(doubled_vec - 2 * x))
max_err
#> [1] 8.792966e-14
```

8.79^{-14} — small enough to be invisible at the precisions reported in
most statistical work. CKKS is the scheme to reach for when the
encrypted computation is a likelihood, a gradient step, a regression
coefficient, or anything else where a real-valued answer with bounded
error is acceptable.

## Boolean operations on encrypted bits

Some computations need comparisons or branching — “is this encrypted
value greater than zero?” — which do not translate cleanly into
polynomial operations on real numbers. For those tasks OpenFHE provides
a separate scheme (BinFHE) that operates on encrypted single **bits**,
each a 0 or 1.

The unit of computation here is the **logic gate**: a basic Boolean
operation — `AND`, `OR`, `NOT`, and a few relatives — that takes one or
two bits in and returns one bit. Wiring gates together, the output of
one feeding the input of the next, builds a **Boolean circuit** that
computes a larger function; a comparator that tests whether one
encrypted number exceeds another, or an adder, is just a fixed
arrangement of gates. BinFHE evaluates one gate at a time on encrypted
bits, and every gate evaluation runs an internal refresh, so a circuit
can be made arbitrarily deep — at the cost of each gate being
comparatively expensive.

``` r

ctx <- bin_fhe_context(BinFHEParamSet$STD128, BinFHEMethod$GINX)
sk  <- bin_key_gen(ctx)
bin_bt_key_gen(ctx, sk)
```

Encrypt two bits and evaluate `AND` and `OR` on them.

``` r

ct_a <- bin_encrypt(ctx, sk, 1L)
ct_b <- bin_encrypt(ctx, sk, 0L)

ct_and <- eval_bin_gate(ctx, BinGate$AND, ct_a, ct_b)
ct_or  <- eval_bin_gate(ctx, BinGate$OR,
                        bin_encrypt(ctx, sk, 1L),
                        bin_encrypt(ctx, sk, 0L))

and_bit <- bin_decrypt(ctx, sk, ct_and)
or_bit  <- bin_decrypt(ctx, sk, ct_or)
and_bit
#> [1] 0
or_bit
#> [1] 1
```

`AND(1, 0)` decrypts to 0 and `OR(1, 0)` decrypts to 1, as expected. The
`binfhe-boolean-circuits` vignette explores this scheme in much more
detail — including comparators, arbitrary-function evaluation, and
multi-input gates.

## Serialization

Federated and threshold protocols need to move encrypted values and keys
between processes, machines, or institutions. Every object the package
produces — contexts, keys, ciphertexts, evaluation keys — has a binary
serialization format. The example below writes a few objects to a
temporary directory and reads them back; in a real protocol the same
calls would write to network sockets or storage buckets.

``` r

tdir <- tempdir()

fhe_serialize(cc, file.path(tdir, "context.bin"))
fhe_serialize(keys@public, file.path(tdir, "pubkey.bin"))
fhe_serialize(ct, file.path(tdir, "ciphertext.bin"))
serialize_eval_keys(file.path(tdir, "mult_keys.bin"), "mult")

cc2 <- fhe_deserialize(file.path(tdir, "context.bin"),    "CryptoContext")
ct2 <- fhe_deserialize(file.path(tdir, "ciphertext.bin"), "Ciphertext")
```

`cc2` and `ct2` are independent objects that behave exactly like the
originals — a different R session, possibly on a different machine, can
decrypt or further process the encrypted data once it has the
appropriate keys.

## Threshold decryption

The previous examples gave one party the full secret key. In a federated
setting, no single party should hold enough key material to decrypt on
their own. OpenFHE supports **threshold decryption**: two or more
parties each generate a key share, encryption uses the joint public key,
and decryption is a small protocol where each party contributes a
partial result.

The flow below sketches the two-party version. Party A generates initial
keys, Party B daisy-chains its own keys off A’s public key, and
encryption is done under B’s public key (which carries both
contributions).

``` r

cc_mp <- fhe_context("BFV",
  plaintext_modulus    = 65537,
  multiplicative_depth = 2,
  features             = c(Feature$MULTIPARTY)
)

kp_a <- key_gen(cc_mp)
kp_b <- multiparty_key_gen(cc_mp, kp_a@public)

ct_mp <- encrypt(kp_b@public,
                 make_packed_plaintext(cc_mp, 1:8),
                 cc = cc_mp)
```

Decryption proceeds in three steps: a *lead* partial decryption from the
first party, a *main* partial decryption from the second party, and a
fusion step that combines the partials into the final plaintext.

``` r

partial_a <- multiparty_decrypt_lead(cc_mp, kp_a@secret, ct_mp)
partial_b <- multiparty_decrypt_main(cc_mp, kp_b@secret, ct_mp)
result_mp <- multiparty_decrypt_fusion(cc_mp, partial_a, partial_b)
set_length(result_mp, 8)
mp_vec <- get_packed_value(result_mp)
mp_vec
#> [1] 1 2 3 4 5 6 7 8
```

The decrypted vector matches `1:8` — neither party alone could have
produced it, but together they recovered the plaintext. This is the
foundation that the worked applications build on. Cox regression across
hospitals, consensus ADMM for distributed convex optimization, secure
inference, and privacy-preserving aggregation all reduce to “encrypt
under a joint key, run the optimizer over the encrypted channel,
threshold-decrypt the final answer”.

## Further Exploration

Two further vignettes in `openfhe.R` itself dig into the schemes in
depth:

- [`ckks-bootstrapping`](https://bnaras.github.io/openfhe.R/articles/ckks-bootstrapping.md)
  — what to do when a long CKKS computation runs out of multiplicative
  depth, including the multi-party variant that composes with the
  threshold flow above.
- [`binfhe-boolean-circuits`](https://bnaras.github.io/openfhe.R/articles/binfhe-boolean-circuits.md)
  — comparators, arbitrary-function evaluation, and the full set of
  BinFHE operations.

For worked statistical applications — Cox regression, MLE, CVXR-based
consensus ADMM, encrypted regression, secure inference, and
privacy-preserving aggregation, plus differentially private variants —
see the companion application package
[`homomorpheR`](https://cran.r-project.org/package=homomorpheR) (version
\>= 1.0). The two packages are siblings: `openfhe.R` provides the
encryption primitives, `homomorpheR` hosts the statistical demos that
run on top of them, ordered from simple aggregation through to advanced
threshold and differential privacy workflows.
