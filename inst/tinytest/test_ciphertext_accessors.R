## @openfhe-python: src/lib/bindings.cpp (Ciphertext accessors) [PARTIAL]
##
## Ciphertext accessor surface + fhe_ckks_tolerance()
## Stage 2 S7 dispatch on Ciphertext.
library(openfhe.R)

# ── Build a CKKS ciphertext for testing ─────────────────
cc <- fhe_context(
  "CKKS",
  multiplicative_depth = 4L,
  scaling_mod_size     = 50L,
  batch_size           = 8L,
  scaling_technique    = ScalingTechnique$FIXEDMANUAL
)
kp <- key_gen(cc, eval_mult = TRUE)
pt <- make_ckks_packed_plaintext(cc, c(0.1, 0.2, 0.3, 0.4))
ct <- encrypt(kp@public, pt, cc)

# ── Basic accessors on Ciphertext ───────────────────────
expect_true(S7::S7_inherits(ct, Ciphertext))
expect_equal(get_level(ct), 0L)             # fresh ciphertext
expect_equal(get_slots(ct), 8L)             # matches batch_size
expect_equal(get_noise_scale_deg(ct), 1L)   # fresh
expect_true(get_scaling_factor(ct) > 0)
expect_equal(get_encoding_type(ct), PlaintextEncodings$CKKS_PACKED_ENCODING)
expect_silent(get_scaling_factor_int(ct))   # BGV-specific; returns default on CKKS

# ── Setters round-trip ──────────────────────────────────
set_level(ct, 2L)
expect_equal(get_level(ct), 2L)
set_level(ct, 0L)  # restore

set_noise_scale_deg(ct, 3L)
expect_equal(get_noise_scale_deg(ct), 3L)
set_noise_scale_deg(ct, 1L)

set_slots(ct, 4L)
expect_equal(get_slots(ct), 4L)
set_slots(ct, 8L)

# ── get_crypto_context: returns the associated CryptoContext ──
cc2 <- get_crypto_context(ct)
expect_true(S7::S7_inherits(cc2, CryptoContext))
## The returned context should behave identically to the original.
expect_equal(get_multiplicative_depth(cc2), get_multiplicative_depth(cc))
expect_equal(get_scaling_technique(cc2),    get_scaling_technique(cc))

# ── Key tag accessors on Ciphertext ─────────────────────
## Ciphertext inherits GetKeyTag/SetKeyTag from CryptoObject<Element>.
tag_default <- get_key_tag(ct)
expect_true(is.character(tag_default))
set_key_tag(ct, "party-7-ct")
expect_equal(get_key_tag(ct), "party-7-ct")

# ── get_scaling_factor_real and ckks_scaling_factor_bits ──
sfr <- get_scaling_factor_real(cc, level = 0L)
expect_true(is.numeric(sfr))
expect_true(sfr > 0)

## ckks_scaling_factor_bits should round-trip the scaling_mod_size
## we used at fhe_context() construction (50L).
bits <- ckks_scaling_factor_bits(cc)
expect_true(is.integer(bits))
expect_equal(bits, 50L)

# ── fhe_ckks_tolerance() Stage 2 dispatch on Ciphertext ─
tol_ct <- fhe_ckks_tolerance(ct)
expect_true(is.numeric(tol_ct))
expect_true(tol_ct > 0)

## Stage 1 (numeric) form should still work — the original call
## shape is preserved via the class_numeric method.
tol_num <- fhe_ckks_tolerance(4L, 50L, "FLEXIBLEAUTO")
expect_true(is.numeric(tol_num))
expect_true(tol_num > 0)

## Stage 1 also accepts an integer enum value for scaling_technique
## now (needed for the Ciphertext method's internal path).
tol_num_int <- fhe_ckks_tolerance(4L, 50L, ScalingTechnique$FLEXIBLEAUTO)
expect_equal(tol_num_int, tol_num)

## Stage 2 reads the ciphertext's context: depth = 4, scaling factor
## bits = 50, scaling technique = FIXEDMANUAL. At a fresh ciphertext
## (level 0) the remaining depth equals the configured
## multiplicative_depth, so tol_ct should match
## fhe_ckks_tolerance(4L, 50L, "FIXEDMANUAL").
tol_manual <- fhe_ckks_tolerance(4L, 50L, "FIXEDMANUAL")
expect_equal(tol_ct, tol_manual)

## After advancing the ciphertext's level, the remaining-depth
## component should drop. Under FIXEDMANUAL the per-level loss is
## 0 so the tolerance value does not actually change, but the
## Ciphertext method path is still exercised.
set_level(ct, 1L)
tol_ct_lvl1 <- fhe_ckks_tolerance(ct)
## FIXEDMANUAL: per-level loss = 0, so the tolerance still matches.
expect_equal(tol_ct_lvl1, tol_manual)
set_level(ct, 0L)

# ── BFV ciphertext accessors (same generics) ───────────
cc_bfv <- fhe_context("BFV", plaintext_modulus = 65537L, multiplicative_depth = 2L)
kp_bfv <- key_gen(cc_bfv, eval_mult = TRUE)
pt_bfv <- make_packed_plaintext(cc_bfv, c(1L, 2L, 3L, 4L))
ct_bfv <- encrypt(kp_bfv@public, pt_bfv, cc_bfv)

expect_equal(get_level(ct_bfv), 0L)
expect_silent(get_slots(ct_bfv))
expect_silent(get_noise_scale_deg(ct_bfv))
expect_silent(get_scaling_factor(ct_bfv))
expect_silent(get_scaling_factor_int(ct_bfv))
expect_equal(get_encoding_type(ct_bfv), PlaintextEncodings$PACKED_ENCODING)

## get_crypto_context on a BFV ciphertext returns the BFV cc.
cc_bfv_back <- get_crypto_context(ct_bfv)
expect_equal(get_scheme_id(cc_bfv_back), SchemeId$BFVRNS_SCHEME)

# ── BFV decrypt-round-trip is unaffected by the accessors ──
out <- decrypt(ct_bfv, kp_bfv@secret, cc_bfv)
set_length(out, 4L)
expect_equal(get_packed_value(out), c(1L, 2L, 3L, 4L))
