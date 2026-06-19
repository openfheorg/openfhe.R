# CKKS Bootstrapping: Refreshing Deep Circuits

CKKS has a budget. Every multiplication consumes a level in the
ciphertext’s modulus chain, and when the chain is exhausted the
ciphertext stops being decryptable. For a linear sequence of
multiplications the budget is exactly the multiplicative depth you
configured at context construction; once it’s spent, you either finish
the computation or you find a way to refresh the ciphertext.

**Bootstrapping is the refresh operation.** It produces a new ciphertext
that encrypts the same plaintext but at a fresh modulus level. From the
outside it’s an identity function; internally it runs a small circuit of
its own (typically consuming 10–15 levels) that leaves the ciphertext at
a higher level than it started.

OpenFHE exposes three flavors of bootstrap. This vignette walks all
three, with runnable examples, and maps each to the R interface that
`openfhe.R` ships:

1.  **Non-interactive bootstrap** — the classical form. The server holds
    bootstrap keys and can refresh any ciphertext on its own.
2.  **Iterative non-interactive bootstrap** — the same thing in a loop,
    for circuits deep enough that one refresh isn’t enough.
3.  **Interactive multi-party bootstrap** — the 9117 addition. Each
    party contributes to the refresh, no single party holds enough key
    material to bootstrap alone. This is the variant that composes with
    the threshold-FHE workflow the cox-threshold and cvxr-consensus-admm
    vignettes build on.

Key point: **the bootstrap is invisible to the R user’s statistical
code.** You still call the same `eval_mult` / `eval_add` / `decrypt`
functions; the bootstrap adds one call and the R script reads through as
if nothing happened.

## The depth budget problem

To see why bootstrapping matters, start with a depth-limited context and
run out of budget.

``` r

library(openfhe.R)

cc_shallow <- fhe_context("CKKS",
  multiplicative_depth = 3L,
  scaling_mod_size     = 50L,
  batch_size           = 8L
)
kp_shallow <- key_gen(cc_shallow, eval_mult = TRUE)

x <- c(0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
pt <- make_ckks_packed_plaintext(cc_shallow, x)
ct <- encrypt(kp_shallow@public, pt, cc = cc_shallow)

## Three multiplications in sequence — right at the depth
## budget. This succeeds.
ct_a <- ct * ct           # level 1
ct_b <- ct_a * ct         # level 2
ct_c <- ct_b * ct         # level 3
res <- decrypt(ct_c, kp_shallow@secret, cc = cc_shallow)
set_length(res, 8L)
round(get_real_packed_value(res)[1:3], 5)
#> [1] 0.0625 0.0625 0.0625
## ~ c(0.5^4, 0.5^4, 0.5^4) = c(0.0625, 0.0625, 0.0625)
```

One more multiplication on `ct_c` would fail: the modulus chain is empty
and the next multiply has nothing to rescale into. That’s the depth
wall. The rest of the vignette shows how to climb past it.

## Non-interactive bootstrap

The classical CKKS bootstrap is a server-side operation. The server
holds a set of *bootstrap keys* (generated from the secret key at setup
time) and can call `eval_bootstrap` on any ciphertext to refresh it. No
client interaction needed once the keys are in place.

### Setup

Bootstrap has significant level overhead — the bootstrap circuit itself
consumes modulus-chain levels, so the context’s `multiplicative_depth`
must be at least the bootstrap budget plus whatever user compute the
refreshed ciphertext needs to support.

[`get_bootstrap_depth()`](https://bnaras.github.io/openfhe.R/reference/get_bootstrap_depth.md)
computes the per-bootstrap level cost from the `level_budget` and the
secret-key distribution.

``` r

## Choose the bootstrap level budget. The two integers are
## the encoding and decoding budgets; (3, 3) is a reasonable
## middle ground. Larger values give faster bootstrap at the
## cost of deeper required chain.
level_budget   <- c(3L, 3L)
secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY

boot_depth <- get_bootstrap_depth(level_budget, secret_key_dist)
boot_depth
#> [1] 20

## User compute budget after a single bootstrap — how many
## multiplications we want to do between refreshes.
user_depth <- 2L

total_depth <- boot_depth + user_depth
total_depth
#> [1] 22
```

With the budget computed, build a CKKS context that has enough depth to
cover both the bootstrap circuit and the post-bootstrap user compute.

``` r

cc <- fhe_context("CKKS",
  multiplicative_depth = total_depth,
  scaling_mod_size     = 59L,
  first_mod_size       = 60L,
  ring_dim             = 4096L,
  security_level       = SecurityLevel$HEStd_NotSet,
  scaling_technique    = ScalingTechnique$FLEXIBLEAUTO,
  features             = c(Feature$ADVANCEDSHE, Feature$FHE)
)
kp <- key_gen(cc, eval_mult = TRUE)
```

`Feature$FHE` is the feature flag that turns on the bootstrap;
`Feature$ADVANCEDSHE` is required alongside it because the Chebyshev
approximations used inside the bootstrap circuit live in that feature.

### Bootstrap key generation

Once the context exists, generate the bootstrap keys (rotation keys that
the bootstrap circuit uses internally) and pre-compute the encoding /
decoding plaintexts.

``` r

## ring_dim / 2 is the number of CKKS slots. Query it off
## the context rather than hard-coding.
ring_dim  <- ring_dimension(cc)
num_slots <- as.integer(ring_dim / 2)

eval_bootstrap_setup(cc, level_budget = level_budget)
eval_bootstrap_key_gen(cc, kp@secret, num_slots)
```

The setup call accepts the optional `bt_slots_encoding` argument for a
small efficiency improvement in specific slot configurations — it
defaults to `FALSE` matching the upstream default.

### Run a refresh

Encrypt a small vector, burn through most of the user compute budget,
then bootstrap and verify the refreshed ciphertext still decrypts to the
expected plaintext.

``` r

y <- c(0.25, 0.5, 0.75, 1.0)
pt_y <- make_ckks_packed_plaintext(cc, y)
ct_y <- encrypt(kp@public, pt_y, cc = cc)

## Burn a couple of levels to simulate "the user circuit has
## run and now we need to refresh".
ct_y <- ct_y * ct_y     # y^2
## At this point ct_y sits at a lower level than it started.

## One bootstrap call refreshes the ciphertext. Default
## num_iterations = 1L is the standard case.
ct_refreshed <- eval_bootstrap(ct_y)

## Decrypt the refreshed ciphertext and confirm it holds
## the same value as y^2 did.
res_refresh <- decrypt(ct_refreshed, kp@secret, cc = cc)
set_length(res_refresh, 4L)
round(get_real_packed_value(res_refresh)[1:4], 4)
#> [1] 0.0625 0.2500 0.5625 1.0000
## ~ c(0.0625, 0.25, 0.5625, 1.0) = y^2
```

Post-refresh, the ciphertext has enough headroom to continue computing —
`ct_refreshed * ct` works where a second `ct_y * ct_y` on the
pre-bootstrap form would have been exhausted.

## Iterative bootstrap

For circuits deep enough that one refresh isn’t enough,
[`eval_bootstrap()`](https://bnaras.github.io/openfhe.R/reference/eval_bootstrap.md)
accepts a `num_iterations` argument that runs multiple refreshes in
sequence with increasing precision. This is the iterative form — a
quality/performance trade-off that lets the caller spend more cycles for
tighter noise bounds.

``` r

## Same cc, same keys — just more iterations per call.
ct_refreshed_2 <- eval_bootstrap(ct_y, num_iterations = 2L)
```

The cost scales roughly linearly in `num_iterations`; two iterations is
the typical value when a single refresh’s precision drop is the dominant
source of error in a long user circuit. Three or more iterations have
diminishing returns and are rarely needed.

The iterative form is hidden inside the same
[`eval_bootstrap()`](https://bnaras.github.io/openfhe.R/reference/eval_bootstrap.md)
entry point — there is no separate `eval_iterative_bootstrap()` generic.
The `num_iterations` argument is optional and defaults to `1L`, so
existing code that calls `eval_bootstrap(ct)` gets the classical non-
iterative form unchanged.

## Interactive multi-party bootstrap

The non-interactive forms require a party that holds the bootstrap keys
— and the bootstrap keys are generated from the secret key, so whoever
holds them effectively holds the decryption capability. In a
threshold-FHE setting where no single party is supposed to decrypt on
their own, the classical bootstrap isn’t viable: granting any party the
bootstrap keys would break the threshold security model.

The **interactive multi-party bootstrap** (`IntMPBoot*` family) solves
this. The refresh operation itself becomes a distributed protocol: each
party contributes a share, the shares are aggregated into a single
“shares pair”, and a final re-encryption step produces a refreshed
ciphertext at a fresh modulus level without any party ever holding
enough key material to decrypt alone.

This is the bootstrap variant that composes with the threshold-FHE flow
used in the `cox-threshold` and `cvxr-consensus-admm` vignettes.

### Setup

Build a CKKS context with `Feature$MULTIPARTY` alongside the `FHE` +
`ADVANCEDSHE` features, then generate the lead party’s key material and
daisy-chain a second party off it.

``` r

cc_mp <- fhe_context("CKKS",
  multiplicative_depth = 6L,
  scaling_mod_size     = 50L,
  first_mod_size       = 60L,
  ring_dim             = 4096L,
  security_level       = SecurityLevel$HEStd_NotSet,
  batch_size           = 8L,
  features             = c(Feature$ADVANCEDSHE, Feature$FHE,
                           Feature$MULTIPARTY)
)
kp1 <- key_gen(cc_mp, eval_mult = TRUE)
kp2 <- multiparty_key_gen(cc_mp, kp1@public)
```

### Refresh a ciphertext through the multi-party protocol

Encrypt a plaintext under party 2’s public key (the daisy-chained
“joint” public key in the two-party threshold protocol), adjust the
scale via
[`int_mp_boot_adjust_scale()`](https://bnaras.github.io/openfhe.R/reference/int_mp_boot_adjust_scale.md),
generate a common random element that all parties will use in their
partial decryptions, and then run each party’s partial decryption.

``` r

z <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
pt_z <- make_ckks_packed_plaintext(cc_mp, z)
ct_z <- encrypt(kp2@public, pt_z, cc = cc_mp)

## Step 1: scale adjustment. Prepares the ciphertext for
## the interactive refresh protocol.
ct_z_adjusted <- int_mp_boot_adjust_scale(ct_z)

## Step 2: generate the common random element. Can be
## derived from either the lead party's public key or from
## a reference ciphertext — the two overloads produce
## equivalent output.
a <- int_mp_boot_random_element_gen(cc_mp, kp1@public)

## Step 3: each party computes their masked-decryption
## shares pair. Each party's output is a list of two
## Ciphertexts.
shares1 <- int_mp_boot_decrypt(kp1@secret, ct_z_adjusted, a)
shares2 <- int_mp_boot_decrypt(kp2@secret, ct_z_adjusted, a)
```

### Aggregate and finalize

The shares pairs are aggregated into a single shares pair via
[`int_mp_boot_add()`](https://bnaras.github.io/openfhe.R/reference/int_mp_boot_add.md)
(parallel to how
[`multiparty_decrypt_fusion()`](https://bnaras.github.io/openfhe.R/reference/multiparty_decrypt_fusion.md)
aggregates lead + main partials in the ordinary threshold decrypt). The
aggregated shares pair, the common random element, and the original
ciphertext all go into
[`int_mp_boot_encrypt()`](https://bnaras.github.io/openfhe.R/reference/int_mp_boot_encrypt.md)
— the final step that produces the refreshed ciphertext at a fresh
modulus level.

``` r

## Aggregate both parties' shares pairs.
aggregated <- int_mp_boot_add(cc_mp, list(shares1, shares2))

## Final re-encryption step.
ct_refreshed_mp <- int_mp_boot_encrypt(kp1@public, aggregated,
                                       a, ct_z_adjusted)
```

The refreshed ciphertext composes with subsequent computation exactly
like the output of the non-interactive bootstrap would — the bootstrap
is still invisible to the user circuit layer, only the key-management
and setup details change.

## Comparison

The three variants have different properties. This table summarizes when
to reach for each.

| Variant | Feature flags | Who holds bootstrap capability | Typical use |
|----|----|----|----|
| Non-interactive | `ADVANCEDSHE`, `FHE` | Single server | Standard single-party CKKS with deep circuits |
| Iterative | `ADVANCEDSHE`, `FHE` | Single server | Same as above, when one refresh’s precision isn’t enough |
| Interactive multi-party | `ADVANCEDSHE`, `FHE`, `MULTIPARTY` | Distributed across parties | Threshold FHE where no single party can decrypt |

For the audience that this package primarily serves — precision-critical
distributed statistics with a threshold-FHE backbone — **the interactive
multi-party form is the right default** whenever a circuit needs more
depth than the initial context budget provides. The non-interactive form
is simpler but requires giving someone the bootstrap keys, which is
exactly what the threshold flow is trying to avoid. The iterative form
is an efficiency knob on the non-interactive path and is only relevant
when the classical single-server bootstrap is already viable.

## Further reading

Besides the package help, see:

- [OpenFHE docs](https://openfhe-development.readthedocs.io/)
- Vignettes in the companion
  [homomorpheR](https://cran.r-project.org/package=homomorpheR) package
  (version \>= 1.0).
