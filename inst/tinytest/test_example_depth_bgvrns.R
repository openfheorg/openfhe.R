## OPENFHE PYTHON SOURCE: examples/pke/depth-bgvrns.py
##
## @openfhe-python: depth-bgvrns.py [FULL]
##
## Example of a computation circuit of depth 3: BGVrns demo for a
## homomorphic multiplication of depth 6 and three different approaches
## for depth-3 multiplications.
library(openfhe.R)

# ── Set-up of parameters ─────────────────────────────────
# Number of evalMults = 3 (first 3) is used to support the
# multiplication of 7 ciphertexts, i.e., ceiling{log2{7}}. Max depth is
# set to 3 (second 3) to generate homomorphic evaluation
# multiplication keys for s^2 and s^3.
parameters <- BGVParams()
set_multiplicative_depth(parameters, 3L)
# This prime supports packed encoding for the m = 65536 cyclotomic
# order selected by the 128-bit backend, as well as the smaller
# backends.
set_plaintext_modulus(parameters, 537133057)
set_max_relin_sk_deg(parameters, 3L)

crypto_context <- gen_crypto_context(parameters)
# enable features that you wish to use
enable_feature(crypto_context, Feature$PKE)
enable_feature(crypto_context, Feature$KEYSWITCH)
enable_feature(crypto_context, Feature$LEVELEDSHE)
enable_feature(crypto_context, Feature$ADVANCEDSHE)

## p, n and log2 q
expect_equal(as.numeric(get_plaintext_modulus(crypto_context)), 537133057)
expect_equal(get_cyclotomic_order(crypto_context) %/% 2L,
             ring_dimension(crypto_context))
## The ciphertext modulus is wider than 53 bits and crosses as a
## string of decimal digits.
modulus <- get_modulus(crypto_context)
expect_true(is.character(modulus) && grepl("^[0-9]+$", modulus))
expect_true(nchar(modulus) > 16L)

# ── Perform Key Generation Operation ─────────────────────
key_pair <- key_gen(crypto_context)
## Keys for homomorphic multiplication (s^2 and s^3)
eval_mult_keys_gen(crypto_context, key_pair@secret)

# ── Encode source data ───────────────────────────────────
vector_of_ints1 <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
plaintext1 <- make_packed_plaintext(crypto_context, vector_of_ints1)

vector_of_ints2 <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
plaintext2 <- make_packed_plaintext(crypto_context, vector_of_ints2)

vector_of_ints3 <- c(2, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
plaintext3 <- make_packed_plaintext(crypto_context, vector_of_ints3)

vector_of_ints4 <- c(2, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
plaintext4 <- make_packed_plaintext(crypto_context, vector_of_ints4)

vector_of_ints5 <- c(3, 2, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12)
plaintext5 <- make_packed_plaintext(crypto_context, vector_of_ints5)

vector_of_ints6 <- c(3, 2, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12)
plaintext6 <- make_packed_plaintext(crypto_context, vector_of_ints6)

vector_of_ints7 <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
plaintext7 <- make_packed_plaintext(crypto_context, vector_of_ints7)

expect_equal(as.numeric(get_packed_value(plaintext1)), vector_of_ints1)
expect_equal(as.numeric(get_packed_value(plaintext3)), vector_of_ints3)
expect_equal(as.numeric(get_packed_value(plaintext5)), vector_of_ints5)

# ── Encryption ───────────────────────────────────────────
ciphertexts <- lapply(
  list(plaintext1, plaintext2, plaintext3, plaintext4, plaintext5, plaintext6,
       plaintext7),
  function(pt) encrypt(key_pair@public, pt, cc = crypto_context))

decrypt_values <- function(ct) {
  pt <- decrypt(ct, key_pair@secret, cc = crypto_context)
  set_length(pt, get_length(plaintext1))
  as.numeric(get_packed_value(pt))
}

## The values the example prints, computed in the clear. Every
## product stays below half the plaintext modulus.
expected_mult <- vector_of_ints1 * vector_of_ints2
expected_mult7 <- vector_of_ints1 * vector_of_ints2 * vector_of_ints3 *
  vector_of_ints4 * vector_of_ints5 * vector_of_ints6 * vector_of_ints7
expected_mult123 <- vector_of_ints1 * vector_of_ints2 * vector_of_ints3

# ── Homomorphic multiplication of 2 ciphertexts ──────────
ciphertext_mult <- eval_mult(ciphertexts[[1L]], ciphertexts[[2L]])
expect_equal(decrypt_values(ciphertext_mult), expected_mult)

# ── Homomorphic multiplication of 7 ciphertexts ──────────
## A binary-tree multiplication of 7 ciphertexts
ciphertext_mult7 <- eval_mult_many(ciphertexts)
expect_equal(decrypt_values(ciphertext_mult7), expected_mult7)

# ── Homomorphic multiplication of 3 ciphertexts where ────
# ── relinearization is done at the end ───────────────────
ciphertext_mult12 <- eval_mult_no_relin(ciphertexts[[1L]], ciphertexts[[2L]])
mod_reduce_in_place(ciphertext_mult12)
ciphertexts2 <- mod_reduce(ciphertexts[[3L]])
ciphertext_mult123 <- eval_mult_and_relinearize(ciphertext_mult12, ciphertexts2)
expect_equal(decrypt_values(ciphertext_mult123), expected_mult123)

# ── Homomorphic multiplication of 3 ciphertexts w/o any ──
# ── relinearization ──────────────────────────────────────
ciphertext_mult12 <- eval_mult_no_relin(ciphertexts[[1L]], ciphertexts[[2L]])
mod_reduce_in_place(ciphertext_mult12)
ciphertext_mult123 <- eval_mult_no_relin(ciphertext_mult12, ciphertexts2)
ciphertext_mult123 <- mod_reduce(ciphertext_mult123)
expect_equal(decrypt_values(ciphertext_mult123), expected_mult123)

# ── Homomorphic multiplication of 3 ciphertexts w/ ───────
# ── relinearization after each multiplication ────────────
ciphertext_mult12 <- eval_mult(ciphertexts[[1L]], ciphertexts[[2L]])
mod_reduce_in_place(ciphertext_mult12)
ciphertext_mult123 <- eval_mult(ciphertext_mult12, ciphertexts2)
expect_equal(decrypt_values(ciphertext_mult123), expected_mult123)
