# BinFHE: Boolean Circuits and Arbitrary Functions on Encrypted Bits

The other vignettes in this package focus on **CKKS** — approximate
real-number arithmetic with batched slots, suitable for distributed
statistics, regression, and the bulk of the headline “R optimizers run
unchanged over an encrypted channel” workflows. CKKS is where most of
the audience-A use cases live.

But CKKS has blind spots. It is not well suited to:

- **Comparisons and branching** — “is `x > 0`?” doesn’t translate
  cleanly into a polynomial approximation unless you’re willing to burn
  levels on a Chebyshev sign approximation.
- **Arbitrary non-polynomial functions** on bounded integer domains — a
  piecewise step function, a bit-extraction, a custom lookup.
- **Exact per-bit logic** — parity, comparators, small
  arbitrary-function evaluation.

OpenFHE’s **BinFHE** subsystem is the tool for those jobs. BinFHE
implements the FHEW/TFHE family: single-bit ciphertexts with *every gate
evaluation* performing an in-place bootstrap. That means there’s no
depth budget to manage — a BinFHE circuit can be arbitrarily deep — but
each gate is comparatively expensive because the bootstrap is on the
critical path. It’s the right shape for short circuits with logical or
arbitrary-function operations, not for long chains of multiplications.

This vignette walks through the BinFHE operations end-to-end. Every
section runs real code and checks real output. The examples use the
**TOY** paramset for speed — in production you’d use **STD128** (or
STD128_3 / STD128_4 for multi-input gates).

## Context and key setup

A BinFHE context is built with a parameter set and a bootstrap method.
`BinFHEParamSet` carries 44 values covering the full C++ header range —
**TOY** for tests, **STD128** / **STD128Q** for 128-bit classical /
quantum security, **STD192** / **STD256** for higher security, and the
**LMKCDEY** family for the newer bootstrap algorithm. `BinFHEMethod`
chooses between **GINX** (default), **AP** (Ducas-Micciancio), and
**LMKCDEY** (the fastest variant in the current OpenFHE release).

``` r

library(openfhe.R)

## TOY paramset — fast but zero security. For demos only.
ctx <- bin_fhe_context(BinFHEParamSet$TOY, BinFHEMethod$GINX)

## The secret key generates bootstrap keys that every gate
## will use internally.
sk <- bin_key_gen(ctx)
bin_bt_key_gen(ctx, sk)
```

[`bin_bt_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_bt_key_gen.md)
accepts an optional `keygen_mode` argument (`KeygenMode$SYM_ENCRYPT`
default, or `KeygenMode$PUB_ENCRYPT`) that controls how the bootstrap
keys are generated. Most users leave it at the default.

## Two-input boolean gates

The standard 2-input gates are `AND`, `OR`, `NAND`, `NOR`, `XOR`,
`XNOR`, and the fast variants `XOR_FAST` / `XNOR_FAST`. All of them go
through the same `eval_bin_gate(ctx, gate, ct1, ct2)` entry point.

``` r

ct0 <- bin_encrypt(ctx, sk, 0L)
ct1 <- bin_encrypt(ctx, sk, 1L)

truth <- function(gate_name, gate, ct_a, ct_b) {
  r <- eval_bin_gate(ctx, gate, ct_a, ct_b)
  bin_decrypt(ctx, sk, r)
}

## Full truth table for AND / OR / XOR.
grid <- expand.grid(a = c(0L, 1L), b = c(0L, 1L))
grid$AND <- mapply(function(a, b) truth("AND", BinGate$AND,
                                         bin_encrypt(ctx, sk, a),
                                         bin_encrypt(ctx, sk, b)),
                    grid$a, grid$b)
grid$OR  <- mapply(function(a, b) truth("OR", BinGate$OR,
                                         bin_encrypt(ctx, sk, a),
                                         bin_encrypt(ctx, sk, b)),
                    grid$a, grid$b)
grid$XOR <- mapply(function(a, b) truth("XOR", BinGate$XOR,
                                         bin_encrypt(ctx, sk, a),
                                         bin_encrypt(ctx, sk, b)),
                    grid$a, grid$b)
grid
#>   a b AND OR XOR
#> 1 0 0   0  0   0
#> 2 1 0   0  1   1
#> 3 0 1   0  1   1
#> 4 1 1   1  1   0
```

Every row of the truth table matches the standard boolean definitions.
Nothing exotic is happening here — the interesting part is that the
inputs are encrypted, the gate evaluation does a bootstrap internally,
and the output is decryptable with the same secret key.

## Negation

The only 1-input gate is `eval_not(ctx, ct)`:

``` r

bin_decrypt(ctx, sk, eval_not(ctx, ct0))
#> [1] 1
bin_decrypt(ctx, sk, eval_not(ctx, ct1))
#> [1] 0
```

## Multi-input gates

OpenFHE exposes wider boolean gates (3-input and 4-input) that are more
efficient than composing 2-input gates. The supported wide gates are
**AND3**, **OR3**, **AND4**, **OR4**, **MAJORITY** (3-input majority
vote), and **CMUX** (3-input conditional mux). All of them go through
the same
[`eval_bin_gate()`](https://openfheorg.github.io/openfhe.R/reference/eval_bin_gate.md)
entry point, but instead of passing two `Ciphertext` arguments you pass
a **list** of ciphertexts.

Multi-input gates have two setup constraints the 2-input gates don’t
share:

1.  **Parameter set**: you need a paramset designed for the input width.
    **STD128_3** for 3-input gates, **STD128_4** for 4-input. TOY with
    the default plaintext modulus produces garbled decryption because
    the TOY parameters are tuned for 2-input only.
2.  **Plaintext modulus**: the encryption call must use
    `p = 2 * num_inputs`. For 3-input gates that’s `p = 6`; for 4-input,
    `p = 8`. The `SMALL_DIM` output mode is also required.

Here’s a 3-input **AND3** example using the right setup:

``` r

ctx3 <- bin_fhe_context(BinFHEParamSet$STD128_3)
sk3 <- bin_key_gen(ctx3)
bin_bt_key_gen(ctx3, sk3)

p3 <- 6L
encrypt_bit_3 <- function(b) {
  bin_encrypt(ctx3, sk3, as.integer(b),
              output = BinFHEOutput$SMALL_DIM,
              p = p3)
}
```

``` r

## 1 AND 1 AND 0 = 0
cts_110 <- list(encrypt_bit_3(1L),
                encrypt_bit_3(1L),
                encrypt_bit_3(0L))
bin_decrypt(ctx3, sk3,
            eval_bin_gate(ctx3, BinGate$AND3, cts_110),
            p = p3)
#> [1] 0

## 1 AND 1 AND 1 = 1
cts_111 <- list(encrypt_bit_3(1L),
                encrypt_bit_3(1L),
                encrypt_bit_3(1L))
bin_decrypt(ctx3, sk3,
            eval_bin_gate(ctx3, BinGate$AND3, cts_111),
            p = p3)
#> [1] 1
```

Same entry point, different shape: the third argument is a list instead
of a single ciphertext, and the second argument (`ct2`) is left unset
(defaults to `NULL`). The dispatcher detects the list shape and routes
to the vector-form C++ overload.

Majority on three bits:

``` r

## Majority uses p = 4 (not 2 * num_inputs = 6) per the
## upstream boolean-multi-input example's encoding.
p_maj <- 4L
encrypt_bit_maj <- function(b) {
  bin_encrypt(ctx3, sk3, as.integer(b),
              output = BinFHEOutput$SMALL_DIM,
              p = p_maj)
}

cts <- list(encrypt_bit_maj(1L),
            encrypt_bit_maj(1L),
            encrypt_bit_maj(0L))
bin_decrypt(ctx3, sk3,
            eval_bin_gate(ctx3, BinGate$MAJORITY, cts),
            p = p_maj)
## 1 (majority of two 1s and one 0)
```

## Arbitrary function evaluation

For functions that don’t fit into the fixed gate repertoire, BinFHE
supports **arbitrary function evaluation** via a lookup table. The
workflow is:

1.  Define a function from integers in `[0, p)` to integers in `[0, p)`
    in plain R.
2.  Build a `BinFHEContext` with `arb_func = TRUE`, which selects a
    paramset and ring dimension large enough for the functional
    bootstrap.
3.  Generate a lookup table via
    [`generate_lut_via_function()`](https://openfheorg.github.io/openfhe.R/reference/generate_lut_via_function.md).
4.  Call `eval_func(ctx, ct, lut)` on an encrypted input — the output is
    a ciphertext of `f(input)`.

``` r

## Build an arb-func context. arb_func = TRUE picks a wider
## paramset; log_q and n control the LARGE_DIM modulus and
## dimension of the functional-bootstrap path.
ctx_f <- bin_fhe_context(BinFHEParamSet$TOY,
                          arb_func = TRUE)
sk_f <- bin_key_gen(ctx_f)
bin_bt_key_gen(ctx_f, sk_f)

p <- get_max_plaintext_space(ctx_f)

## Example function: squared value mod p. The LUT maps
## input i in [0, p) to f(i) = i^2 mod p.
f_square <- function(x, plaintext_modulus) {
  (x * x) %% plaintext_modulus
}
lut <- generate_lut_via_function(f_square, p)

## Encrypt a value in the LARGE_DIM / functional-bootstrap
## path and evaluate.
ct_input <- bin_encrypt(ctx_f, sk_f, 3L,
                        output = BinFHEOutput$LARGE_DIM,
                        p = p)
ct_out <- eval_func(ctx_f, ct_input, lut)
bin_decrypt(ctx_f, sk_f, ct_out, p = p)
#> [1] 1
## 9 (if p > 9, otherwise 9 mod p)
```

The LUT evaluation runs one functional bootstrap per
[`eval_func()`](https://openfheorg.github.io/openfhe.R/reference/eval_func.md)
call — so it’s not cheap — but it gives you arbitrary univariate
functions over the plaintext domain without any polynomial
approximation.

## The sign function

`eval_sign(ctx, ct)` evaluates the sign of an encrypted value: it
returns 1 if the input is in the “positive” half of the encoding range
and 0 if it’s in the “negative” half. The primary use case is threshold
comparisons (convert `x > threshold` into
`eval_sign(ct - threshold_ct)`).

Unlike the other functional-bootstrap primitives in this vignette,
[`eval_sign()`](https://openfheorg.github.io/openfhe.R/reference/eval_sign.md)
requires a **large-Q** context: the paramset must be **STD128** (not
TOY), the `arb_func` flag must be `FALSE`, and an explicit `log_q` must
be supplied. The encryption path uses the `LARGE_DIM` output mode with
both an explicit plaintext modulus `p` and an explicit ciphertext
modulus `mod = Q`.

This setup mirrors the upstream `eval-sign.py` example.

``` r

log_q <- 17L
ctx_s <- bin_fhe_context(
  paramset           = BinFHEParamSet$STD128,
  method             = BinFHEMethod$GINX,
  arb_func           = FALSE,
  log_q              = log_q,
  n                  = 0L,
  time_optimization  = FALSE
)
sk_s <- bin_key_gen(ctx_s)
bin_bt_key_gen(ctx_s, sk_s)

Q <- bitwShiftL(1L, log_q)                           # 131072
q <- 4096
factor <- bitwShiftL(1L, log_q - as.integer(log2(q))) # 32
p_s <- get_max_plaintext_space(ctx_s) * factor
```

Now encrypt eight values centered on `p_s / 2` and test each one’s sign:

``` r

center <- p_s %/% 2
for (i in 0:7) {
  msg <- center + i - 3
  ct  <- bin_encrypt(ctx_s, sk_s, msg,
                     output = BinFHEOutput$LARGE_DIM,
                     p = p_s, mod = Q)
  ct_sign <- eval_sign(ctx_s, ct)
  ## Decrypt with p = 2 (sign bit is a single bit).
  result <- bin_decrypt(ctx_s, sk_s, ct_sign, p = 2L)
  cat(sprintf("msg = center%+d => sign bit %d\n", i - 3, result))
}
#> msg = center-3 => sign bit 0
#> msg = center-2 => sign bit 0
#> msg = center-1 => sign bit 0
#> msg = center+0 => sign bit 1
#> msg = center+1 => sign bit 1
#> msg = center+2 => sign bit 1
#> msg = center+3 => sign bit 1
#> msg = center+4 => sign bit 1
```

The sign flips exactly at `i = 3` (msg = center) — inputs in the lower
half of `[0, p_s)` return 0, inputs in the upper half return 1.

The optional `scheme_switch` argument to
[`eval_sign()`](https://openfheorg.github.io/openfhe.R/reference/eval_sign.md)
controls whether the output encoding is compatible with the
CKKS\<-\>FHEW scheme-switching pipeline. Most users can ignore it
(default `FALSE`).

## Floor: bit-level rounding

`eval_floor(ctx, ct, roundbits)` performs the LWE equivalent of
`floor(ct / 2^roundbits)` via functional bootstrapping. Used as a
primitive in bit-extraction or quantization pipelines. Like `eval_func`,
`eval_floor` works with an `arb_func = TRUE` context and the `LARGE_DIM`
encryption mode — so the previous `ctx_f` from the LUT section is ready
to use.

``` r

ct_five <- bin_encrypt(ctx_f, sk_f, 5L,
                       output = BinFHEOutput$LARGE_DIM,
                       p = p)
ct_floor <- eval_floor(ctx_f, ct_five, roundbits = 2L)
class(ct_floor)
#> [1] "openfhe.R::LWECiphertext" "openfhe.R::OpenFHEObject"
#> [3] "S7_object"
## Returns an LWECiphertext holding floor(5 / 2^2) = 1 in
## the rounded encoding.
```

## When to use BinFHE vs CKKS

The two schemes solve different problems.

| Property | CKKS | BinFHE |
|----|----|----|
| Data type | real numbers (approximate) | single bits |
| Batching | yes (thousands of slots per ciphertext) | no (one bit per ciphertext) |
| Per-op cost | cheap multiply / add, expensive bootstrap | every gate is a bootstrap internally |
| Depth budget | yes — bootstrap refreshes, see [ckks-bootstrapping](https://openfheorg.github.io/openfhe.R/articles/ckks-bootstrapping.md) | no — gates self-refresh |
| Good at | polynomial arithmetic, statistics, batched linear algebra | comparisons, branching, per-bit logic, arbitrary univariate functions |
| Audience-A fit in this package | **primary** — cox / cvxr / mle / encrypted-regression etc. | **secondary** — comparators, thresholding, custom LUT evaluation |

In practice the two schemes are complementary. A hybrid workflow — use
CKKS for the heavy lifting, then scheme-switch to BinFHE for a
comparison or a LUT evaluation — exists in the OpenFHE C++ library (via
`eval_sign(scheme_switch = TRUE)` and the `EvalSchemeSwitching*`
family). The scheme-switching pipeline itself is not yet exposed in
`openfhe.R`’s R interface but a future version could if a concrete use
case demands it.

## Further reading

Besides the package help, more details can be found in the [OpenFHE
BinFHE documentation](https://openfhe-development.readthedocs.io/).
