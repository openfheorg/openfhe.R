## @openfhe-python: src/lib/bindings.cpp (factory arg completion) [PARTIAL]
##
## Factory argument-completion pass. Covers:
##   - make_packed_plaintext 3-arg round trip (values, noise_scale_deg, level)
##   - make_coef_packed_plaintext
##   - make_ckks_packed_plaintext 5-arg round trip with all four new args
##   - encrypt(PrivateKey, Plaintext) S7 overload
##   - enable_feature mask overload
##   - get_scheme_id on CryptoContext
##   - clear_static_maps_and_vectors
##   - get_key_tag / set_key_tag on PublicKey and PrivateKey
##   - is_good on KeyPair
library(openfhe.R)

# ── make_packed_plaintext with new args ─────────────────
cc_bfv <- fhe_context("BFV", plaintext_modulus = 65537L, multiplicative_depth = 2L)
kp_bfv <- key_gen(cc_bfv, eval_mult = TRUE)

## Default args (back-compat)
pt_bfv_default <- make_packed_plaintext(cc_bfv, c(1L, 2L, 3L))
expect_equal(get_noise_scale_deg(pt_bfv_default), 1L)
expect_equal(get_level(pt_bfv_default), 0L)

## Non-default noise_scale_deg
pt_bfv_nsd2 <- make_packed_plaintext(cc_bfv, c(1L, 2L, 3L),
                                     noise_scale_deg = 2L)
expect_equal(get_noise_scale_deg(pt_bfv_nsd2), 2L)

## make_coef_packed_plaintext (new)
pt_bfv_coef <- make_coef_packed_plaintext(cc_bfv, c(1L, 2L, 3L))
expect_true(is_encoded(pt_bfv_coef))
expect_equal(get_encoding_type(pt_bfv_coef),
             PlaintextEncodings$COEF_PACKED_ENCODING)

# ── make_ckks_packed_plaintext with new args ────────────
cc_ckks <- fhe_context(
  "CKKS",
  multiplicative_depth = 4L,
  scaling_mod_size     = 50L,
  batch_size           = 8L,
  scaling_technique    = ScalingTechnique$FIXEDMANUAL
)
kp_ckks <- key_gen(cc_ckks, eval_mult = TRUE)

## Default args (back-compat)
pt_ckks_default <- make_ckks_packed_plaintext(cc_ckks, c(0.1, 0.2, 0.3, 0.4))
expect_equal(get_noise_scale_deg(pt_ckks_default), 1L)
expect_equal(get_level(pt_ckks_default), 0L)

## Non-default noise_scale_deg and level (under FIXEDMANUAL,
## these propagate directly). Under FLEXIBLEAUTO the auto-rescale
## logic would override them — discovery D011.
pt_ckks_nsd <- make_ckks_packed_plaintext(
  cc_ckks, c(0.1, 0.2, 0.3, 0.4),
  noise_scale_deg = 2L
)
expect_equal(get_noise_scale_deg(pt_ckks_nsd), 2L)

pt_ckks_lvl <- make_ckks_packed_plaintext(
  cc_ckks, c(0.1, 0.2, 0.3, 0.4),
  level = 1L
)
expect_equal(get_level(pt_ckks_lvl), 1L)

## slots argument: slots=0 means "use batch_size", slots=4 means
## literal 4. (cf. fixture rationale).
pt_ckks_slots_default <- make_ckks_packed_plaintext(
  cc_ckks, c(0.1, 0.2, 0.3, 0.4)
)
expect_equal(get_slots(pt_ckks_slots_default), 8L)  ## batch_size

pt_ckks_slots4 <- make_ckks_packed_plaintext(
  cc_ckks, c(0.1, 0.2, 0.3, 0.4),
  slots = 4L
)
expect_equal(get_slots(pt_ckks_slots4), 4L)

## params arg: only NULL is supported here (no R-side way to
## build a non-default ElementParams in this path). Verify the
## default NULL path works and does not error.
pt_ckks_params_null <- make_ckks_packed_plaintext(
  cc_ckks, c(0.1, 0.2, 0.3, 0.4),
  params = NULL
)
expect_true(is_encoded(pt_ckks_params_null))

# ── encrypt(PrivateKey, Plaintext) overload ─────────────
pt_for_sk <- make_packed_plaintext(cc_bfv, c(10L, 20L, 30L))
## Encrypt with the secret key instead of the public key
ct_from_sk <- encrypt(kp_bfv@secret, pt_for_sk, cc_bfv)
expect_true(S7::S7_inherits(ct_from_sk, Ciphertext))
## Decrypt and verify round-trip
pt_dec <- decrypt(ct_from_sk, kp_bfv@secret, cc_bfv)
set_length(pt_dec, 3L)
expect_equal(get_packed_value(pt_dec), c(10L, 20L, 30L))

# ── enable_feature mask overload ────────────────────────
## Create a fresh context and enable features via an integer mask
## instead of individual calls.
cc_mask <- fhe_context("BFV", plaintext_modulus = 65537L, multiplicative_depth = 2L)
## The default fhe_context already enables PKE | KEYSWITCH | LEVELEDSHE.
## Add MULTIPARTY via the mask path (single-feature mask is still a
## valid mask in principle; the dispatch picks the enum path for
## single-feature values).
enable_feature(cc_mask, Feature$MULTIPARTY)  ## single enum value
## Multi-feature mask: OR several features together.
## The dispatch detects multiple bits and routes to the _Mask binding.
combined <- bitwOr(Feature$ADVANCEDSHE, Feature$FHE)
enable_feature(cc_mask, combined)
## If both paths worked, the context is still valid for key_gen.
kp_mask <- key_gen(cc_mask, eval_mult = TRUE)
expect_true(is_good(kp_mask))

# ── get_scheme_id on CryptoContext ──────────────────────
expect_equal(get_scheme_id(cc_bfv),  SchemeId$BFVRNS_SCHEME)
expect_equal(get_scheme_id(cc_ckks), SchemeId$CKKSRNS_SCHEME)

# ── clear_static_maps_and_vectors ───────────────────────
## Idempotent — calling it should not throw and should return
## invisible(NULL).
expect_silent(clear_static_maps_and_vectors())
expect_null(clear_static_maps_and_vectors())

# ── Key-tag accessors ───────────────────────────────────
## Fresh keys start with an empty or context-assigned tag.
cc_tag <- fhe_context("BFV", plaintext_modulus = 65537L, multiplicative_depth = 2L)
kp_tag <- key_gen(cc_tag, eval_mult = TRUE)

## Get the default tags (may be empty string or a generated id)
tag_pub_default <- get_key_tag(kp_tag@public)
tag_sec_default <- get_key_tag(kp_tag@secret)
expect_true(is.character(tag_pub_default))
expect_true(is.character(tag_sec_default))

## Round-trip: set then get returns the same string
set_key_tag(kp_tag@public, "party-1")
expect_equal(get_key_tag(kp_tag@public), "party-1")

set_key_tag(kp_tag@secret, "party-1-secret")
expect_equal(get_key_tag(kp_tag@secret), "party-1-secret")

# ── is_good on KeyPair ──────────────────────────────────
expect_true(is_good(kp_bfv))
expect_true(is_good(kp_ckks))
## Constructing a KeyPair with NULL ptrs produces an invalid one.
## (Direct S7 construction bypasses the key_gen factory.)
kp_null <- KeyPair(public = PublicKey(ptr = NULL),
                   secret = PrivateKey(ptr = NULL))
expect_false(is_good(kp_null))
