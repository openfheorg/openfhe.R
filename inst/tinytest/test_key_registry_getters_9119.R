## @openfhe-python: src/lib/bindings.cpp (eval-key getter fleet) [PARTIAL]
##
## read-only diagnostic access to the
## cc-internal eval-key registry — the mirror of the
## write surface (insert_eval_*_key, clear_eval_*_keys). Four
## new getters:
##   get_all_eval_mult_keys()           — named list of lists
##   get_eval_mult_key_vector(tag)      — list of EvalKey
##   get_all_eval_automorphism_keys()   — named list of EvalKeyMap
##   get_all_eval_sum_keys()            — named list of EvalKeyMap
##
## Python binds get_eval_mult_key_vector (as a lambda) but not
## the three "all-" forms — flagged as R-extensions in
## `notes/upstream-defects.md`.
library(openfhe.R)

# ── Clean slate: clear any leftover registry from other tests ──

## The cc-internal registry is static and persists across
## tinytest files in a single process. Start fresh.
clear_eval_mult_keys()
clear_eval_automorphism_keys()

# ── Setup: BFV with eval-mult + rotation + sum keys ────

cc <- fhe_context("BFV",
  plaintext_modulus = 65537,
  multiplicative_depth = 2,
  batch_size = 16L,
  features = c(Feature$MULTIPARTY, Feature$ADVANCEDSHE)
)
kp <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, 2L, -1L))
eval_sum_key_gen(cc, kp@secret)
tag <- get_key_tag(kp@secret)

# ── get_all_eval_mult_keys: registry after key_gen(eval_mult=TRUE) ──

all_mult <- get_all_eval_mult_keys()
expect_true(is.list(all_mult))
expect_true(length(all_mult) >= 1L)
expect_true(tag %in% names(all_mult))
## Each value is itself a list of EvalKey objects (the
## underlying C++ `vector<EvalKey>` for that tag).
mult_for_tag <- all_mult[[tag]]
expect_true(is.list(mult_for_tag))
expect_true(length(mult_for_tag) >= 1L)
for (ek in mult_for_tag) expect_true(S7::S7_inherits(ek, EvalKey))

# ── get_eval_mult_key_vector: per-tag lookup ────────────

vec_for_tag <- get_eval_mult_key_vector(tag)
expect_true(is.list(vec_for_tag))
expect_equal(length(vec_for_tag), length(mult_for_tag))
for (ek in vec_for_tag) expect_true(S7::S7_inherits(ek, EvalKey))

# ── get_all_eval_automorphism_keys: rotation-key registry ──

all_rot <- get_all_eval_automorphism_keys()
expect_true(is.list(all_rot))
expect_true(length(all_rot) >= 1L)
expect_true(tag %in% names(all_rot))
## Each value is an EvalKeyMap (opaque wrapper).
rot_for_tag <- all_rot[[tag]]
expect_true(S7::S7_inherits(rot_for_tag, EvalKeyMap))
expect_true(openfhe.R:::ptr_is_valid(rot_for_tag))

# ── get_all_eval_sum_keys: sum-key registry ─────────────

## EvalSumKeys and EvalAutomorphismKeys share backing storage
## on the C++ side, so this returns a
## named list with the same tag present. Each value is still
## an EvalKeyMap.
all_sum <- get_all_eval_sum_keys()
expect_true(is.list(all_sum))
expect_true(length(all_sum) >= 1L)
expect_true(tag %in% names(all_sum))
sum_for_tag <- all_sum[[tag]]
expect_true(S7::S7_inherits(sum_for_tag, EvalKeyMap))

# ── Interaction with the clear surface ────────────────

## After clear_eval_mult_keys(tag = ...), the entry for this
## tag should disappear from get_all_eval_mult_keys.
clear_eval_mult_keys(key_tag = tag)
all_mult_after <- get_all_eval_mult_keys()
expect_false(tag %in% names(all_mult_after))

## Per-tag getter on a cleared tag — the C++ side surfaces
## this through catch_openfhe as "not generated for ID".
expect_error(get_eval_mult_key_vector(tag),
             pattern = "not generated|not found|EvalMult")

## Clearing automorphism keys removes the tag from both
## get_all_eval_automorphism_keys and get_all_eval_sum_keys
## (shared backing storage).
clear_eval_automorphism_keys(key_tag = tag)
all_rot_after <- get_all_eval_automorphism_keys()
expect_false(tag %in% names(all_rot_after))
all_sum_after <- get_all_eval_sum_keys()
expect_false(tag %in% names(all_sum_after))

# ── Empty-registry case ─────────────────────────────────

## After clearing everything, the getters return empty lists.
clear_eval_mult_keys()
clear_eval_automorphism_keys()
expect_equal(length(get_all_eval_mult_keys()), 0L)
expect_equal(length(get_all_eval_automorphism_keys()), 0L)
expect_equal(length(get_all_eval_sum_keys()), 0L)

# ── Formals shape assertions ────────────────────────────

expect_equal(length(formals(get_all_eval_mult_keys)), 0L)
expect_identical(names(formals(get_eval_mult_key_vector)), "key_tag")
expect_equal(length(formals(get_all_eval_automorphism_keys)), 0L)
expect_equal(length(formals(get_all_eval_sum_keys)), 0L)
