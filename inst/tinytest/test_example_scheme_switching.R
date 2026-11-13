## OPENFHE PYTHON SOURCE: examples/pke/scheme-switching.py
##
## @openfhe-python: scheme-switching.py [FULL]
##
## Switching between CKKS and FHEW in both directions, and the
## computations built on it: floor, an arbitrary function, a polynomial
## evaluated in CKKS between two switches, comparison, and four
## variants of minimum and maximum with their indices. The ten
## functions of the Python main() run with the example's parameters.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: long-running example (runs on CI and at_home)")
}

# ── Helper functions ─────────────────────────────────────
reduce_rotation <- function(index, slots) (slots + index %% slots) %% slots

## Rotates the vector by the index amount (positive: left).
rotate_int <- function(a, index) {
  slots <- length(a)
  if (index < 0 || index > slots) index <- reduce_rotation(index, slots)
  if (index == 0) return(a)
  c(a[(index + 1L):slots], a[seq_len(index)])
}

enable_features <- function(cc, features) {
  for (f in features) enable_feature(cc, f)
  invisible(cc)
}

## Decrypts and returns the first n real values.
real_values <- function(cc, secret_key, ct, n) {
  pt <- decrypt(ct, secret_key, cc = cc)
  set_length(pt, n)
  get_real_packed_value(pt)
}

fhew_decrypt <- function(cc_lwe, sk, cts, p) {
  vapply(cts, function(ct) bin_decrypt(cc_lwe, sk, ct, p), integer(1))
}

## The FHEW parameters the example prints.
check_fhew <- function(cc_lwe) {
  expect_true(get_n(cc_lwe) > 0)
  expect_true(as.numeric(get_q(cc_lwe)) > 0)
}

# ══ 1. SwitchCKKSToFHEW ══════════════════════════════════
## Switching a packed ciphertext from CKKS to multiple FHEW ciphertexts.
switch_ckks_to_fhew <- function() {
  # Step 1: Setup CryptoContext for CKKS

  # Specify main parameters
  mult_depth <- 3L
  first_mod_size <- 60L
  scale_mod_size <- 50L
  ring_dim <- 4096L
  sl <- SecurityLevel$HEStd_NotSet
  sl_bin <- BinFHEParamSet$TOY
  log_q_cc_lwe <- 25L
  slots <- 16L  # sparsely-packed
  batch_size <- slots

  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_first_mod_size(parameters, first_mod_size)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_scaling_technique(parameters, ScalingTechnique$FIXEDMANUAL)
  set_security_level(parameters, sl)
  set_ring_dim(parameters, ring_dim)
  set_batch_size(parameters, batch_size)

  cc <- gen_crypto_context(parameters)

  # Enable the features that you wish to use
  enable_features(cc, c(Feature$PKE, Feature$KEYSWITCH, Feature$LEVELEDSHE,
                        Feature$SCHEMESWITCH))
  expect_equal(ring_dimension(cc), ring_dim)

  # Generate encryption keys
  keys <- key_gen(cc)

  # Step 2: Prepare the FHEW cryptocontext and keys for FHEW and scheme
  # switching
  params <- SchSwchParams()
  set_security_level_ckks(params, sl)
  set_security_level_fhew(params, sl_bin)
  set_ctxt_mod_size_fhew_large_prec(params, log_q_cc_lwe)
  set_num_slots_ckks(params, slots)

  private_key_fhew <- eval_ckks_to_fhew_setup(cc, params)
  cc_lwe <- get_bin_cc_for_scheme_switch(cc)

  eval_ckks_to_fhew_key_gen(cc, keys, private_key_fhew)
  check_fhew(cc_lwe)

  # Compute the scaling factor to decrypt correctly in FHEW; the LWE mod
  # switch is performed on the ciphertext at the last level
  p_lwe1 <- get_max_plaintext_space(cc_lwe)  # Small precision
  modulus_lwe <- 2^log_q_cc_lwe
  beta <- get_beta(cc_lwe)
  p_lwe2 <- modulus_lwe / (2 * beta)  # Large precision

  scale1 <- 1 / p_lwe1
  scale2 <- 1 / p_lwe2

  # Perform the precomputation for switching
  eval_ckks_to_fhew_precompute(cc, scale1)

  # Step 3: Encoding and encryption of inputs
  # Inputs
  x1 <- c(0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 2.0, 3.0, 4.0,
          5.0, 6.0)
  x2 <- c(0.0, 271.1, 30000.0, p_lwe2 - 2)
  encoded_length1 <- length(x1)
  encoded_length2 <- length(x2)

  # Encoding as plaintexts
  ptxt1 <- make_ckks_packed_plaintext(cc, x1, 1L, 0L)
  ptxt2 <- make_ckks_packed_plaintext(cc, x2, 1L, 0L)

  # Encrypt the encoded vectors
  c1 <- encrypt(keys@public, ptxt1, cc = cc)
  c2 <- encrypt(keys@public, ptxt2, cc = cc)

  # Step 4: Scheme Switching from CKKS to FHEW
  c_temp <- eval_ckks_to_fhew(c1, encoded_length1)
  expect_equal(length(c_temp), encoded_length1)

  # Decrypting switched ciphertext with small precision (plaintext
  # modulus p_lwe1)
  x1_int <- round(x1) %% p_lwe1

  set_length(ptxt1, encoded_length1)
  expect_equal(get_real_packed_value(ptxt1), x1, tolerance = 1e-8)
  # FHEW Decryption. A value halfway between two whole numbers may land
  # on either.
  got1 <- fhew_decrypt(cc_lwe, private_key_fhew, c_temp, p_lwe1)
  halfway <- abs(x1 - floor(x1) - 0.5) < 1e-9
  expect_equal(got1[!halfway], x1_int[!halfway])
  expect_true(all(got1[halfway] == floor(x1[halfway]) %% p_lwe1 |
                  got1[halfway] == ceiling(x1[halfway]) %% p_lwe1))

  # B: Second scheme switching case

  # Perform the precomputation for switching
  eval_ckks_to_fhew_precompute(cc, scale2)

  # Transform the ciphertext from CKKS to FHEW (only for the number of
  # inputs given)
  c_temp2 <- eval_ckks_to_fhew(c2, encoded_length2)
  expect_equal(length(c_temp2), encoded_length2)

  # Decrypting switched ciphertext with large precision (plaintext
  # modulus p_lwe2)
  set_length(ptxt2, encoded_length2)
  expect_equal(get_real_packed_value(ptxt2), x2, tolerance = 1e-8)
  # FHEW Decryption
  x2_int <- round(x2) %% p_lwe2
  got2 <- fhew_decrypt(cc_lwe, private_key_fhew, c_temp2, p_lwe2)
  expect_equal(got2, x2_int)

  # C: Decompose the FHEW ciphertexts in smaller digits
  # Generate the bootstrapping keys (refresh and switching keys)
  bin_bt_key_gen(cc_lwe, private_key_fhew)

  for (j in seq_along(c_temp2)) {
    # Decompose the large ciphertext into small ciphertexts that fit in q
    decomp <- eval_decomp(cc_lwe, c_temp2[[j]])

    # Decryption
    p <- get_max_plaintext_space(cc_lwe)
    digits <- numeric(length(decomp))
    for (i in seq_along(decomp)) {
      if (i == length(decomp)) {
        # The last digit should be up to P / p^floor(log_p(P))
        p <- trunc(p_lwe2 / p_lwe1^floor(log(p_lwe2) / log(p_lwe1)))
      }
      digits[i] <- bin_decrypt(cc_lwe, private_key_fhew, decomp[[i]], p)
    }
    # The digits, least significant first, give the value back.
    expect_equal(sum(digits * p_lwe1^(seq_along(digits) - 1L)), x2_int[j],
                 info = paste("decomposition of value", j))
  }
}

# ══ 2. SwitchFHEWtoCKKS ══════════════════════════════════
## Output precision is only wrt the operations in CKKS after switching
## back.
switch_fhew_to_ckks <- function() {
  # Step 1: Setup CryptoContext for CKKS to be switched into

  # A. Specify main parameters
  sc_tech <- ScalingTechnique$FIXEDAUTO
  # for r = 3 in FHEWtoCKKS, Chebyshev max depth allowed is 9, 1 more
  # level for postscaling
  mult_depth <- 3L + 9L + 1L
  if (sc_tech == ScalingTechnique$FLEXIBLEAUTOEXT) mult_depth <- mult_depth + 1L
  scale_mod_size <- 50L
  ring_dim <- 8192L
  # If this is not HEStd_NotSet, ensure ring_dim is compatible
  sl <- SecurityLevel$HEStd_NotSet
  log_q_cc_lwe <- 28L

  slots <- 16L  # sparsely-packed
  batch_size <- slots

  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_scaling_technique(parameters, sc_tech)
  set_security_level(parameters, sl)
  set_ring_dim(parameters, ring_dim)
  set_batch_size(parameters, batch_size)

  cc <- gen_crypto_context(parameters)

  # Enable the features that you wish to use
  enable_features(cc, c(Feature$PKE, Feature$KEYSWITCH, Feature$LEVELEDSHE,
                        Feature$ADVANCEDSHE, Feature$SCHEMESWITCH))
  expect_equal(ring_dimension(cc), ring_dim)

  # Generate encryption keys
  keys <- key_gen(cc)

  # Step 2: Prepare the FHEW cryptocontext and keys for FHEW and scheme
  # switching
  cc_lwe <- bin_fhe_context(BinFHEParamSet$TOY, arb_func = FALSE,
                            log_q = log_q_cc_lwe, n = 0L,
                            method = BinFHEMethod$GINX,
                            time_optimization = FALSE)

  # LWE private key
  lwesk <- bin_key_gen(cc_lwe)
  check_fhew(cc_lwe)

  # Step 3. Precompute the necessary keys and information for switching
  # from FHEW to CKKS
  eval_fhew_to_ckks_setup(cc, cc_lwe, slots, log_q_cc_lwe)

  eval_fhew_to_ckks_key_gen(cc, keys, lwesk)

  # Step 4: Encoding and encryption of inputs
  # For correct CKKS decryption, the messages have to be much smaller
  # than the FHEW plaintext modulus!
  p_lwe1 <- get_max_plaintext_space(cc_lwe)  # Small precision
  p_lwe2 <- 256  # Medium precision
  modulus_lwe <- 2^log_q_cc_lwe
  beta <- get_beta(cc_lwe)
  p_lwe3 <- trunc(modulus_lwe / (2 * beta))  # Large precision
  x1 <- c(1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0)
  x2 <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
  if (length(x1) < slots) {
    zeros <- numeric(slots - length(x1))
    x1 <- c(x1, zeros)
    x2 <- c(x2, zeros)
  }

  # Encrypt
  # Encrypted under small plaintext modulus p = 4 and ciphertext modulus:
  ctxts_lwe1 <- lapply(x1, function(m) bin_encrypt(cc_lwe, lwesk, m))
  # Encrypted under larger plaintext modulus p = 16 but small ciphertext
  # modulus:
  ctxts_lwe2 <- lapply(x1, function(m) {
    bin_encrypt(cc_lwe, lwesk, m, BinFHEOutput$FRESH, p_lwe1)
  })
  # Encrypted under larger plaintext modulus and large ciphertext modulus:
  ctxts_lwe3 <- lapply(x2, function(m) {
    bin_encrypt(cc_lwe, lwesk, m, BinFHEOutput$FRESH, p_lwe2, modulus_lwe)
  })
  # Encrypted under large plaintext modulus and large ciphertext modulus:
  ctxts_lwe4 <- lapply(x2, function(m) {
    bin_encrypt(cc_lwe, lwesk, m, BinFHEOutput$FRESH, p_lwe3, modulus_lwe)
  })

  # The ciphertext moduli the example prints
  q <- as.numeric(get_q(cc_lwe))
  expect_equal(as.numeric(get_modulus(ctxts_lwe1[[1L]])), q)
  expect_equal(as.numeric(get_modulus(ctxts_lwe2[[1L]])), q)
  expect_equal(as.numeric(get_modulus(ctxts_lwe3[[1L]])), modulus_lwe)
  expect_equal(as.numeric(get_modulus(ctxts_lwe4[[1L]])), modulus_lwe)

  # Step 5. Perform the scheme switching
  c_temp <- eval_fhew_to_ckks(cc, ctxts_lwe1, slots, slots)

  # Step 6. Decrypt
  # Switched CKKS decryption 1: x1 encrypted under p = 4
  expect_equal(round(real_values(cc, keys@secret, c_temp, slots)), x1)

  # Step 5'. Perform the scheme switching
  c_temp <- eval_fhew_to_ckks(cc, ctxts_lwe2, slots, slots, p_lwe1, 0, p_lwe1)

  # Step 6'. Decrypt
  # Switched CKKS decryption 2: x1 encrypted under p = p_lwe1
  expect_equal(round(real_values(cc, keys@secret, c_temp, slots)), x1)

  # Step 5''. Perform the scheme switching
  c_temp <- eval_fhew_to_ckks(cc, ctxts_lwe3, slots, slots, p_lwe2, 0, p_lwe2)

  # Step 6''. Decrypt
  # Switched CKKS decryption 3: x2 encrypted under p = p_lwe2
  expect_equal(round(real_values(cc, keys@secret, c_temp, slots)), x2)

  # Step 5'''. Perform the scheme switching
  c_temp2 <- eval_fhew_to_ckks(cc, ctxts_lwe4, slots, slots, p_lwe3, 0, p_lwe3)

  # Step 6'''. Decrypt
  # Switched CKKS decryption 4: x2 encrypted under p = p_lwe3
  expect_equal(round(real_values(cc, keys@secret, c_temp2, slots)), x2)
}

# ══ 3. FloorViaSchemeSwitching ═══════════════════════════
## Output precision is only wrt the operations in CKKS after switching
## back.
floor_via_scheme_switching <- function() {
  # Step 1: Setup CryptoContext for CKKS
  sc_tech <- ScalingTechnique$FIXEDAUTO
  # for r = 3 in FHEWtoCKKS, Chebyshev max depth allowed is 9, 1 more
  # level for postscaling
  mult_depth <- 3L + 9L + 1L
  if (sc_tech == ScalingTechnique$FLEXIBLEAUTOEXT) mult_depth <- mult_depth + 1L

  scale_mod_size <- 50L
  ring_dim <- 8192L
  sl <- SecurityLevel$HEStd_NotSet
  sl_bin <- BinFHEParamSet$TOY
  log_q_cc_lwe <- 23L
  slots <- 16L  # sparsely-packed
  batch_size <- slots

  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_scaling_technique(parameters, sc_tech)
  set_security_level(parameters, sl)
  set_ring_dim(parameters, ring_dim)
  set_batch_size(parameters, batch_size)

  cc <- gen_crypto_context(parameters)

  # Enable the features that you wish to use
  enable_features(cc, c(Feature$PKE, Feature$KEYSWITCH, Feature$LEVELEDSHE,
                        Feature$ADVANCEDSHE, Feature$SCHEMESWITCH))
  expect_equal(ring_dimension(cc), ring_dim)

  # Generate encryption keys.
  keys <- key_gen(cc)

  # Step 2: Prepare the FHEW cryptocontext and keys for FHEW and scheme
  # switching
  params <- SchSwchParams()
  set_security_level_ckks(params, sl)
  set_security_level_fhew(params, sl_bin)
  set_ctxt_mod_size_fhew_large_prec(params, log_q_cc_lwe)
  set_num_slots_ckks(params, slots)
  set_num_values(params, slots)

  private_key_fhew <- eval_scheme_switching_setup(cc, params)
  cc_lwe <- get_bin_cc_for_scheme_switch(cc)

  eval_scheme_switching_key_gen(cc, keys, private_key_fhew)

  # Generate bootstrapping key for EvalFloor
  bin_bt_key_gen(cc_lwe, private_key_fhew)
  check_fhew(cc_lwe)

  # Set the scaling factor to be able to decrypt; the LWE mod switch is
  # performed on the ciphertext at the last level
  modulus_ckks_from <- get_modulus_ckks(cc)
  expect_true(grepl("^[0-9]+$", modulus_ckks_from))

  modulus_lwe <- 2^log_q_cc_lwe
  beta <- get_beta(cc_lwe)
  p_lwe <- trunc(modulus_lwe / (2 * beta))  # Large precision

  scale_cf <- 1.0 / p_lwe

  eval_ckks_to_fhew_precompute(cc, scale_cf)

  # Step 3: Encoding and encryption of inputs
  # Inputs
  x1 <- c(0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0,
          13.0, 14.0, 15.0)

  # Encoding as plaintexts
  ptxt1 <- make_ckks_packed_plaintext(cc, x1, 1L, 0L, NULL)

  # Encrypt the encoded vectors
  c1 <- encrypt(keys@public, ptxt1, cc = cc)

  # Step 4: Scheme switching from CKKS to FHEW
  c_temp <- eval_ckks_to_fhew(c1, slots)

  # Step 5: Evaluate the floor function
  bits <- 2L

  c_floor <- lapply(c_temp, function(ct) eval_floor(cc_lwe, ct, bits))

  # Expected result for EvalFloor with 2 bits
  expected <- trunc(get_real_packed_value(ptxt1)[seq_len(slots)]) %/% 2^bits
  expect_equal(expected, x1 %/% 4)

  # FHEW decryption with p = p_lwe / (1 << bits)
  p_floor <- fhew_decrypt(cc_lwe, private_key_fhew, c_floor, p_lwe %/% 2^bits)
  expect_equal(p_floor, expected)

  # Step 6: Scheme switching from FHEW to CKKS
  c_temp2 <- eval_fhew_to_ckks(cc, c_floor, slots, slots, p_lwe %/% 2^bits, 0,
                               p_lwe / 2^bits)

  # Switched floor decryption
  expect_equal(real_values(cc, keys@secret, c_temp2, slots), expected,
               tolerance = 0.05)
}

# ══ 4. FuncViaSchemeSwitching ════════════════════════════
## Output precision is only wrt the operations in CKKS after switching
## back.
func_via_scheme_switching <- function() {
  # Step 1: Setup CryptoContext for CKKS
  mult_depth <- 9L + 3L + 2L  # 1 for CKKS to FHEW, 14 for FHEW to CKKS
  scale_mod_size <- 50L
  ring_dim <- 2048L
  sl <- SecurityLevel$HEStd_NotSet
  sl_bin <- BinFHEParamSet$TOY
  log_q_cc_lwe <- 25L
  slots <- 8L  # sparsely-packed
  batch_size <- slots

  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_scaling_technique(parameters, ScalingTechnique$FIXEDMANUAL)
  set_security_level(parameters, sl)
  set_ring_dim(parameters, ring_dim)
  set_batch_size(parameters, batch_size)

  cc <- gen_crypto_context(parameters)

  # Enable the features that you wish to use
  enable_features(cc, c(Feature$PKE, Feature$KEYSWITCH, Feature$LEVELEDSHE,
                        Feature$ADVANCEDSHE, Feature$SCHEMESWITCH))
  expect_equal(ring_dimension(cc), ring_dim)

  # Generate encryption keys.
  keys <- key_gen(cc)

  # Step 2: Prepare the FHEW cryptocontext and keys for FHEW and scheme
  # switching
  params <- SchSwchParams()
  set_security_level_ckks(params, sl)
  set_security_level_fhew(params, sl_bin)
  set_arbitrary_function_evaluation(params, TRUE)
  set_ctxt_mod_size_fhew_large_prec(params, log_q_cc_lwe)
  set_num_slots_ckks(params, slots)
  set_num_values(params, slots)

  private_key_fhew <- eval_scheme_switching_setup(cc, params)
  cc_lwe <- get_bin_cc_for_scheme_switch(cc)

  eval_scheme_switching_key_gen(cc, keys, private_key_fhew)

  # Generate the bootstrapping keys for EvalFunc in FHEW
  bin_bt_key_gen(cc_lwe, private_key_fhew)
  check_fhew(cc_lwe)

  # Set the scaling factor to be able to decrypt; the LWE mod switch is
  # performed on the ciphertext at the last level
  # Small precision because GenerateLUTviaFunction needs p < q
  p_lwe <- get_max_plaintext_space(cc_lwe)
  scale_cf <- 1.0 / p_lwe

  eval_ckks_to_fhew_precompute(cc, scale_cf)

  # Step 3: Initialize the function
  # Initialize Function f(x) = x^3 + 2x^2 + 1 % p
  fp <- function(m, p1) {
    h <- m - p1 / 2
    ifelse(m < p1,
           (m * m * m + 2 * m * m + 1) %% p1,
           (h * h * h + 2 * h * h + 1) %% p1)
  }

  # Generate LUT from function f(x)
  lut <- generate_lut_via_function(fp, p_lwe)
  expect_equal(length(lut), p_lwe)

  # Step 4: Encoding and encryption of inputs
  # Inputs
  x1 <- c(0.0, 0.3, 2.0, 4.0, 5.0, 6.0, 7.0, 8.0)

  # Encoding as plaintexts
  ptxt1 <- make_ckks_packed_plaintext(cc, x1, 1L, 0L, NULL)

  # Encrypt the encoded vectors
  c1 <- encrypt(keys@public, ptxt1, cc = cc)

  # Step 5: Scheme switching from CKKS to FHEW
  c_temp <- eval_ckks_to_fhew(c1, slots)

  # FHEW decryption
  expect_equal(fhew_decrypt(cc_lwe, private_key_fhew, c_temp, p_lwe),
               round(x1) %% p_lwe)

  # Step 6: Evaluate the function
  c_func <- lapply(c_temp, function(ct) eval_func(cc_lwe, ct, lut))

  # Expected result of the function mod p
  expected <- fp(trunc(x1) %% p_lwe, p_lwe)

  # FHEW decryption mod p
  p_func <- fhew_decrypt(cc_lwe, private_key_fhew, c_func, p_lwe)
  expect_equal(p_func, expected)

  # Step 7: Scheme switching from FHEW to CKKS
  c_temp2 <- eval_fhew_to_ckks(cc, c_func, slots, slots, p_lwe, 0, p_lwe)

  # Switched decryption modulus_LWE mod p works only for messages << p:
  # a message m comes back as p / (2 pi) * sin(2 pi m / p).
  dec <- real_values(cc, keys@secret, c_temp2, slots)
  expect_equal(dec, p_lwe / (2 * pi) * sin(2 * pi * expected / p_lwe),
               tolerance = 0.05)

  # Transform through arcsine
  c_temp2 <- eval_fhew_to_ckks(cc, c_func, slots, slots, 4L, 0, 2)

  dec <- real_values(cc, keys@secret, c_temp2, slots)

  # Arcsin(switched result) * p/2pi gives the correct result if messages
  # are < p/4
  x <- pmax(pmin(dec, 1.0), -1.0)
  recovered <- asin(x) * p_lwe / (2 * pi)
  small <- expected <= p_lwe / 4
  expect_true(any(small))
  expect_equal(recovered[small], expected[small], tolerance = 0.05)
}

# ══ 5. PolyViaSchemeSwitching ════════════════════════════
poly_via_scheme_switching <- function() {
  # Step 1: Setup CryptoContext for CKKS to be switched into

  # A. Specify main parameters
  sc_tech <- ScalingTechnique$FIXEDAUTO
  # for r = 3 in FHEWtoCKKS, Chebyshev max depth allowed is 9, 1 more
  # level for postscaling, 3 levels for functionality
  mult_depth <- 3L + 9L + 1L + 2L
  if (sc_tech == ScalingTechnique$FLEXIBLEAUTOEXT) mult_depth <- mult_depth + 1L
  scale_mod_size <- 50L
  ring_dim <- 2048L
  sl <- SecurityLevel$HEStd_NotSet
  sl_bin <- BinFHEParamSet$TOY
  log_q_cc_lwe <- 25L

  slots <- 16L  # sparsely-packed
  batch_size <- slots

  # Create encryption parameters
  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_scaling_technique(parameters, sc_tech)
  set_security_level(parameters, sl)
  set_ring_dim(parameters, ring_dim)
  set_batch_size(parameters, batch_size)

  cc <- gen_crypto_context(parameters)

  # Enable the features that you wish to use
  enable_features(cc, c(Feature$PKE, Feature$KEYSWITCH, Feature$LEVELEDSHE,
                        Feature$ADVANCEDSHE, Feature$SCHEMESWITCH))
  expect_equal(ring_dimension(cc), ring_dim)

  # Generate encryption keys
  keys <- key_gen(cc)

  # Step 2: Prepare the FHEW cryptocontext and keys for FHEW and scheme
  # switching
  params <- SchSwchParams()
  set_security_level_ckks(params, sl)
  set_security_level_fhew(params, sl_bin)
  set_ctxt_mod_size_fhew_large_prec(params, log_q_cc_lwe)
  set_num_slots_ckks(params, slots)
  set_num_values(params, slots)

  private_key_fhew <- eval_scheme_switching_setup(cc, params)
  cc_lwe <- get_bin_cc_for_scheme_switch(cc)

  eval_scheme_switching_key_gen(cc, keys, private_key_fhew)
  check_fhew(cc_lwe)

  p_lwe1 <- get_max_plaintext_space(cc_lwe)  # Small precision
  modulus_lwe <- 2^log_q_cc_lwe
  beta <- get_beta(cc_lwe)
  p_lwe2 <- trunc(modulus_lwe / (2 * beta))  # Large precision

  scale1 <- 1.0 / p_lwe1
  scale2 <- 1.0 / p_lwe2

  # Generate keys for the CKKS intermediate computation
  eval_mult_key_gen(cc, keys@secret)
  eval_rotate_key_gen(cc, keys@secret, c(1L, 2L))

  # Step 4: Encoding and encryption of inputs
  # For correct CKKS decryption, the messages have to be much smaller
  # than the FHEW plaintext modulus!
  # Inputs
  x1 <- c(1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0)
  x2 <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)

  x1_rot <- rotate_int(x1, 1L) + x1
  x1_int <- round(0.25 * x1_rot * x1_rot) %% p_lwe1

  x2_rot <- rotate_int(x2, 2L) + x2
  x2_int <- round(0.25 * x2_rot * x2_rot) %% p_lwe2

  # Encrypt
  # encrypted under small plaintext modulus p = 4 and ciphertext modulus
  ctxts_lwe1 <- lapply(x1, function(m) bin_encrypt(cc_lwe, private_key_fhew, m))
  # encrypted under large plaintext modulus and large ciphertext modulus
  ctxts_lwe2 <- lapply(x2, function(m) {
    bin_encrypt(cc_lwe, private_key_fhew, m, BinFHEOutput$FRESH, p_lwe2,
                modulus_lwe)
  })

  # The ciphertext moduli the example prints
  expect_equal(as.numeric(get_modulus(ctxts_lwe1[[1L]])),
               as.numeric(get_q(cc_lwe)))
  expect_equal(as.numeric(get_modulus(ctxts_lwe2[[1L]])), modulus_lwe)

  # Step 5. Perform the scheme switching
  c_temp <- eval_fhew_to_ckks(cc, ctxts_lwe1, slots, slots)

  # Step 6. Perform the desired computation in CKKS:
  # 0.25 * (x1 + rot(x1, 1))^2
  c_poly <- eval_add(c_temp, eval_rotate(c_temp, 1L))
  c_poly <- eval_mult(eval_mult(c_poly, c_poly), 0.25)

  # Perform the precomputation for switching back to CKKS
  eval_ckks_to_fhew_precompute(cc, scale1)

  # Transform the ciphertext from CKKS to FHEW
  c_temp1 <- eval_ckks_to_fhew(c_poly, slots)

  # FHEW decryption with plaintext modulus p_lwe1
  expect_equal(fhew_decrypt(cc_lwe, private_key_fhew, c_temp1, p_lwe1), x1_int)

  # Step 5'. Perform the scheme switching
  c_temp <- eval_fhew_to_ckks(cc, ctxts_lwe2, slots, slots, p_lwe2, 0, p_lwe2)

  # Step 6'. Perform the desired computation in CKKS:
  # 0.25 * (x2 + rot(x2, 2))^2
  c_poly <- eval_add(c_temp, eval_rotate(c_temp, 2L))
  c_poly <- eval_mult(eval_mult(c_poly, c_poly), 0.25)

  # Perform the precomputation for switching back to CKKS
  eval_ckks_to_fhew_precompute(cc, scale2)

  # Transform the ciphertext from CKKS to FHEW
  c_temp2 <- eval_ckks_to_fhew(c_poly, slots)

  # FHEW decryption with plaintext modulus p_lwe2. The switched inputs
  # carry noise that the squaring multiplies by up to 13, so a large
  # value can come out one off.
  got2 <- fhew_decrypt(cc_lwe, private_key_fhew, c_temp2, p_lwe2)
  expect_true(all(abs(got2 - x2_int) <= 1))
  expect_true(sum(got2 != x2_int) <= 2L)
}

# ══ 6. ComparisonViaSchemeSwitching ══════════════════════
## Output precision is only wrt the operations in CKKS after switching
## back.
comparison_via_scheme_switching <- function() {
  # Step 1: Setup CryptoContext for CKKS
  sc_tech <- ScalingTechnique$FIXEDAUTO
  mult_depth <- 17L
  if (sc_tech == ScalingTechnique$FLEXIBLEAUTOEXT) mult_depth <- mult_depth + 1L

  scale_mod_size <- 50L
  first_mod_size <- 60L
  ring_dim <- 8192L
  sl <- SecurityLevel$HEStd_NotSet
  sl_bin <- BinFHEParamSet$TOY
  log_q_cc_lwe <- 25L
  slots <- 16L  # sparsely-packed
  batch_size <- slots

  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_first_mod_size(parameters, first_mod_size)
  set_scaling_technique(parameters, sc_tech)
  set_security_level(parameters, sl)
  set_ring_dim(parameters, ring_dim)
  set_batch_size(parameters, batch_size)
  set_secret_key_dist(parameters, SecretKeyDist$UNIFORM_TERNARY)
  set_key_switch_technique(parameters, KeySwitchTechnique$HYBRID)
  set_num_large_digits(parameters, 3L)

  cc <- gen_crypto_context(parameters)

  # Enable the features that you wish to use
  enable_features(cc, c(Feature$PKE, Feature$KEYSWITCH, Feature$LEVELEDSHE,
                        Feature$ADVANCEDSHE, Feature$SCHEMESWITCH))
  expect_equal(ring_dimension(cc), ring_dim)

  # Generate encryption keys.
  keys <- key_gen(cc)

  # Step 2: Prepare the FHEW cryptocontext and keys for FHEW and scheme
  # switching
  params <- SchSwchParams()
  set_security_level_ckks(params, sl)
  set_security_level_fhew(params, sl_bin)
  set_ctxt_mod_size_fhew_large_prec(params, log_q_cc_lwe)
  set_num_slots_ckks(params, slots)
  set_num_values(params, slots)

  private_key_fhew <- eval_scheme_switching_setup(cc, params)
  cc_lwe <- get_bin_cc_for_scheme_switch(cc)

  eval_scheme_switching_key_gen(cc, keys, private_key_fhew)
  check_fhew(cc_lwe)

  # Set the scaling factor to be able to decrypt; the LWE mod switch is
  # performed on the ciphertext at the last level
  p_lwe1 <- get_max_plaintext_space(cc_lwe)  # Small precision
  modulus_lwe <- 2^log_q_cc_lwe
  beta <- get_beta(cc_lwe)
  p_lwe2 <- trunc(modulus_lwe / (2 * beta))  # Large precision

  scale_sign_fhew <- 1.0
  eval_compare_switch_precompute(cc, p_lwe2, scale_sign_fhew)

  # Step 3: Encoding and encryption of inputs
  x1 <- c(0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0,
          13.0, 14.0, 15.0)
  x2 <- rep(5.25, slots)

  ptxt1 <- make_ckks_packed_plaintext(cc, x1, 1L, 0L, NULL, slots)
  ptxt2 <- make_ckks_packed_plaintext(cc, x2, 1L, 0L, NULL, slots)

  c1 <- encrypt(keys@public, ptxt1, cc = cc)
  c2 <- encrypt(keys@public, ptxt2, cc = cc)

  c_diff <- eval_sub(c1, c2)

  # Step 4: CKKS to FHEW switching and sign evaluation to test correctness
  # Difference of inputs
  p_diff <- real_values(cc, keys@secret, c_diff, slots)
  expect_equal(p_diff, x1 - x2, tolerance = 1e-8)

  # Expected sign result from CKKS
  eps <- 0.0001
  sign_ckks <- as.integer(round(p_diff / eps) * eps < 0)
  expect_equal(sign_ckks, as.integer(x1 < x2))

  lwe_ciphertexts <- eval_ckks_to_fhew(c_diff, slots)

  # FHEW decryption with plaintext modulus p_lwe2: the differences
  # rounded to whole numbers
  expect_equal(fhew_decrypt(cc_lwe, private_key_fhew, lwe_ciphertexts, p_lwe2),
               round(x1 - x2) %% p_lwe2)

  # Expected sign result in FHEW with plaintext modulus p_lwe2 and scale
  # scale_sign_fhew
  sign_fhew <- (round(p_diff * scale_sign_fhew) %% p_lwe2) - p_lwe2 / 2.0 >= 0

  # Obtained sign result in FHEW
  lwe_sign <- lapply(lwe_ciphertexts, function(ct) eval_sign(cc_lwe, ct))
  expect_equal(fhew_decrypt(cc_lwe, private_key_fhew, lwe_sign, 2L),
               as.integer(sign_fhew))

  # Step 5'': Direct comparison via CKKS->FHEW->CKKS
  c_result <- eval_compare_scheme_switching(c1, c2, slots, slots)
  # Decrypted switched result
  expect_equal(real_values(cc, keys@secret, c_result, slots),
               as.numeric(sign_fhew), tolerance = 0.01)
}

## The inputs of the four minimum and maximum functions.
argmin_inputs <- c(-1.125, -1.12, 5.0, 6.0, -1.0, 2.0, 8.0, -1.0, 9.0, 10.0,
                   11.0, 12.0, 13.0, 14.0, 15.25, 15.30)

## Checks a result of the minimum or maximum functions: the value and
## its location, which is one-hot encoded (the example's oneHot = True,
## the default of SchSwchParams).
check_extremum <- function(cc, secret_key, result, value, location,
                           num_values, tol) {
  expect_equal(length(result), 2L)
  expect_true(abs(real_values(cc, secret_key, result[[1L]], 1L) - value) < tol)
  indicator <- real_values(cc, secret_key, result[[2L]], num_values)
  expect_equal(round(indicator), as.numeric(seq_len(num_values) == location))
}

# ══ 7. ArgminViaSchemeSwitching ══════════════════════════
## Output precision is only wrt the operations in CKKS after switching
## back.
argmin_via_scheme_switching <- function() {
  # Step 1: Setup CryptoContext for CKKS
  scale_mod_size <- 50L
  first_mod_size <- 60L
  ring_dim <- 8192L
  sl <- SecurityLevel$HEStd_NotSet
  sl_bin <- BinFHEParamSet$TOY
  log_q_cc_lwe <- 25L
  # Change to FALSE if the output should not be one-hot encoded
  one_hot <- TRUE

  slots <- 16L  # sparsely-packed
  batch_size <- slots
  num_values <- 16L
  sc_tech <- ScalingTechnique$FIXEDMANUAL
  # 13 for FHEW to CKKS, log2(num_values) for argmin
  mult_depth <- 9L + 3L + 1L + as.integer(log2(num_values))
  if (sc_tech == ScalingTechnique$FLEXIBLEAUTOEXT) mult_depth <- mult_depth + 1L

  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_first_mod_size(parameters, first_mod_size)
  set_scaling_technique(parameters, sc_tech)
  set_security_level(parameters, sl)
  set_ring_dim(parameters, ring_dim)
  set_batch_size(parameters, batch_size)

  cc <- gen_crypto_context(parameters)

  # Enable the features that you wish to use
  enable_features(cc, c(Feature$PKE, Feature$KEYSWITCH, Feature$LEVELEDSHE,
                        Feature$ADVANCEDSHE, Feature$SCHEMESWITCH))
  expect_equal(ring_dimension(cc), ring_dim)

  # Generate encryption keys
  keys <- key_gen(cc)

  # Step 2: Prepare the FHEW cryptocontext and keys for FHEW and scheme
  # switching
  params <- SchSwchParams()
  set_security_level_ckks(params, sl)
  set_security_level_fhew(params, sl_bin)
  set_ctxt_mod_size_fhew_large_prec(params, log_q_cc_lwe)
  set_num_slots_ckks(params, slots)
  set_num_values(params, num_values)
  set_compute_argmin(params, TRUE)

  private_key_fhew <- eval_scheme_switching_setup(cc, params)
  cc_lwe <- get_bin_cc_for_scheme_switch(cc)

  eval_scheme_switching_key_gen(cc, keys, private_key_fhew)
  check_fhew(cc_lwe)

  # Scale the inputs to ensure their difference is correctly represented
  # after switching to FHEW
  scale_sign <- 512
  modulus_lwe <- 2^log_q_cc_lwe
  beta <- get_beta(cc_lwe)
  p_lwe <- trunc(modulus_lwe / (2 * beta))  # Large precision

  eval_compare_switch_precompute(cc, p_lwe, scale_sign)

  # Step 3: Encoding and encryption of inputs
  x1 <- argmin_inputs

  ptxt1 <- make_ckks_packed_plaintext(cc, x1)

  c1 <- encrypt(keys@public, ptxt1, cc = cc)

  # Step 4: Argmin evaluation
  result <- eval_min_scheme_switching(c1, keys@public, num_values, slots)
  # Minimum value and argmin indicator vector
  check_extremum(cc, keys@secret, result, min(x1), which.min(x1),
                 num_values, 0.01)

  result <- eval_max_scheme_switching(c1, keys@public, num_values, slots)
  # Maximum value and argmax indicator vector
  check_extremum(cc, keys@secret, result, max(x1), which.max(x1),
                 num_values, 0.01)
}

# ══ 8. ArgminViaSchemeSwitchingAlt ═══════════════════════
## Output precision is only wrt the operations in CKKS after switching
## back.
argmin_via_scheme_switching_alt <- function() {
  # Step 1: Setup CryptoContext for CKKS
  scale_mod_size <- 50L
  first_mod_size <- 60L
  ring_dim <- 8192L
  sl <- SecurityLevel$HEStd_NotSet
  sl_bin <- BinFHEParamSet$TOY
  log_q_cc_lwe <- 25L
  one_hot <- TRUE

  slots <- 16L
  batch_size <- slots
  num_values <- 16L
  sc_tech <- ScalingTechnique$FIXEDAUTO
  mult_depth <- 9L + 3L + 1L + as.integer(log2(num_values))

  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_first_mod_size(parameters, first_mod_size)
  set_scaling_technique(parameters, sc_tech)
  set_security_level(parameters, sl)
  set_ring_dim(parameters, ring_dim)
  set_batch_size(parameters, batch_size)

  cc <- gen_crypto_context(parameters)

  enable_features(cc, c(Feature$PKE, Feature$KEYSWITCH, Feature$LEVELEDSHE,
                        Feature$ADVANCEDSHE, Feature$SCHEMESWITCH))
  expect_equal(ring_dimension(cc), ring_dim)

  keys <- key_gen(cc)

  # Step 2: Prepare the FHEW cryptocontext and keys for FHEW and scheme
  # switching
  params <- SchSwchParams()
  set_security_level_ckks(params, sl)
  set_security_level_fhew(params, sl_bin)
  set_ctxt_mod_size_fhew_large_prec(params, log_q_cc_lwe)
  set_num_slots_ckks(params, slots)
  set_num_values(params, num_values)
  set_compute_argmin(params, TRUE)
  set_use_alt_argmin(params, TRUE)

  private_key_fhew <- eval_scheme_switching_setup(cc, params)
  cc_lwe <- get_bin_cc_for_scheme_switch(cc)

  eval_scheme_switching_key_gen(cc, keys, private_key_fhew)
  check_fhew(cc_lwe)

  scale_sign <- 512
  modulus_lwe <- 2^log_q_cc_lwe
  beta <- get_beta(cc_lwe)
  p_lwe <- trunc(modulus_lwe / (2 * beta))

  eval_compare_switch_precompute(cc, p_lwe, scale_sign)

  # Step 3: Encoding and encryption of inputs

  # Inputs
  x1 <- argmin_inputs

  # Encoding as plaintexts
  ptxt1 <- make_ckks_packed_plaintext(cc, x1)  # Only if we set batchsize

  # Encrypt the encoded vectors
  c1 <- encrypt(keys@public, ptxt1, cc = cc)

  # Step 4: Argmin evaluation
  result <- eval_min_scheme_switching_alt(c1, keys@public, num_values, slots)
  # Minimum value and argmin indicator vector
  check_extremum(cc, keys@secret, result, min(x1), which.min(x1),
                 num_values, 0.01)

  result <- eval_max_scheme_switching_alt(c1, keys@public, num_values, slots)
  # Maximum value and argmax indicator vector
  check_extremum(cc, keys@secret, result, max(x1), which.max(x1),
                 num_values, 0.01)
}

# ══ 9. ArgminViaSchemeSwitchingUnit ══════════════════════
## Output precision is only wrt the operations in CKKS after switching
## back.
argmin_via_scheme_switching_unit <- function() {
  # Step 1: Setup CryptoContext for CKKS
  scale_mod_size <- 50L
  first_mod_size <- 60L
  ring_dim <- 8192L
  sl <- SecurityLevel$HEStd_NotSet
  sl_bin <- BinFHEParamSet$TOY
  log_q_cc_lwe <- 25L
  one_hot <- TRUE

  slots <- 32L  # sparsely-packed
  batch_size <- slots
  num_values <- 32L
  # 1 for CKKS to FHEW, 13 for FHEW to CKKS, log2(num_values) for argmin
  mult_depth <- 9L + 3L + 1L + as.integer(log2(num_values))

  parameters <- CKKSParams()
  if (get_native_int() != 128L) {
    sc_tech <- ScalingTechnique$FLEXIBLEAUTOEXT
    mult_depth <- mult_depth + 1L
    set_scaling_technique(parameters, sc_tech)
  }

  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_first_mod_size(parameters, first_mod_size)
  set_security_level(parameters, sl)
  set_ring_dim(parameters, ring_dim)
  set_batch_size(parameters, batch_size)

  cc <- gen_crypto_context(parameters)

  # Enable the features that you wish to use
  enable_features(cc, c(Feature$PKE, Feature$KEYSWITCH, Feature$LEVELEDSHE,
                        Feature$ADVANCEDSHE, Feature$SCHEMESWITCH, Feature$FHE))
  expect_equal(ring_dimension(cc), ring_dim)

  # Generate encryption keys.
  keys <- key_gen(cc)

  # Step 2: Prepare the FHEW cryptocontext and keys for FHEW and scheme
  # switching
  params <- SchSwchParams()
  set_security_level_ckks(params, sl)
  set_security_level_fhew(params, sl_bin)
  set_ctxt_mod_size_fhew_large_prec(params, log_q_cc_lwe)
  set_num_slots_ckks(params, slots)
  set_num_values(params, num_values)
  set_compute_argmin(params, TRUE)

  private_key_fhew <- eval_scheme_switching_setup(cc, params)
  cc_lwe <- get_bin_cc_for_scheme_switch(cc)

  eval_scheme_switching_key_gen(cc, keys, private_key_fhew)
  check_fhew(cc_lwe)

  # Here we assume the message does not need scaling, as they are in the
  # unit circle.
  eval_compare_switch_precompute(cc, 1L, 1)

  # Step 3: Encoding and encryption of inputs

  # Inputs
  x1 <- argmin_inputs
  if (length(x1) < slots) x1 <- c(x1, numeric(slots - length(x1)))

  p <- 2^(first_mod_size - scale_mod_size - 1L)
  x1 <- x1 / (2 * p)  # Input scaled

  # Encoding as plaintexts
  ptxt1 <- make_ckks_packed_plaintext(cc, x1)

  # Encrypt the encoded vectors
  c1 <- encrypt(keys@public, ptxt1, cc = cc)

  # Step 4: Argmin evaluation
  result <- eval_min_scheme_switching(c1, keys@public, num_values, slots)
  # Minimum value and argmin indicator vector
  check_extremum(cc, keys@secret, result, min(x1), which.min(x1),
                 num_values, 1e-6)

  result <- eval_max_scheme_switching(c1, keys@public, num_values, slots)
  # Maximum value and argmax indicator vector
  check_extremum(cc, keys@secret, result, max(x1), which.max(x1),
                 num_values, 1e-6)
}

# ══ 10. ArgminViaSchemeSwitchingAltUnit ══════════════════
## Output precision is only wrt the operations in CKKS after switching
## back.
argmin_via_scheme_switching_alt_unit <- function() {
  # Step 1: Setup CryptoContext for CKKS
  scale_mod_size <- 50L
  first_mod_size <- 60L
  ring_dim <- 8192L
  sl <- SecurityLevel$HEStd_NotSet
  sl_bin <- BinFHEParamSet$TOY
  log_q_cc_lwe <- 25L
  one_hot <- TRUE
  # alternative mode of argmin which has fewer rotation keys and does
  # more operations in FHEW than in CKKS: set below

  slots <- 32L  # sparsely-packed
  batch_size <- slots
  num_values <- 32L
  # 1 for CKKS to FHEW, 13 for FHEW to CKKS, log2(num_values) for argmin
  mult_depth <- 9L + 3L + 1L + as.integer(log2(num_values))

  parameters <- CKKSParams()
  if (get_native_int() != 128L) {
    sc_tech <- ScalingTechnique$FLEXIBLEAUTOEXT
    mult_depth <- mult_depth + 1L
    set_scaling_technique(parameters, sc_tech)
  }

  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_first_mod_size(parameters, first_mod_size)
  set_security_level(parameters, sl)
  set_ring_dim(parameters, ring_dim)
  set_batch_size(parameters, batch_size)

  cc <- gen_crypto_context(parameters)

  # Enable the features that you wish to use
  enable_features(cc, c(Feature$PKE, Feature$KEYSWITCH, Feature$LEVELEDSHE,
                        Feature$ADVANCEDSHE, Feature$SCHEMESWITCH, Feature$FHE))
  expect_equal(ring_dimension(cc), ring_dim)

  # Generate encryption keys.
  keys <- key_gen(cc)

  # Step 2: Prepare the FHEW cryptocontext and keys for FHEW and scheme
  # switching
  params <- SchSwchParams()
  set_security_level_ckks(params, sl)
  set_security_level_fhew(params, sl_bin)
  set_ctxt_mod_size_fhew_large_prec(params, log_q_cc_lwe)
  set_num_slots_ckks(params, slots)
  set_num_values(params, num_values)
  set_compute_argmin(params, TRUE)
  set_use_alt_argmin(params, TRUE)

  private_key_fhew <- eval_scheme_switching_setup(cc, params)
  cc_lwe <- get_bin_cc_for_scheme_switch(cc)

  eval_scheme_switching_key_gen(cc, keys, private_key_fhew)
  check_fhew(cc_lwe)

  # Here we assume the message does not need scaling, as they are in the
  # unit circle.
  eval_compare_switch_precompute(cc, 1L, 1)

  # Step 3: Encoding and encryption of inputs
  # Inputs
  x1 <- argmin_inputs
  if (length(x1) < slots) x1 <- c(x1, numeric(slots - length(x1)))

  p <- 2^(first_mod_size - scale_mod_size - 1L)
  x1 <- x1 / (2 * p)  # Input scaled

  # Encoding as plaintexts
  ptxt1 <- make_ckks_packed_plaintext(cc, x1)

  # Encrypt the encoded vectors
  c1 <- encrypt(keys@public, ptxt1, cc = cc)

  # Step 4: Argmin evaluation
  result <- eval_min_scheme_switching_alt(c1, keys@public, num_values, slots)
  # Minimum value and argmin indicator vector
  check_extremum(cc, keys@secret, result, min(x1), which.min(x1),
                 num_values, 1e-6)

  result <- eval_max_scheme_switching_alt(c1, keys@public, num_values, slots)
  # Maximum value and argmax indicator vector
  check_extremum(cc, keys@secret, result, max(x1), which.max(x1),
                 num_values, 1e-6)
}

# ── main ─────────────────────────────────────────────────
switch_ckks_to_fhew()
switch_fhew_to_ckks()
floor_via_scheme_switching()
func_via_scheme_switching()
poly_via_scheme_switching()
comparison_via_scheme_switching()
argmin_via_scheme_switching()
argmin_via_scheme_switching_alt()
argmin_via_scheme_switching_unit()
argmin_via_scheme_switching_alt_unit()

clear_fhe_state()
