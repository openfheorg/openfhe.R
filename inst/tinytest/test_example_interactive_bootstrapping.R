## OPENFHE PYTHON SOURCE: examples/pke/interactive-bootstrapping.py
##
## @openfhe-python: interactive-bootstrapping.py [FULL]
##
## 2-party interactive bootstrapping in threshold CKKS: on a fresh
## ciphertext, and between two Chebyshev series evaluations.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

## The Chebyshev series with coefficients `co` on [a, b], in the clear.
chebyshev_in_clear <- function(co, x, a, b) {
  u <- (2 * x - (a + b)) / (b - a)
  k <- seq_along(co) - 1L
  vapply(u, function(z) sum(co * cos(k * acos(z))) - co[1] / 2, numeric(1))
}

## The interactive bootstrapping of the example, for the server holding
## kp1 and the client holding kp2.
interactive_bootstrap <- function(ciphertext1, kp1, kp2) {
  ## under the hood it reduces to two towers
  ciphertext1 <- int_boot_adjust_scale(ciphertext1)
  expect_true(S7::S7_inherits(ciphertext1, Ciphertext))

  ## masked decryption on the server: c0 = b + a*s0
  ciphertext_output1 <- int_boot_decrypt(kp1@secret, ciphertext1)
  expect_true(S7::S7_inherits(ciphertext_output1, Ciphertext))

  ciphertext2 <- clone(ciphertext1)
  set_elements(ciphertext2, list(get_elements(ciphertext2)[[2L]]))

  ## masked decryption on the client: c1 = a*s1
  ciphertext_output2 <- int_boot_decrypt(kp2@secret, ciphertext2)
  expect_true(S7::S7_inherits(ciphertext_output2, Ciphertext))

  ## Encryption of masked decryption c1 = a*s1
  ciphertext_output2 <- int_boot_encrypt(kp2@public, ciphertext_output2)
  expect_true(S7::S7_inherits(ciphertext_output2, Ciphertext))

  ## Compute Enc(c1) + c0
  ciphertext_output <- int_boot_add(ciphertext_output2, ciphertext_output1)
  expect_true(S7::S7_inherits(ciphertext_output, Ciphertext))
  ciphertext_output
}

distributed_decrypt <- function(cc, ciphertext_output, kp1, kp2, len) {
  ciphertext_partial1 <- multiparty_decrypt_lead(cc, kp1@secret,
                                                 list(ciphertext_output))
  ciphertext_partial2 <- multiparty_decrypt_main(cc, kp2@secret,
                                                 list(ciphertext_output))
  plaintext_multiparty <- multiparty_decrypt_fusion(
    cc, ciphertext_partial1[[1L]], ciphertext_partial2[[1L]])
  set_length(plaintext_multiparty, len)
  plaintext_multiparty
}

# ══ ThresholdFHE ═════════════════════════════════════════
threshold_fhe <- function(scale_tech) {
  parameters <- CKKSParams()
  ## 1 extra level needs to be added for FIXED* modes (2 extra levels for
  ## FLEXIBLE* modes) to the multiplicative depth to support 2-party
  ## interactive bootstrapping
  depth <- 7L
  set_multiplicative_depth(parameters, depth)
  set_scaling_mod_size(parameters, 50L)
  set_batch_size(parameters, 16L)
  set_scaling_technique(parameters, scale_tech)

  cc <- gen_crypto_context(parameters)
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)
  enable_feature(cc, Feature$MULTIPARTY)

  ## Key generation. Round 1 (party A)
  kp1 <- key_gen(cc)
  eval_mult_key <- key_switch_gen(cc, kp1@secret, kp1@secret)
  expect_true(S7::S7_inherits(eval_mult_key, EvalKey))

  ## Round 2 (party B): the joint public key for (s_a + s_b)
  kp2 <- multiparty_key_gen(cc, kp1@public)

  input <- c(-0.9, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 0.9)

  ## This plaintext only has 3 RNS limbs, the minimum needed to perform
  ## 2-party interactive bootstrapping for FLEXIBLEAUTO
  plaintext1 <- make_ckks_packed_plaintext(cc, input, 1L, depth - 2L)
  ciphertext1 <- encrypt(kp2@public, plaintext1, cc = cc)

  ciphertext_output <- interactive_bootstrap(ciphertext1, kp1, kp2)
  ## The refreshed ciphertext has more levels than the one that went in.
  expect_true(get_level(ciphertext_output) < get_level(ciphertext1))

  ## distributed decryption
  plaintext_multiparty <- distributed_decrypt(cc, ciphertext_output, kp1, kp2,
                                              length(input))

  ## Original plaintext
  expect_equal(Re(get_complex_packed_value(plaintext1))[seq_along(input)],
               input)
  ## Result after bootstrapping
  expect_equal(Re(get_complex_packed_value(plaintext_multiparty)), input,
               tolerance = 1e-6)
}

# ══ Chebyshev ════════════════════════════════════════════
chebyshev <- function(scale_tech) {
  parameters <- CKKSParams()
  ## 1 extra level needs to be added for FIXED* modes (2 extra levels for
  ## FLEXIBLE* modes) to the multiplicative depth to support 2-party
  ## interactive bootstrapping
  set_multiplicative_depth(parameters, 8L)
  set_scaling_mod_size(parameters, 50L)
  set_batch_size(parameters, 16L)
  set_scaling_technique(parameters, scale_tech)

  cc <- gen_crypto_context(parameters)
  ## enable features that you wish to use
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)
  enable_feature(cc, Feature$MULTIPARTY)

  ## Key generation. Round 1 (party A)
  kp1 <- key_gen(cc)

  eval_mult_key <- key_switch_gen(cc, kp1@secret, kp1@secret)
  eval_sum_key_gen(cc, kp1@secret)
  eval_sum_keys <- get_eval_sum_key_map(get_key_tag(kp1@secret))

  ## Round 2 (party B): the joint public key for (s_a + s_b)
  kp2 <- multiparty_key_gen(cc, kp1@public)

  eval_mult_key2 <- multi_key_switch_gen(cc, kp2@secret, kp2@secret,
                                         eval_mult_key)

  ## Joint evaluation multiplication key for (s_a + s_b)
  eval_mult_ab <- multi_add_eval_keys(cc, eval_mult_key, eval_mult_key2,
                                      get_key_tag(kp2@public))

  ## transformed into s_b*(s_a + s_b)
  eval_mult_bab <- multi_mult_eval_key(cc, kp2@secret, eval_mult_ab,
                                       get_key_tag(kp2@public))

  eval_sum_keys_b <- multi_eval_sum_key_gen(cc, kp2@secret, eval_sum_keys,
                                            get_key_tag(kp2@public))

  ## Joint evaluation summation key for (s_a + s_b)
  eval_sum_keys_join <- multi_add_eval_sum_keys(cc, eval_sum_keys,
                                                eval_sum_keys_b,
                                                get_key_tag(kp2@public))

  insert_eval_sum_key(eval_sum_keys_join)

  ## Round 3 (party A): the joint key (s_a + s_b) is transformed into
  ## s_a*(s_a + s_b)
  eval_mult_aab <- multi_mult_eval_key(cc, kp1@secret, eval_mult_ab,
                                       get_key_tag(kp2@public))

  ## The final evaluation multiplication key for (s_a + s_b)*(s_a + s_b)
  eval_mult_final <- multi_add_eval_mult_keys(cc, eval_mult_aab, eval_mult_bab,
                                              get_key_tag(eval_mult_ab))

  insert_eval_mult_key(list(eval_mult_final))

  input <- c(-4.0, -3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0, 4.0)

  coefficients <- c(1.0, 0.558971, 0.0, -0.0943712, 0.0, 0.0215023, 0.0,
                    -0.00505348, 0.0, 0.00119324, 0.0, -0.000281928, 0.0,
                    0.0000664347, 0.0, -0.0000148709)

  a <- -4
  b <- 4

  plaintext1 <- make_ckks_packed_plaintext(cc, input)

  ciphertext1 <- encrypt(kp2@public, plaintext1, cc = cc)

  ## The Chebyshev series interpolation requires 6 levels
  ciphertext1 <- eval_chebyshev(ciphertext1, coefficients, a, b)

  ciphertext_output <- interactive_bootstrap(ciphertext1, kp1, kp2)

  ## distributed decryption
  plaintext_multiparty <- distributed_decrypt(cc, ciphertext_output, kp1, kp2,
                                              length(input))

  ## The series in the clear is the example's "Plaintext result"; it
  ## approximates the logistic function, its "Exact result".
  plaintext_result <- chebyshev_in_clear(coefficients, input, a, b)
  expect_equal(plaintext_result,
               c(0.0179885, 0.0474289, 0.119205, 0.268936, 0.5, 0.731064,
                 0.880795, 0.952571, 0.982011), tolerance = 1e-5)
  expect_equal(plaintext_result, 1 / (1 + exp(-input)), tolerance = 1e-4)
  ## Ciphertext result
  first_round <- get_real_packed_value(plaintext_multiparty)
  expect_equal(first_round, plaintext_result, tolerance = 1e-5)

  ## Another round of Chebyshev interpolation after interactive
  ## bootstrapping
  ciphertext_output <- eval_chebyshev(ciphertext_output, coefficients, a, b)

  ## distributed decryption
  plaintext_multiparty <- distributed_decrypt(cc, ciphertext_output, kp1, kp2,
                                              length(input))

  plaintext_result2 <- chebyshev_in_clear(coefficients, plaintext_result, a, b)
  expect_equal(plaintext_result2,
               c(0.504497, 0.511855, 0.529766, 0.566832, 0.622459, 0.675039,
                 0.706987, 0.721632, 0.727508), tolerance = 1e-5)
  ## Ciphertext result
  expect_equal(get_real_packed_value(plaintext_multiparty), plaintext_result2,
               tolerance = 1e-5)
}

## The scaling technique can be changed to FIXEDMANUAL, FIXEDAUTO, or
## FLEXIBLEAUTOEXT (128-bit CKKS supports only the FIXED* scaling
## techniques)
scale_tech <- if (get_native_int() == 128L) {
  ScalingTechnique$FIXEDAUTO
} else {
  ScalingTechnique$FLEXIBLEAUTO
}
threshold_fhe(scale_tech)
chebyshev(scale_tech)

clear_fhe_state()
