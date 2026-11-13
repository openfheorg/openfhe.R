## OPENFHE PYTHON SOURCE: examples/pke/tckks-interactive-mp-bootstrapping-Chebyshev.py
##
## @openfhe-python: tckks-interactive-mp-bootstrapping-Chebyshev.py [FULL]
##
## Interactive 3-party bootstrapping of a threshold-CKKS ciphertext that
## carries the result of a Chebyshev series evaluation.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

check_approximate_equality <- function(a, b, vector_size, epsilon) {
  i <- seq_len(vector_size)
  expect_true(all(abs(a[i] - b[i]) <= epsilon))
}

tckks_collective_boot <- function(scale_tech) {
  supported <- c(ScalingTechnique$FIXEDMANUAL, ScalingTechnique$FIXEDAUTO,
                 ScalingTechnique$FLEXIBLEAUTO, ScalingTechnique$FLEXIBLEAUTOEXT)
  if (!(scale_tech %in% supported)) {
    stop("ERROR: Scaling technique is not supported!")
  }

  parameters <- CKKSParams()

  secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
  set_secret_key_dist(parameters, secret_key_dist)

  set_security_level(parameters, SecurityLevel$HEStd_128_classic)

  dcrt_bits <- 50L
  first_mod <- 60L

  set_scaling_mod_size(parameters, dcrt_bits)
  set_scaling_technique(parameters, scale_tech)
  set_first_mod_size(parameters, first_mod)

  multiplicative_depth <- 10L
  set_multiplicative_depth(parameters, multiplicative_depth)
  set_key_switch_technique(parameters, KeySwitchTechnique$HYBRID)

  batch_size <- 16L
  set_batch_size(parameters, batch_size)

  compression_level <- CompressionLevel$COMPACT  # or CompressionLevel$SLACK
  set_interactive_boot_compression_level(parameters, compression_level)

  crypto_context <- gen_crypto_context(parameters)
  enable_feature(crypto_context, Feature$PKE)
  enable_feature(crypto_context, Feature$KEYSWITCH)
  enable_feature(crypto_context, Feature$LEVELEDSHE)
  enable_feature(crypto_context, Feature$ADVANCEDSHE)
  enable_feature(crypto_context, Feature$MULTIPARTY)

  ring_dim <- ring_dimension(crypto_context)
  expect_equal(ring_dim, 32768L)

  ## Round 1 (party A)
  kp1 <- key_gen(crypto_context)

  ## Generate evalmult key part for A
  eval_mult_key <- key_switch_gen(crypto_context, kp1@secret, kp1@secret)

  ## Generate evalsum key part for A
  eval_sum_key_gen(crypto_context, kp1@secret)
  eval_sum_keys <- get_eval_sum_key_map(get_key_tag(kp1@secret))

  ## Round 2 (party B)
  kp2 <- multiparty_key_gen(crypto_context, kp1@public)
  eval_mult_key2 <- multi_key_switch_gen(crypto_context, kp2@secret,
                                         kp2@secret, eval_mult_key)
  eval_mult_ab <- multi_add_eval_keys(crypto_context, eval_mult_key,
                                      eval_mult_key2, get_key_tag(kp2@public))
  eval_mult_bab <- multi_mult_eval_key(crypto_context, kp2@secret,
                                       eval_mult_ab, get_key_tag(kp2@public))
  eval_sum_keys_b <- multi_eval_sum_key_gen(crypto_context, kp2@secret,
                                            eval_sum_keys,
                                            get_key_tag(kp2@public))
  eval_sum_keys_join <- multi_add_eval_sum_keys(crypto_context, eval_sum_keys,
                                                eval_sum_keys_b,
                                                get_key_tag(kp2@public))
  insert_eval_sum_key(eval_sum_keys_join)
  eval_mult_aab <- multi_mult_eval_key(crypto_context, kp1@secret,
                                       eval_mult_ab, get_key_tag(kp2@public))
  eval_mult_final <- multi_add_eval_mult_keys(crypto_context, eval_mult_aab,
                                              eval_mult_bab,
                                              get_key_tag(eval_mult_ab))
  insert_eval_mult_key(list(eval_mult_final))

  ## Round 3 (party C) - Lead Party (who encrypts and finalizes the
  ## bootstrapping protocol)
  kp3 <- multiparty_key_gen(crypto_context, kp2@public)
  eval_mult_key3 <- multi_key_switch_gen(crypto_context, kp3@secret,
                                         kp3@secret, eval_mult_key)
  eval_mult_abc <- multi_add_eval_keys(crypto_context, eval_mult_ab,
                                       eval_mult_key3, get_key_tag(kp3@public))
  eval_mult_babc <- multi_mult_eval_key(crypto_context, kp2@secret,
                                        eval_mult_abc, get_key_tag(kp3@public))
  eval_mult_aabc <- multi_mult_eval_key(crypto_context, kp1@secret,
                                        eval_mult_abc, get_key_tag(kp3@public))
  eval_mult_cabc <- multi_mult_eval_key(crypto_context, kp3@secret,
                                        eval_mult_abc, get_key_tag(kp3@public))
  eval_mult_ababc <- multi_add_eval_mult_keys(crypto_context, eval_mult_babc,
                                              eval_mult_aabc,
                                              get_key_tag(eval_mult_babc))
  eval_mult_final2 <- multi_add_eval_mult_keys(crypto_context, eval_mult_ababc,
                                               eval_mult_cabc,
                                               get_key_tag(eval_mult_cabc))
  insert_eval_mult_key(list(eval_mult_final2))

  expect_true(is_good(kp1))
  expect_true(is_good(kp2))
  expect_true(is_good(kp3))

  ## END of Key Generation

  input <- c(-4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0)

  ## Chebyshev coefficients
  coefficients <- c(1.0, 0.558971, 0.0, -0.0943712, 0.0, 0.0215023, 0.0,
                    -0.00505348, 0.0, 0.00119324, 0.0, -0.000281928, 0.0,
                    0.0000664347, 0.0, -0.0000148709)
  ## Input range
  a <- -4
  b <- 4

  pt1 <- make_ckks_packed_plaintext(crypto_context, input)
  encoded_length <- length(input)

  ct1 <- encrypt(kp3@public, pt1, cc = crypto_context)

  ct1 <- eval_chebyshev(ct1, coefficients, a, b)

  # ── Interactive bootstrapping starts ──────────────────

  ct1 <- int_mp_boot_adjust_scale(ct1)

  ## Leading party (party B) generates a Common Random Poly (crp) at max
  ## coefficient modulus (QNumPrime). a is sampled at random uniformly
  ## from R_{Q}
  crp <- int_mp_boot_random_element_gen(crypto_context, kp3@public)
  ## Each party generates its own shares: maskedDecryptionShare and
  ## reEncryptionShare
  ## (h_{0,i}, h_{1,i}) = (masked decryption share, re-encryption share)

  ## extract c1 - element-wise
  c1 <- clone(ct1)
  remove_element(c1, 1L)
  shares_pair0 <- int_mp_boot_decrypt(kp1@secret, c1, crp)
  shares_pair1 <- int_mp_boot_decrypt(kp2@secret, c1, crp)
  shares_pair2 <- int_mp_boot_decrypt(kp3@secret, c1, crp)

  shares_pair_vec <- list(shares_pair0, shares_pair1, shares_pair2)

  ## Party B finalizes the protocol by aggregating the shares and
  ## reEncrypting the results
  aggregated_shares_pair <- int_mp_boot_add(crypto_context, shares_pair_vec)
  ciphertext_output <- int_mp_boot_encrypt(kp3@public, aggregated_shares_pair,
                                           crp, ct1)

  # ── Interactive bootstrapping ends ────────────────────
  ## The refreshed ciphertext has more levels than the one that went in.
  expect_true(get_level(ciphertext_output) < get_level(ct1))

  ## distributed decryption

  ciphertext_partial1 <- multiparty_decrypt_main(crypto_context, kp1@secret,
                                                 list(ciphertext_output))
  ciphertext_partial2 <- multiparty_decrypt_main(crypto_context, kp2@secret,
                                                 list(ciphertext_output))
  ciphertext_partial3 <- multiparty_decrypt_lead(crypto_context, kp3@secret,
                                                 list(ciphertext_output))

  plaintext_multiparty <- multiparty_decrypt_fusion(
    crypto_context, ciphertext_partial1[[1L]], ciphertext_partial2[[1L]],
    ciphertext_partial3[[1L]])
  set_length(plaintext_multiparty, encoded_length)

  ## Ground truth result
  result <- c(0.0179885, 0.0474289, 0.119205, 0.268936, 0.5, 0.731064,
              0.880795, 0.952571, 0.982011)
  plaintext_result <- make_ckks_packed_plaintext(crypto_context, result)

  check_approximate_equality(get_complex_packed_value(plaintext_result),
                             get_complex_packed_value(plaintext_multiparty),
                             encoded_length, 0.0001)
  ## The values agree far more closely than the example asks for.
  expect_equal(Re(get_complex_packed_value(plaintext_multiparty)), result,
               tolerance = 1e-5)
}

## Same test with different rescaling techniques in CKKS
tckks_collective_boot(ScalingTechnique$FIXEDMANUAL)
tckks_collective_boot(ScalingTechnique$FIXEDAUTO)
if (get_native_int() != 128L) {
  tckks_collective_boot(ScalingTechnique$FLEXIBLEAUTO)
  tckks_collective_boot(ScalingTechnique$FLEXIBLEAUTOEXT)
}

clear_fhe_state()
