## OPENFHE PYTHON SOURCE: examples/pke/pre-buffer.py
##
## @openfhe-python: pre-buffer.py [FULL]
##
## Proxy re-encryption of a buffer of shorts in BFV: Alice encrypts,
## a re-encryption key takes the ciphertext to Bob, and both decrypt
## the same values.
library(openfhe.R)

run_demo_pre <- function() {
  # Generate parameters.
  plaintext_modulus <- 65537  # can encode shorts

  parameters <- BFVParams()
  set_plaintext_modulus(parameters, plaintext_modulus)
  set_scaling_mod_size(parameters, 60L)

  cc <- gen_crypto_context(parameters)

  # Turn on features
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$PRE)

  ## p, n, log2 q and r
  expect_equal(as.numeric(get_plaintext_modulus(cc)), plaintext_modulus)
  expect_equal(get_cyclotomic_order(cc) / 2, ring_dimension(cc))
  modulus <- get_modulus(cc)
  expect_true(is.character(modulus) && grepl("^[0-9]+$", modulus))
  ## The digit size was not set, so it is the library default of zero.
  expect_equal(as.numeric(get_digit_size(cc)), 0)

  ringsize <- ring_dimension(cc)

  # Perform Key Generation Operation
  ## Alice key generation (used for source data)
  key_pair1 <- key_gen(cc)
  expect_true(is_good(key_pair1))

  # Encode source data
  nshort <- ringsize
  v_shorts <- sample(0:65536, nshort, replace = TRUE)
  pt <- make_packed_plaintext(cc, v_shorts)

  # Encryption
  ct1 <- encrypt(key_pair1@public, pt, cc = cc)

  # Decryption of Ciphertext
  pt_dec1 <- decrypt(ct1, key_pair1@secret, cc = cc)
  set_length(pt_dec1, get_length(pt))

  # Perform Key Generation Operation
  ## Bob key generation
  key_pair2 <- key_gen(cc)
  expect_true(is_good(key_pair2))

  # Perform the proxy re-encryption key generation operation.
  # This generates the keys which are used to perform the key switching.
  reencryption_key12 <- re_key_gen(cc, key_pair1@secret, key_pair2@public)

  # Re-Encryption
  ct2 <- re_encrypt(ct1, reencryption_key12)

  # Decryption of Ciphertext
  pt_dec2 <- decrypt(ct2, key_pair2@secret, cc = cc)
  set_length(pt_dec2, get_length(pt))

  unpacked0 <- as.numeric(get_packed_value(pt))
  unpacked1 <- as.numeric(get_packed_value(pt_dec1))
  unpacked2 <- as.numeric(get_packed_value(pt_dec2))

  # note that OpenFHE assumes that plaintext is in the range of -p/2..p/2
  # to recover 0...q simply add q if the unpacked value is negative
  unpacked1 <- ifelse(unpacked1 < 0, unpacked1 + plaintext_modulus, unpacked1)
  unpacked2 <- ifelse(unpacked2 < 0, unpacked2 + plaintext_modulus, unpacked2)

  # compare all the results for correctness
  expect_equal(length(unpacked0), nshort)
  expect_equal(unpacked0, as.numeric(v_shorts))
  expect_equal(unpacked1, unpacked0)
  expect_equal(unpacked2, unpacked0)

  all(unpacked0 == unpacked1) && all(unpacked0 == unpacked2)
}

passed <- run_demo_pre()
expect_true(passed)
