## @openfhe-python: src/lib/bindings.cpp (CKKSBootCorrectionFactor + EvalFastRotationExt + EvalFastRotation 3-arg) [FULL]
##
## CKKS bootstrap correction factor
## read/write, EvalFastRotationExt (the "with add_first" flag
## variant used inside CKKS bootstrap's inner loop), and the
## 3-arg EvalFastRotation convenience overload that closes
## design.md §11 open question #1 (the phantom 3-arg form is
## NOT a Python defect — the C++ header declares both
## overloads).
library(openfhe.R)

## CKKS bootstrapping — skip on CRAN for time/memory, but run everywhere
## else: on CI (GitHub Actions sets CI=true) and locally via
## tinytest::test_all() (sets TT_AT_HOME).
if (!at_home() && Sys.getenv("CI") != "true")
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")

# ── CKKS setup with rotation keys ───────────────────────
cc <- fhe_context("CKKS",
  multiplicative_depth = 4L,
  scaling_mod_size     = 50L,
  batch_size           = 8L,
  features             = c(Feature$ADVANCEDSHE, Feature$FHE)
)
kp <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, 2L, -1L, 3L))

x <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
pt <- make_ckks_packed_plaintext(cc, x)
ct <- encrypt(kp@public, pt, cc = cc)

decode <- function(ct_in, n = 8L) {
  pt_out <- decrypt(ct_in, kp@secret, cc = cc)
  set_length(pt_out, n)
  get_real_packed_value(pt_out)[1:n]
}

tol <- 1e-4

# ── CKKS bootstrap correction factor round-trip ─────────

## Read the default value set by the scheme. The default is 0
## unless EvalBootstrapSetup has been called (which sets it
## per scheme parameters). At this point bootstrap setup has
## not been called, so the default should be 0.
cf_default <- get_ckks_boot_correction_factor(cc)
expect_true(is.numeric(cf_default))
expect_equal(length(cf_default), 1L)

## Round-trip a deliberate value.
set_ckks_boot_correction_factor(cc, 9L)
expect_equal(get_ckks_boot_correction_factor(cc), 9L)

## Restore and re-verify.
set_ckks_boot_correction_factor(cc, cf_default)
expect_equal(get_ckks_boot_correction_factor(cc), cf_default)

# ── eval_fast_rotation 3-arg vs 4-arg equivalence ───────

precomp <- eval_fast_rotation_precompute(ct)

## The 3-arg convenience form internally sets
## m = GetRingDimension() * 2. Compute that value explicitly
## and verify the 4-arg form with the same m produces
## identical output to the 3-arg form.
ring_dim <- ring_dimension(cc)
m_expected <- 2 * ring_dim

## 3-arg form: omit `m`.
ct_3arg <- eval_fast_rotation(ct, index = 1L, precomp = precomp)
## 4-arg form (existing): pass m explicitly.
ct_4arg <- eval_fast_rotation(ct, 1L, m_expected, precomp)

expect_true(S7::S7_inherits(ct_3arg, Ciphertext))
expect_true(S7::S7_inherits(ct_4arg, Ciphertext))

## Decrypted outputs should match to CKKS tolerance.
expect_equal(decode(ct_3arg), decode(ct_4arg), tolerance = tol)

## Cleartext reference: rotation by 1 to the left gives
## x[-1] prepended with 0 in the shifted slot. Under CKKS
## slot-rotation semantics, rotate-left-by-1 rearranges to
## `c(x[2:8], 0)` padded from the cc's ring dimension.
expected_rot <- c(x[2:8], 0)
## CKKS fast rotation gives approximately this shape for the
## first 7 slots (the 8th slot is the "wrap" and depends on
## ring-dimension padding).
got_rot <- decode(ct_3arg)
expect_equal(got_rot[1:7], expected_rot[1:7], tolerance = tol)

# ── Backward compat: existing 4-arg positional call still works ──

## Exactly mirrors test_ckks_advanced_real_numbers.R:127-128.
M <- 2 * ring_dim
rots_fast <- lapply(1:3, function(k) eval_fast_rotation(ct, k, M, precomp))
for (r in rots_fast) {
  expect_true(S7::S7_inherits(r, Ciphertext))
}
## Slot-1 rotation under the positional 4-arg form matches
## the slot-1 rotation under the 3-arg form.
expect_equal(decode(rots_fast[[1]]), decode(ct_3arg), tolerance = tol)

# ── eval_fast_rotation_ext smoke test ───────────────────

## add_first = FALSE is the "ordinary" fast rotation; the ext
## variant adds the first digit of the decomposition to the
## output before the rotation is applied. Under
## add_first = FALSE, EvalFastRotationExt is expected to
## differ from the non-Ext form only in the RNS extension
## (P*Q basis vs Q basis) — the cleartext value differs
## because an Ext ciphertext lives in a different modulus
## space and typically requires a subsequent KeySwitchDown
## call (KeySwitchDown) to bring it back to Q. We assert that
## the binding dispatches, produces a Ciphertext object, and
## does not crash. The full numeric validation ships with
## the KeySwitchDown test.
ct_ext <- eval_fast_rotation_ext(ct, index = 1L, precomp = precomp,
                                 add_first = FALSE)
expect_true(S7::S7_inherits(ct_ext, Ciphertext))

ct_ext_addfirst <- eval_fast_rotation_ext(ct, index = 1L, precomp = precomp,
                                          add_first = TRUE)
expect_true(S7::S7_inherits(ct_ext_addfirst, Ciphertext))

# ── Formals check ───────────────────────────────────────

expect_identical(names(formals(get_ckks_boot_correction_factor)), "cc")
expect_identical(names(formals(set_ckks_boot_correction_factor)),
                 c("cc", "cf"))
