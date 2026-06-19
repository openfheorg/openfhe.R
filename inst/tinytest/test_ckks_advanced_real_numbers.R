## CKKS advanced features: scaling techniques, hybrid key switching,
## hoisted (fast) rotations.
## @openfhe-python: pke/advanced-real-numbers.py [FULL: skips
## get_native_int()==128 branch which gates FLEXIBLEAUTO in
## hybrid_key_switching_demo and fast_rotation_demo; we always run
## with FLEXIBLEAUTO since the build is 64-bit native]
library(openfhe.R)

batch_size <- 8L
x_poly <- c(1.0, 1.01, 1.02, 1.03, 1.04, 1.05, 1.06, 1.07)
expected_poly <- x_poly^18 + x_poly^9 + 1.0
tol <- 1e-3   # depth-5 CKKS, default scaling_mod_size=50

# Helper: encrypt, evaluate f(x) = x^18 + x^9 + 1, decrypt to vector.
poly_eval_then_decrypt <- function(cc, keys, ct_x, manual_rescale = FALSE) {
  if (manual_rescale) {
    c2 <- rescale(ct_x * ct_x)
    c4 <- rescale(c2 * c2)
    c8 <- rescale(c4 * c4)
    c16 <- rescale(c8 * c8)
    c9 <- c8 * ct_x
    c18 <- c16 * c2
    c_res <- rescale((c18 + c9) + 1.0)
  } else {
    c2 <- ct_x * ct_x
    c4 <- c2 * c2
    c8 <- c4 * c4
    c16 <- c8 * c8
    c9 <- c8 * ct_x
    c18 <- c16 * c2
    c_res <- (c18 + c9) + 1.0
  }
  res <- decrypt(c_res, keys@secret, cc = cc)
  set_length(res, batch_size)
  get_real_packed_value(res)[1:batch_size]
}

# ── automatic_rescale_demo: FLEXIBLEAUTO ────────────────
cc_flex <- fhe_context("CKKS",
  multiplicative_depth = 5L,
  scaling_mod_size = 50L,
  batch_size = batch_size,
  scaling_technique = ScalingTechnique$FLEXIBLEAUTO)
keys_flex <- key_gen(cc_flex, eval_mult = TRUE)
pt_flex <- make_ckks_packed_plaintext(cc_flex, x_poly)
ct_flex <- encrypt(keys_flex@public, pt_flex, cc = cc_flex)
expect_equal(poly_eval_then_decrypt(cc_flex, keys_flex, ct_flex),
             expected_poly, tolerance = tol)

# ── automatic_rescale_demo: FIXEDAUTO ───────────────────
cc_fauto <- fhe_context("CKKS",
  multiplicative_depth = 5L,
  scaling_mod_size = 50L,
  batch_size = batch_size,
  scaling_technique = ScalingTechnique$FIXEDAUTO)
keys_fauto <- key_gen(cc_fauto, eval_mult = TRUE)
pt_fauto <- make_ckks_packed_plaintext(cc_fauto, x_poly)
ct_fauto <- encrypt(keys_fauto@public, pt_fauto, cc = cc_fauto)
expect_equal(poly_eval_then_decrypt(cc_fauto, keys_fauto, ct_fauto),
             expected_poly, tolerance = tol)

# ── manual_rescale_demo: FIXEDMANUAL ────────────────────
cc_man <- fhe_context("CKKS",
  multiplicative_depth = 5L,
  scaling_mod_size = 50L,
  batch_size = batch_size,
  scaling_technique = ScalingTechnique$FIXEDMANUAL)
keys_man <- key_gen(cc_man, eval_mult = TRUE)
pt_man <- make_ckks_packed_plaintext(cc_man, x_poly)
ct_man <- encrypt(keys_man@public, pt_man, cc = cc_man)
expect_equal(poly_eval_then_decrypt(cc_man, keys_man, ct_man,
                                    manual_rescale = TRUE),
             expected_poly, tolerance = tol)

# ── hybrid_key_switching_demo: helper ───────────────────
hybrid_rot_test <- function(dnum) {
  x <- c(1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7)
  cc <- fhe_context("CKKS",
    multiplicative_depth = 5L,
    scaling_mod_size = 50L,
    batch_size = batch_size,
    scaling_technique = ScalingTechnique$FLEXIBLEAUTO,
    num_large_digits = dnum)
  keys <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, -2L))
  pt <- make_ckks_packed_plaintext(cc, x)
  ct <- encrypt(keys@public, pt, cc = cc)
  ct_rot1 <- eval_rotate(ct, 1L)
  ct_rot2 <- eval_rotate(ct_rot1, -2L)
  res <- decrypt(ct_rot2, keys@secret, cc = cc)
  set_length(res, batch_size)
  # Rotating left by 1 then right by 2 == rotating right by 1.
  expected <- c(tail(x, 1), head(x, batch_size - 1L))
  expect_equal(get_real_packed_value(res)[1:batch_size], expected, tolerance = tol)
}

hybrid_rot_test(2L)
hybrid_rot_test(3L)

# ── fast_rotation_demo1 (HYBRID, default) ───────────────
fast_rotation_test <- function(use_bv = FALSE) {
  x <- c(0, 0, 0, 0, 0, 0, 0, 1)
  if (use_bv) {
    cc <- fhe_context("CKKS",
      multiplicative_depth = 1L,
      scaling_mod_size = 50L,
      batch_size = batch_size,
      scaling_technique = ScalingTechnique$FLEXIBLEAUTO,
      key_switch_technique = KeySwitchTechnique$BV,
      first_mod_size = 60L,
      digit_size = 3L)
  } else {
    cc <- fhe_context("CKKS",
      multiplicative_depth = 5L,
      scaling_mod_size = 50L,
      batch_size = batch_size)
  }
  keys <- key_gen(cc, eval_mult = TRUE, rotations = 1:7)
  pt <- make_ckks_packed_plaintext(cc, x)
  ct <- encrypt(keys@public, pt, cc = cc)

  # Non-hoisted rotations (baseline).
  rots_plain <- lapply(1:7, function(k) eval_rotate(ct, k))

  # Hoisted rotations.
  N <- ring_dimension(cc)
  M <- 2L * N
  precomp <- eval_fast_rotation_precompute(ct)
  rots_fast <- lapply(1:7, function(k) eval_fast_rotation(ct, k, M, precomp))

  expected <- function(k) {
    out <- numeric(batch_size)
    out[((seq_len(batch_size) - 1L - k) %% batch_size) + 1L] <- x
    out
  }

  decode <- function(c) {
    res <- decrypt(c, keys@secret, cc = cc)
    set_length(res, batch_size)
    get_real_packed_value(res)[1:batch_size]
  }

  for (k in 1:7) {
    expect_equal(decode(rots_plain[[k]]), expected(k), tolerance = tol,
      info = sprintf("non-hoisted k=%d use_bv=%s", k, use_bv))
    expect_equal(decode(rots_fast[[k]]), expected(k), tolerance = tol,
      info = sprintf("hoisted k=%d use_bv=%s", k, use_bv))
  }
}

fast_rotation_test(use_bv = FALSE)
fast_rotation_test(use_bv = TRUE)
