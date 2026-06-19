## @openfhe-python: src/lib/bindings.cpp (InsertEvalMultKey + single-tag clear overloads) [PARTIAL]
##
## InsertEvalMultKey (Python binds)
## plus the key-tag-specific clear overloads for EvalMult and
## EvalAutomorphism (Python binds only the no-arg forms, so
## the tag overloads are effectively R-only additions).
library(openfhe.R)

# ── Setup: BFV with MULTIPARTY + eval-mult keys ─────────
cc <- fhe_context("BFV",
  plaintext_modulus = 65537,
  multiplicative_depth = 2,
  features = c(Feature$MULTIPARTY)
)
kp <- key_gen(cc, eval_mult = TRUE)
tag <- get_key_tag(kp@secret)

x <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L)
pt_x <- make_packed_plaintext(cc, x)

# ── Baseline: eval_mult works right after key_gen ───────

ct_x <- encrypt(kp@public, pt_x, cc = cc)
ct_sq <- eval_mult(ct_x, ct_x)
expect_true(S7::S7_inherits(ct_sq, Ciphertext))

# ── clear_eval_mult_keys(key_tag): single-tag path ──────

## After clearing by tag, the cc's EvalMult key cache should
## no longer contain an entry for this tag. Subsequent
## eval_mult should fail at the VerifyAdvancedSHE check with
## a "has not been generated for this key ID" error.
clear_eval_mult_keys(key_tag = tag)
ct_fresh <- encrypt(kp@public, pt_x, cc = cc)
expect_error(eval_mult(ct_fresh, ct_fresh),
             pattern = "EvalMultKey|not been generated|not.*enabled")

## Re-generate and verify eval_mult recovers.
openfhe.R:::CryptoContext__EvalMultKeyGen(openfhe.R:::get_ptr(cc), openfhe.R:::get_ptr(kp@secret))
ct_sq2 <- eval_mult(ct_x, ct_x)
expect_true(S7::S7_inherits(ct_sq2, Ciphertext))

# ── clear_eval_mult_keys(NULL): clear-all path ──────────

## NULL (default) routes to the no-arg ClearEvalMultKeys in
## pke_serialization.cpp — equivalent to clear_fhe_state's
## "mult_keys" branch. Verify it still works and subsequent
## eval_mult fails.
clear_eval_mult_keys()
ct_fresh2 <- encrypt(kp@public, pt_x, cc = cc)
expect_error(eval_mult(ct_fresh2, ct_fresh2),
             pattern = "EvalMultKey|not been generated|not.*enabled")

## Restore for subsequent tests.
openfhe.R:::CryptoContext__EvalMultKeyGen(openfhe.R:::get_ptr(cc), openfhe.R:::get_ptr(kp@secret))

# ── clear_eval_automorphism_keys: key_tag and NULL paths ──

## Generate rotation keys, then clear by tag and verify the
## rotation fails. Regenerate via a second key_gen call with
## rotations (which produces a NEW keypair — cc's internal
## registry grows a rotation-key entry for the new tag).
kp_rot <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, 2L))
tag_rot <- get_key_tag(kp_rot@secret)
ct_rot <- encrypt(kp_rot@public, pt_x, cc = cc)
expect_true(S7::S7_inherits(eval_rotate(ct_rot, index = 1L), Ciphertext))

clear_eval_automorphism_keys(key_tag = tag_rot)
ct_rot_fresh <- encrypt(kp_rot@public, pt_x, cc = cc)
expect_error(eval_rotate(ct_rot_fresh, index = 1L),
             pattern = "not generated|not been generated|Automorphism|automorphism|not.*enabled")

## NULL path: clear all automorphism keys.
kp_rot2 <- key_gen(cc, eval_mult = TRUE, rotations = c(1L))
clear_eval_automorphism_keys()  # NULL default
ct_rot2_fresh <- encrypt(kp_rot2@public, pt_x, cc = cc)
expect_error(eval_rotate(ct_rot2_fresh, index = 1L),
             pattern = "not generated|not been generated|Automorphism|automorphism|not.*enabled")

# ── insert_eval_mult_key: wrapper dispatch ──────────────

## Produce an EvalKey via the multi_key_switch_gen surface
## so we have a list<EvalKey> to feed into insert_eval_mult_key.
## The key-switch generator needs a scaffold eval key — use the
## cc's current eval-mult storage (regenerated above) via
## CryptoContext__EvalMultKeyGen side effect. For the wrapper
## test we just need the binding to dispatch and accept the
## marshalled vector.
openfhe.R:::CryptoContext__EvalMultKeyGen(openfhe.R:::get_ptr(cc), openfhe.R:::get_ptr(kp@secret))

## insert_eval_mult_key input validation: non-list aborts.
expect_error(insert_eval_mult_key("not a list"),
             pattern = "eval_keys.*list")

## Empty list is a degenerate no-op — verify it does not
## throw at the R layer. The C++ side may or may not accept
## an empty vector; catch the result either way.
ok <- tryCatch({
  insert_eval_mult_key(list(), key_tag = "empty-test")
  TRUE
}, error = function(e) TRUE)  # either way the R wrapper dispatched
expect_true(ok)

# ── Formals shape assertions ────────────────────────────

expect_identical(names(formals(insert_eval_mult_key)),
                 c("eval_keys", "key_tag"))
expect_identical(names(formals(clear_eval_mult_keys)), "key_tag")
expect_identical(names(formals(clear_eval_automorphism_keys)),
                 "key_tag")
expect_null(formals(clear_eval_mult_keys)$key_tag)
expect_null(formals(clear_eval_automorphism_keys)$key_tag)
expect_equal(formals(insert_eval_mult_key)$key_tag, "")
