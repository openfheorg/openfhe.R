## OPENFHE PYTHON SOURCE: examples/pke/pre-hra-secure.py
##
## @openfhe-python: pre-hra-secure.py [FULL]
##
## Example of HRA-secure Proxy Re-Encryption with 13 hops.
library(openfhe.R)

run_demo_pre <- function() {
  # Generate parameters.
  plaintext_modulus <- 2  # can encode shorts

  num_hops <- 13L

  parameters <- BGVParams()
  set_plaintext_modulus(parameters, plaintext_modulus)
  set_scaling_technique(parameters, ScalingTechnique$FIXEDMANUAL)
  set_pre_num_hops(parameters, num_hops)
  set_statistical_security(parameters, 40L)
  set_num_adversarial_queries(parameters, 1048576)
  set_ring_dim(parameters, 32768L)
  set_pre_mode(parameters, PREMode$NOISE_FLOODING_HRA)
  set_key_switch_technique(parameters, KeySwitchTechnique$HYBRID)
  set_multiplicative_depth(parameters, 0L)

  cc <- gen_crypto_context(parameters)

  # Turn on features
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$PRE)

  ## p, n and log2 q
  expect_equal(as.numeric(get_plaintext_modulus(cc)), plaintext_modulus)
  expect_equal(get_cyclotomic_order(cc) %/% 2L, 32768L)
  modulus <- get_modulus(cc)
  expect_true(is.character(modulus) && grepl("^[0-9]+$", modulus))

  ringsize <- ring_dimension(cc)
  expect_equal(ringsize, 32768L)

  # ── Perform Key Generation Operation ───────────────────
  ## Alice key generation (used for source data)
  key_pair1 <- key_gen(cc)

  # ── Encode source data ─────────────────────────────────
  nshort <- ringsize

  v_shorts <- sample(0:(plaintext_modulus - 1), nshort, replace = TRUE)

  pt <- make_coef_packed_plaintext(cc, v_shorts)

  # ── Encryption ─────────────────────────────────────────
  ct1 <- encrypt(key_pair1@public, pt, cc = cc)

  # ── Decryption of Ciphertext ───────────────────────────
  pt_dec1 <- decrypt(ct1, key_pair1@secret, cc = cc)
  set_length(pt_dec1, get_length(pt))

  # ── Perform Key Generation Operation ───────────────────
  key_pair_vector <- vector("list", num_hops)
  reencryption_key_vector <- vector("list", num_hops)

  ## Keys for num_hops parties
  for (i in seq_len(num_hops)) {
    key_pair_vector[[i]] <- key_gen(cc)

    # Perform the proxy re-encryption key generation operation.
    # This generates the keys which are used to perform the key switching.
    if (i == 1L) {
      reencryption_key_vector[[i]] <-
        re_key_gen(cc, key_pair1@secret, key_pair_vector[[i]]@public)
    } else {
      reencryption_key_vector[[i]] <-
        re_key_gen(cc, key_pair_vector[[i - 1L]]@secret,
                   key_pair_vector[[i]]@public)
    }
  }

  # ── Re-Encryption ──────────────────────────────────────
  good <- TRUE
  for (i in seq_len(num_hops)) {
    ct1 <- re_encrypt(ct1, reencryption_key_vector[[i]])

    if (i < num_hops) {
      mod_reduce_in_place(ct1)
    }

    # ── Decryption of Ciphertext ─────────────────────────
    pt_dec2 <- decrypt(ct1, key_pair_vector[[i]]@secret, cc = cc)
    set_length(pt_dec2, get_length(pt))

    unpacked0 <- as.numeric(get_coef_packed_value(pt))
    unpacked1 <- as.numeric(get_coef_packed_value(pt_dec1))
    unpacked2 <- as.numeric(get_coef_packed_value(pt_dec2))

    # note that OpenFHE assumes that plaintext is in the range of -p/2..p/2
    # to recover 0...q simply add q if the unpacked value is negative
    unpacked1 <- ifelse(unpacked1 < 0, unpacked1 + plaintext_modulus, unpacked1)
    unpacked2 <- ifelse(unpacked2 < 0, unpacked2 + plaintext_modulus, unpacked2)

    # compare all the results for correctness
    if (any(unpacked0 != unpacked1) || any(unpacked0 != unpacked2)) {
      good <- FALSE
    }

    expect_equal(unpacked1, unpacked0, info = paste("hop", i))
    expect_equal(unpacked2, unpacked0, info = paste("hop", i))
    expect_true(good, info = paste("PRE passes at hop", i))
  }

  good
}

passed <- run_demo_pre()
expect_true(passed)
