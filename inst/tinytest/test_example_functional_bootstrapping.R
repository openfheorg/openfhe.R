## OPENFHE PYTHON SOURCE: examples/pke/functional-bootstrapping-ckks.py
##
## @openfhe-python: functional-bootstrapping-ckks.py [FULL]
##
## Functional bootstrapping of RLWE ciphertexts through CKKS: an
## arbitrary look-up table, two tables on one input with leveled
## computation in between, and the sign of a multi-digit input. The
## nine parameter sets of the Python main() run at home; the first
## Boolean one runs everywhere.
library(openfhe.R)

at_home <- tinytest::at_home()

## 2^n as a string of decimal digits (n can exceed 53).
pow2 <- function(n) {
  d <- 1L
  for (i in seq_len(n)) {
    d <- d * 2L
    carry <- d %/% 10L
    d <- d %% 10L
    if (any(carry > 0L)) {
      d <- c(d, 0L) + c(0L, carry)
      if (d[length(d)] == 0L) d <- d[-length(d)]
    }
  }
  paste(rev(d), collapse = "")
}
expect_identical(pow2(60L), "1152921504606846976")

fill <- function(a, slots) a[(seq_len(slots) - 1L) %% length(a) + 1L]

## Rotates the vector by the index amount (positive: left).
rotate <- function(a, index) {
  n <- length(a)
  index <- index %% n
  if (index == 0L) return(a)
  c(a[(index + 1L):n], a[seq_len(index)])
}

## Rotates each half of the vector, as the BFV subring rotations do.
rotate_two_halves <- function(a, index) {
  h <- length(a) %/% 2L
  c(rotate(a[seq_len(h)], index), rotate(a[h + seq_len(h)], index))
}

centered <- function(v, p) ifelse(v > p / 2, v - p, v)

new_context <- function(dcrt_bits, scal_tech, num_slots_ckks, ring_dim, depth) {
  fhe_context("CKKS",
    secret_key_dist = SecretKeyDist$SPARSE_ENCAPSULATED,
    security_level = SecurityLevel$HEStd_NotSet,
    scaling_mod_size = dcrt_bits,
    scaling_technique = scal_tech,
    first_mod_size = dcrt_bits,
    num_large_digits = 3L,
    batch_size = num_slots_ckks,
    ring_dim = ring_dim,
    multiplicative_depth = depth,
    features = c(Feature$ADVANCEDSHE, Feature$FHE))
}

input_values <- function(p_input, num_slots) {
  x <- c(p_input %/% 2, p_input %/% 2 + 1, 0, 3, 16, 33, 64, p_input - 1)
  if (length(x) < num_slots) fill(x, num_slots) else x
}

## Moduli are powers of two, given by their exponents: q_init_bits,
## q_bits (Q) and bigq_bits (Bigq).
# ══ 1. An arbitrary look-up table ════════════════════════
arbitrary_lut <- function(q_init_bits, p_input, p_output, q_bits, bigq_bits,
                          scale_thi, order, num_slots, ring_dim, func) {
  flag_sp <- num_slots <= ring_dim %/% 2
  num_slots_ckks <- if (flag_sp) num_slots else num_slots %/% 2
  x <- input_values(p_input, num_slots)

  ## The Boolean case of order 1 has an optimized form with integer
  ## coefficients for [1, cos^2(pi x)].
  binary_lut <- p_input == 2 && order == 1
  coeff <- if (binary_lut) {
    as.integer(c(func(1), func(0) - func(1)))
  } else {
    get_hermite_trig_coefficients(func, p_input, order, scale_thi)
  }

  skd <- SecretKeyDist$SPARSE_ENCAPSULATED
  lvlb <- c(3L, 3L)
  depth <- get_fbt_depth(lvlb, coeff, p_input, order, skd)
  cc <- new_context(bigq_bits, ScalingTechnique$FLEXIBLEAUTO, num_slots_ckks,
                    ring_dim, depth)
  keys <- key_gen(cc)
  eval_fbt_setup(cc, coeff, num_slots_ckks, p_input, p_output, pow2(bigq_bits),
                 keys@public, c(0L, 0L), lvlb, 0L, 0L, order)
  eval_bootstrap_key_gen(cc, keys@secret, num_slots_ckks)
  eval_mult_key_gen(cc, keys@secret)

  ## Encrypt in RLWE over a larger modulus, then switch down.
  ep <- schemelet_get_element_params(keys@secret, depth)
  ctxt_bfv <- schemelet_encrypt_coeff(x, pow2(q_init_bits), p_input,
                                      keys@secret, ep)
  schemelet_mod_switch(ctxt_bfv, pow2(q_bits), pow2(q_init_bits))

  ctxt <- schemelet_convert_rlwe_to_ckks(cc, ctxt_bfv, keys@public,
                                         pow2(bigq_bits), num_slots_ckks, depth)
  ctxt_after <- eval_fbt(ctxt, coeff, log2(p_input), get_modulus(ep),
                         scale_thi, 0L, order)
  polys <- schemelet_convert_ckks_to_rlwe(ctxt_after, pow2(q_bits))
  computed <- schemelet_decrypt_coeff(polys, pow2(q_bits), p_output,
                                      keys@secret, ep, num_slots_ckks, num_slots)

  exact <- centered(vapply(x, func, numeric(1)), p_output)
  max(abs(exact - computed) %% p_output)
}

lut_bool <- function(x) (x %% 2 - 2 %/% 2) %% 2
expect_equal(arbitrary_lut(60L, 2, 2, 33L, 33L, 1, 1L, 8L, 4096L, lut_bool), 0)
if (at_home) {
  expect_equal(arbitrary_lut(60L, 2, 2, 33L, 33L, 1, 2L, 8L, 4096L, lut_bool), 0)
  expect_equal(arbitrary_lut(60L, 2, 2, 33L, 33L, 1, 1L, 1024L, 4096L, lut_bool), 0)
  expect_equal(arbitrary_lut(60L, 256, 16, 47L, 47L, 32, 1L, 8L, 4096L,
                             function(x) (x %% 256 - 16 %/% 2) %% 16), 0)
}

# ══ 2. Several tables on one input ═══════════════════════
multi_value_bootstrapping <- function(q_init_bits, p_input, p_output, q_bits,
                                      bigq_bits, scale_thi, order, num_slots,
                                      ring_dim, levels_computation) {
  flag_sp <- num_slots <= ring_dim %/% 2
  num_slots_ckks <- if (flag_sp) num_slots else num_slots %/% 2
  a <- p_input
  b <- p_output
  func1 <- function(x) (x %% a - a %/% 2) %% b
  func2 <- function(x) (x %% a) %% b
  x <- input_values(p_input, num_slots)

  binary_lut <- p_input == 2 && order == 1
  if (binary_lut) {
    coeff1 <- as.integer(c(func1(1), func1(0) - func1(1)))
    coeff2 <- as.integer(c(func2(1), func2(0) - func2(1)))
  } else {
    coeff1 <- get_hermite_trig_coefficients(func1, p_input, order, scale_thi)
    coeff2 <- get_hermite_trig_coefficients(func2, p_input, order, scale_thi)
  }

  skd <- SecretKeyDist$SPARSE_ENCAPSULATED
  scal_tech <- ScalingTechnique$FIXEDMANUAL
  lvlb <- c(3L, 3L)
  depth <- levels_computation + get_fbt_depth(lvlb, coeff1, p_input, order, skd)
  cc <- new_context(bigq_bits, scal_tech, num_slots_ckks, ring_dim, depth)
  keys <- key_gen(cc)
  eval_fbt_setup(cc, coeff1, num_slots_ckks, p_input, p_output, pow2(bigq_bits),
                 keys@public, c(0L, 0L), lvlb, 0L, levels_computation, order)
  eval_bootstrap_key_gen(cc, keys@secret, num_slots_ckks)
  eval_mult_key_gen(cc, keys@secret)
  eval_at_index_key_gen(cc, keys@secret, -2L)

  mask_real <- fill(c(1, 1, 1, 1, 0, 0, 0, 0), num_slots)
  ptxt_mask <- make_ckks_packed_plaintext(
    cc, fill(c(1, 1, 1, 1, 0, 0, 0, 0), num_slots_ckks), 1L,
    depth - lvlb[2] - levels_computation, NULL, num_slots_ckks)

  ## With the FFT method for the homomorphic encoding and decoding and
  ## leveled computation in slot-packed CKKS, the RLWE input is encoded
  ## in bit-reversed order.
  flag_br <- lvlb[1] != 1L || lvlb[2] != 1L

  ep <- schemelet_get_element_params(keys@secret, depth)
  ctxt_bfv <- schemelet_encrypt_coeff(x, pow2(q_init_bits), p_input,
                                      keys@secret, ep, flag_br)
  schemelet_mod_switch(ctxt_bfv, pow2(q_bits), pow2(q_init_bits))
  ctxt <- schemelet_convert_rlwe_to_ckks(cc, ctxt_bfv, keys@public,
                                         pow2(bigq_bits), num_slots_ckks, depth)

  exact1 <- centered(vapply(x, func1, numeric(1)), p_output)
  exact2 <- centered(vapply(x, func2, numeric(1)), p_output)

  ## The complex exponential and its powers once; then one table each.
  powers <- eval_mvb_precompute(ctxt, coeff1, log2(p_input), get_modulus(ep),
                                order)
  ctxt_after1 <- eval_mvb(powers, coeff1, log2(p_input), scale_thi,
                          levels_computation, order)
  ctxt_after2 <- eval_mvb_no_decoding(powers, coeff2, log2(p_input), order)

  ## A rotation and a multiplicative mask in slot-packed CKKS.
  ctxt_after2 <- eval_rotate(ctxt_after2, -2L)
  exact2 <- if (flag_sp) rotate(exact2, -2L) else rotate_two_halves(exact2, -2L)
  ctxt_after2 <- eval_mult(ctxt_after2, ptxt_mask)
  mod_reduce_in_place(ctxt_after2)
  exact2 <- exact2 * mask_real

  ## Back to coefficient encoding.
  ctxt_after2 <- eval_hom_decoding(ctxt_after2, scale_thi,
                                   levels_computation - 1L)

  dec <- function(ct) {
    polys <- schemelet_convert_ckks_to_rlwe(ct, pow2(q_bits))
    schemelet_decrypt_coeff(polys, pow2(q_bits), p_output, keys@secret, ep,
                            num_slots_ckks, num_slots, flag_br)
  }
  c(max(abs(exact1 - dec(ctxt_after1)) %% p_output),
    max(abs(exact2 - dec(ctxt_after2)) %% p_output))
}

if (at_home) {
  expect_equal(multi_value_bootstrapping(60L, 256, 256, 47L, 47L, 32, 1L, 256L,
                                         2048L, 1L), c(0, 0))
}

# ══ 3. The sign of a multi-digit input ═══════════════════
multi_precision_sign <- function(q_init_bits, p_input, p_digit, q_bits,
                                 bigq_bits, scale_thi, scale_step_thi, order,
                                 num_slots, ring_dim) {
  flag_sp <- num_slots <= ring_dim %/% 2
  num_slots_ckks <- if (flag_sp) num_slots else num_slots %/% 2
  a <- p_input
  b <- p_digit
  func_mod <- function(x) x %% b
  func_step <- function(x) as.numeric((x %% a) >= (b %/% 2))
  x <- input_values(p_input, num_slots)
  exact <- as.numeric(x >= p_input / 2)
  p_orig <- p_input

  binary_lut <- p_digit == 2 && order == 1
  if (binary_lut) {
    coeff_mod <- as.integer(c(func_mod(1), func_mod(0) - func_mod(1)))
    coeff_step <- NULL
  } else {
    coeff_mod <- get_hermite_trig_coefficients(func_mod, p_digit, order, scale_thi)
    coeff_step <- get_hermite_trig_coefficients(func_step, p_digit, order,
                                                scale_step_thi)
  }

  skd <- SecretKeyDist$SPARSE_ENCAPSULATED
  lvlb <- c(3L, 3L)
  depth <- get_fbt_depth(lvlb, coeff_mod, p_digit, order, skd)
  cc <- new_context(bigq_bits, ScalingTechnique$FIXEDMANUAL, num_slots_ckks,
                    ring_dim, depth)
  keys <- key_gen(cc)
  eval_mult_key_gen(cc, keys@secret)
  eval_fbt_setup(cc, coeff_mod, num_slots_ckks, p_digit, p_input,
                 pow2(bigq_bits), keys@public, c(0L, 0L), lvlb, 0L, 0L, order)
  eval_bootstrap_key_gen(cc, keys@secret, num_slots_ckks)

  ep <- schemelet_get_element_params(keys@secret, depth)
  ctxt_bfv <- schemelet_encrypt_coeff(x, pow2(q_init_bits), p_input,
                                      keys@secret, ep)
  schemelet_mod_switch(ctxt_bfv, pow2(q_bits), pow2(q_init_bits))

  coeff <- coeff_mod
  checkeq2 <- p_digit == 2
  checkgt2 <- p_digit > 2
  p_digit_bits <- as.integer(log2(p_digit))
  step <- FALSE
  go <- q_bits > bigq_bits
  levels_to_drop <- 0L
  post_scaling_bits <- 0L
  computed <- NULL

  ## For a digit size above one bit, the last iteration evaluates the
  ## step function and not the reduction modulo the digit.
  while (go) {
    ## Reduce modulo Bigq to extract the digit, and convert it to CKKS.
    encrypted_digit <- clone(ctxt_bfv)
    switch_modulus(encrypted_digit, pow2(bigq_bits))
    ctxt <- schemelet_convert_rlwe_to_ckks(cc, encrypted_digit, keys@public,
                                           pow2(bigq_bits), num_slots_ckks,
                                           depth)
    ## Bootstrap the digit.
    ctxt_after <- eval_fbt(ctxt, coeff, p_digit_bits, get_modulus(ep),
                           scale_thi * 2^post_scaling_bits, levels_to_drop,
                           order)
    polys <- schemelet_convert_ckks_to_rlwe(ctxt_after, pow2(q_bits))

    if (!step) {
      ## Subtract the digit and switch the modulus from Q to Q / digit.
      ctxt_bfv <- ctxt_bfv - polys
      schemelet_mod_switch(ctxt_bfv, pow2(q_bits - p_digit_bits), pow2(q_bits))
      q_bits <- q_bits - p_digit_bits
      p_input <- p_input / p_digit
      post_scaling_bits <- post_scaling_bits + p_digit_bits
    } else {
      ctxt_bfv <- polys
    }

    go <- q_bits > bigq_bits
    if (step || (checkeq2 && !go)) {
      computed <- schemelet_decrypt_coeff(ctxt_bfv, pow2(q_bits), p_input,
                                          keys@secret, ep, num_slots_ckks,
                                          num_slots)
    }

    if (checkgt2 && !go && !step) {
      if (!binary_lut) coeff <- coeff_step
      scale_thi <- scale_step_thi
      step <- TRUE
      go <- TRUE
      d_mod <- get_multiplicative_depth_by_coeff_vector(coeff_mod, TRUE)
      d_step <- get_multiplicative_depth_by_coeff_vector(coeff_step, TRUE)
      if (length(coeff_mod) > 4L && d_mod > d_step) {
        levels_to_drop <- d_mod - d_step
      }
    }
  }
  max(abs(exact - computed) %% p_orig)
}

if (at_home) {
  expect_equal(multi_precision_sign(60L, 4096, 2, 46L, 35L, 1, 1, 1L, 32L, 2048L), 0)
  expect_equal(multi_precision_sign(60L, 4096, 16, 48L, 40L, 32, 8, 1L, 64L, 2048L), 0)
  expect_equal(multi_precision_sign(80L, 2^32, 256, 71L, 47L, 256, 32, 1L, 64L,
                                    2048L), 0)
}
