## OPENFHE PYTHON SOURCE: examples/pke/threshold-fhe.py
##
## @openfhe-python: threshold-fhe.py [FULL]
##
## Threshold FHE: three parties adding in BGV, then two parties with
## joint multiplication and summation keys in BFV and in CKKS. Each
## result is decrypted by all the parties together and checked against
## the same computation in the clear.
library(openfhe.R)

## The parameters the example prints.
check_parameters <- function(cc, plaintext_modulus = NULL) {
  if (!is.null(plaintext_modulus)) {
    expect_equal(as.numeric(get_plaintext_modulus(cc)), plaintext_modulus)
  }
  expect_equal(get_cyclotomic_order(cc) / 2, ring_dimension(cc))
  expect_true(log2(as.numeric(get_modulus(cc))) > 0)
}

# ══ BGVrns - Additive ════════════════════════════════════
run_bgvrns_additive <- function() {
  parameters <- BGVParams()
  set_plaintext_modulus(parameters, 65537)
  set_multiplicative_depth(parameters, 0L)
  set_key_switch_technique(parameters, KeySwitchTechnique$BV)
  set_digit_size(parameters, 10L)

  # NOISE_FLOODING_MULTIPARTY adds extra noise to the ciphertext before
  # decrypting and is most secure mode of threshold FHE for BFV and BGV.
  set_multiparty_mode(parameters, MultipartyMode$NOISE_FLOODING_MULTIPARTY)

  cc <- gen_crypto_context(parameters)
  # Enable Features you wish to use
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)
  enable_feature(cc, Feature$MULTIPARTY)

  # Set-up of parameters
  check_parameters(cc, 65537)

  # Perform Key Generation Operation

  # generate the public key for first share
  kp1 <- key_gen(cc)
  # generate the public key for two shares
  kp2 <- multiparty_key_gen(cc, kp1@public)
  # generate the public key for all three secret shares
  kp3 <- multiparty_key_gen(cc, kp2@public)

  expect_true(is_good(kp1))
  expect_true(is_good(kp2))
  expect_true(is_good(kp3))

  # Encode source data
  vector_of_ints1 <- c(1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0)
  vector_of_ints2 <- c(1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0)
  vector_of_ints3 <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 0)

  plaintext1 <- make_packed_plaintext(cc, vector_of_ints1)
  plaintext2 <- make_packed_plaintext(cc, vector_of_ints2)
  plaintext3 <- make_packed_plaintext(cc, vector_of_ints3)

  # Encryption
  ciphertext1 <- encrypt(kp3@public, plaintext1, cc = cc)
  ciphertext2 <- encrypt(kp3@public, plaintext2, cc = cc)
  ciphertext3 <- encrypt(kp3@public, plaintext3, cc = cc)

  # EvalAdd Operation on Re-Encrypted Data
  ciphertext_add12 <- eval_add(ciphertext1, ciphertext2)
  ciphertext_add123 <- eval_add(ciphertext_add12, ciphertext3)

  # Decryption after Accumulation Operation on Encrypted Data with Multiparty

  # partial decryption by first party
  ciphertext_partial1 <- multiparty_decrypt_lead(cc, kp1@secret,
                                                 list(ciphertext_add123))
  # partial decryption by second party
  ciphertext_partial2 <- multiparty_decrypt_main(cc, kp2@secret,
                                                 list(ciphertext_add123))
  # partial decryption by third party
  ciphertext_partial3 <- multiparty_decrypt_main(cc, kp3@secret,
                                                 list(ciphertext_add123))

  # partial decryption are combined together
  plaintext_multiparty_new <- multiparty_decrypt_fusion(
    cc, ciphertext_partial1[[1L]], ciphertext_partial2[[1L]],
    ciphertext_partial3[[1L]])

  # Original Plaintext
  expect_equal(as.numeric(get_packed_value(plaintext1)), vector_of_ints1)
  expect_equal(as.numeric(get_packed_value(plaintext2)), vector_of_ints2)
  expect_equal(as.numeric(get_packed_value(plaintext3)), vector_of_ints3)

  set_length(plaintext_multiparty_new, get_length(plaintext1))

  # Resulting Fused Plaintext adding 3 ciphertexts
  expect_equal(as.numeric(get_packed_value(plaintext_multiparty_new)),
               vector_of_ints1 + vector_of_ints2 + vector_of_ints3)
}

## The three rounds of joint key generation of the BFV and the CKKS
## parts: a joint public key, a joint multiplication key and joint
## summation keys for (s_a + s_b).
joint_key_gen <- function(cc) {
  # Round 1 (party A)
  kp1 <- key_gen(cc)

  # Generate evalmult key part for A
  eval_mult_key <- key_switch_gen(cc, kp1@secret, kp1@secret)

  # Generate evalsum key part for A
  eval_sum_key_gen(cc, kp1@secret)
  eval_sum_keys <- get_eval_sum_key_map(get_key_tag(kp1@secret))

  # Round 2 (party B)

  # Joint public key for (s_a + s_b) is generated
  kp2 <- multiparty_key_gen(cc, kp1@public)
  tag2 <- get_key_tag(kp2@public)

  eval_mult_key2 <- multi_key_switch_gen(cc, kp2@secret, kp2@secret,
                                         eval_mult_key)

  # Joint evaluation multiplication key for (s_a + s_b) is generated
  eval_mult_ab <- multi_add_eval_keys(cc, eval_mult_key, eval_mult_key2, tag2)

  # Joint evaluation multiplication key (s_a + s_b) is transformed into
  # s_b*(s_a + s_b)
  eval_mult_bab <- multi_mult_eval_key(cc, kp2@secret, eval_mult_ab, tag2)

  eval_sum_keys_b <- multi_eval_sum_key_gen(cc, kp2@secret, eval_sum_keys, tag2)

  # Joint evaluation summation key for (s_a + s_b) is generated
  eval_sum_keys_join <- multi_add_eval_sum_keys(cc, eval_sum_keys,
                                                eval_sum_keys_b, tag2)

  insert_eval_sum_key(eval_sum_keys_join)

  # Round 3 (party A)

  # Joint key (s_a + s_b) is transformed into s_a*(s_a + s_b)
  eval_mult_aab <- multi_mult_eval_key(cc, kp1@secret, eval_mult_ab, tag2)

  # Computing the final evaluation multiplication key for
  # (s_a + s_b)*(s_a + s_b)
  eval_mult_final <- multi_add_eval_mult_keys(cc, eval_mult_aab, eval_mult_bab,
                                              get_key_tag(eval_mult_ab))

  insert_eval_mult_key(list(eval_mult_final))

  list(kp1 = kp1, kp2 = kp2)
}

## Decryption by the two parties: the lead, the other, and the fusion.
two_party_decrypt <- function(cc, kp1, kp2, ciphertext) {
  ciphertext_partial1 <- multiparty_decrypt_lead(cc, kp1@secret,
                                                 list(ciphertext))
  ciphertext_partial2 <- multiparty_decrypt_main(cc, kp2@secret,
                                                 list(ciphertext))
  multiparty_decrypt_fusion(cc, ciphertext_partial1[[1L]],
                            ciphertext_partial2[[1L]])
}

# ══ BFVrns ═══════════════════════════════════════════════
run_bfvrns <- function() {
  batch_size <- 16L

  parameters <- BFVParams()
  set_plaintext_modulus(parameters, 65537)
  set_batch_size(parameters, batch_size)
  set_multiplicative_depth(parameters, 2L)
  # NOISE_FLOODING_MULTIPARTY adds extra noise to the ciphertext before
  # decrypting and is most secure mode of threshold FHE for BFV and BGV.
  set_multiparty_mode(parameters, MultipartyMode$NOISE_FLOODING_MULTIPARTY)

  cc <- gen_crypto_context(parameters)
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)
  enable_feature(cc, Feature$MULTIPARTY)

  # Set-up of parameters
  check_parameters(cc, 65537)

  # Perform Key Generation Operation
  kps <- joint_key_gen(cc)
  kp1 <- kps$kp1
  kp2 <- kps$kp2

  # Encode source data
  vector_of_ints1 <- c(1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 0)
  vector_of_ints2 <- c(1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0)
  vector_of_ints3 <- c(2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 0)

  plaintext1 <- make_packed_plaintext(cc, vector_of_ints1)
  plaintext2 <- make_packed_plaintext(cc, vector_of_ints2)
  plaintext3 <- make_packed_plaintext(cc, vector_of_ints3)

  # Encryption
  ciphertext1 <- encrypt(kp2@public, plaintext1, cc = cc)
  ciphertext2 <- encrypt(kp2@public, plaintext2, cc = cc)
  ciphertext3 <- encrypt(kp2@public, plaintext3, cc = cc)

  # Homomorphic Operations
  ciphertext_add12 <- eval_add(ciphertext1, ciphertext2)
  ciphertext_add123 <- eval_add(ciphertext_add12, ciphertext3)

  ciphertext_mult <- eval_mult(ciphertext1, ciphertext3)
  ciphertext_eval_sum <- eval_sum(ciphertext3, batch_size)

  # Decryption after Accumulation Operation on Encrypted Data with Multiparty
  plaintext_multiparty_new <- two_party_decrypt(cc, kp1, kp2, ciphertext_add123)

  # Original Plaintext
  expect_equal(as.numeric(get_packed_value(plaintext1)), vector_of_ints1)
  expect_equal(as.numeric(get_packed_value(plaintext2)), vector_of_ints2)
  expect_equal(as.numeric(get_packed_value(plaintext3)), vector_of_ints3)

  n <- get_length(plaintext1)
  set_length(plaintext_multiparty_new, n)

  # Resulting Fused Plaintext
  expect_equal(as.numeric(get_packed_value(plaintext_multiparty_new)),
               vector_of_ints1 + vector_of_ints2 + vector_of_ints3)

  plaintext_multiparty_mult <- two_party_decrypt(cc, kp1, kp2, ciphertext_mult)
  set_length(plaintext_multiparty_mult, n)

  # Resulting Fused Plaintext after Multiplication of plaintexts 1 and 3
  expect_equal(as.numeric(get_packed_value(plaintext_multiparty_mult)),
               vector_of_ints1 * vector_of_ints3)

  plaintext_multiparty_eval_sum <- two_party_decrypt(cc, kp1, kp2,
                                                     ciphertext_eval_sum)
  set_length(plaintext_multiparty_eval_sum, n)

  # Fused result after summation of ciphertext 3: each slot holds the
  # sum of the batch_size slots from it onward, and the slots after the
  # data are zero.
  expect_equal(as.numeric(get_packed_value(plaintext_multiparty_eval_sum)),
               rev(cumsum(rev(vector_of_ints3))))
}

# ══ CKKS ═════════════════════════════════════════════════
run_ckks <- function() {
  batch_size <- 16L

  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, 3L)
  set_scaling_mod_size(parameters, 50L)
  set_batch_size(parameters, batch_size)

  cc <- gen_crypto_context(parameters)
  # Enable features you wish to use
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)
  enable_feature(cc, Feature$MULTIPARTY)

  # Set-up of parameters
  check_parameters(cc)

  # Perform Key Generation Operation
  kps <- joint_key_gen(cc)
  kp1 <- kps$kp1
  kp2 <- kps$kp2

  # Encode source data
  vector_of_ints1 <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0, 0.0)
  vector_of_ints2 <- c(1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  vector_of_ints3 <- c(2.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 0.0, 0.0)

  plaintext1 <- make_ckks_packed_plaintext(cc, vector_of_ints1)
  plaintext2 <- make_ckks_packed_plaintext(cc, vector_of_ints2)
  plaintext3 <- make_ckks_packed_plaintext(cc, vector_of_ints3)

  # Encryption
  ciphertext1 <- encrypt(kp2@public, plaintext1, cc = cc)
  ciphertext2 <- encrypt(kp2@public, plaintext2, cc = cc)
  ciphertext3 <- encrypt(kp2@public, plaintext3, cc = cc)

  # EvalAdd Operation on Re-Encrypted Data
  ciphertext_add12 <- eval_add(ciphertext1, ciphertext2)
  ciphertext_add123 <- eval_add(ciphertext_add12, ciphertext3)

  ciphertext_mult_temp <- eval_mult(ciphertext1, ciphertext3)
  ciphertext_mult <- mod_reduce(ciphertext_mult_temp)
  ciphertext_eval_sum <- eval_sum(ciphertext3, batch_size)

  # Decryption after Accumulation Operation on Encrypted Data with Multiparty
  plaintext_multiparty_new <- two_party_decrypt(cc, kp1, kp2, ciphertext_add123)

  tol <- 1e-6
  n <- get_length(plaintext1)

  # Original Plaintext
  expect_equal(get_real_packed_value(plaintext1)[seq_along(vector_of_ints1)],
               vector_of_ints1, tolerance = tol)
  expect_equal(get_real_packed_value(plaintext2)[seq_along(vector_of_ints2)],
               vector_of_ints2, tolerance = tol)
  expect_equal(get_real_packed_value(plaintext3)[seq_along(vector_of_ints3)],
               vector_of_ints3, tolerance = tol)

  set_length(plaintext_multiparty_new, n)
  pad <- function(v) c(v, numeric(n - length(v)))

  # Resulting Fused Plaintext
  expect_equal(get_real_packed_value(plaintext_multiparty_new),
               pad(vector_of_ints1 + vector_of_ints2 + vector_of_ints3),
               tolerance = tol)

  plaintext_multiparty_mult <- two_party_decrypt(cc, kp1, kp2, ciphertext_mult)
  set_length(plaintext_multiparty_mult, n)

  # Resulting Fused Plaintext after Multiplication of plaintexts 1 and 3
  expect_equal(get_real_packed_value(plaintext_multiparty_mult),
               pad(vector_of_ints1 * vector_of_ints3), tolerance = tol)

  plaintext_multiparty_eval_sum <- two_party_decrypt(cc, kp1, kp2,
                                                     ciphertext_eval_sum)
  set_length(plaintext_multiparty_eval_sum, n)

  # Fused result after the Summation of ciphertext 3
  expect_equal(get_real_packed_value(plaintext_multiparty_eval_sum),
               rep(sum(vector_of_ints3), n), tolerance = tol)
}

# ── main ─────────────────────────────────────────────────
run_bgvrns_additive()
run_bfvrns()
run_ckks()
