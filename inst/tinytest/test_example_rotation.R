## OPENFHE PYTHON SOURCE: examples/pke/rotation.py
##
## @openfhe-python: rotation.py [FULL]
##
## Example of vector rotation: how the EvalRotate and EvalMerge
## operations work for power-of-two cyclotomic rings.
library(openfhe.R)

# ── BFVrns.EvalRotate - Power-of-Two Cyclotomics ─────────
bfvrns_eval_rotate_2n <- function() {
  parameters <- BFVParams()
  set_plaintext_modulus(parameters, 65537)
  set_max_relin_sk_deg(parameters, 3L)

  cc <- gen_crypto_context(parameters)
  # enable features that you wish to use
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)

  n <- get_cyclotomic_order(cc) %/% 2L

  # Initialize the public key containers.
  kp <- key_gen(cc)

  index_list <- c(2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 10L, -n + 2L, -n + 3L, n - 1L,
                  n - 2L, -1L, -2L, -3L, -4L, -5L)

  eval_rotate_key_gen(cc, kp@secret, index_list)

  vector_of_ints <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  vector_of_ints <- c(vector_of_ints, rep(0, n - length(vector_of_ints)))
  vector_of_ints[n] <- n
  vector_of_ints[n - 1L] <- n - 1
  vector_of_ints[n - 2L] <- n - 2

  int_array <- make_packed_plaintext(cc, vector_of_ints)

  ciphertext <- encrypt(kp@public, int_array, cc = cc)

  ## The packed slots form two rows of n / 2; a rotation by index
  ## shifts each row to the left by index, cyclically, and an index of
  ## n / 2 or more in absolute value also swaps the two rows. The first
  ## ten slots of the result are the start of the first row afterwards,
  ## so the three values at the end of the vector come into view only
  ## for the indices n - 1 and n - 2.
  half <- n %/% 2L
  for (i in seq_along(index_list)) {
    permuted_ciphertext <- eval_rotate(ciphertext, index_list[i])

    int_array_new <- decrypt(permuted_ciphertext, kp@secret, cc = cc)
    set_length(int_array_new, 10L)

    row_start <- if (abs(index_list[i]) >= half) half else 0L
    expected <- vector_of_ints[row_start + ((0:9 + index_list[i]) %% half) + 1L]
    expect_equal(as.numeric(get_packed_value(int_array_new)), expected,
                 info = paste("BFV rotation at index", index_list[i]))
  }
}

# ── CKKS.EvalRotate - Power-of-Two Cyclotomics ───────────
ckks_eval_rotate_2n <- function() {
  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, 2L)
  set_scaling_mod_size(parameters, 40L)

  cc <- gen_crypto_context(parameters)
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)

  cycl_order <- get_cyclotomic_order(cc)

  # Initialize the public key containers.
  kp <- key_gen(cc)

  n <- cycl_order %/% 4L
  index_list <- c(2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 10L, -n + 2L, -n + 3L, n - 1L,
                  n - 2L, -1L, -2L, -3L, -4L, -5L)

  eval_rotate_key_gen(cc, kp@secret, index_list)

  vector_of_ints <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  vector_of_ints <- c(vector_of_ints, rep(0, n - length(vector_of_ints)))
  vector_of_ints[n] <- n
  vector_of_ints[n - 1L] <- n - 1
  vector_of_ints[n - 2L] <- n - 2

  int_array <- make_ckks_packed_plaintext(cc, vector_of_ints)

  ciphertext <- encrypt(kp@public, int_array, cc = cc)

  ## The n slots form a single row; a rotation by index shifts it to
  ## the left by index, cyclically, so the three values at the end of
  ## the vector come into view for negative indices.
  for (i in seq_along(index_list)) {
    permuted_ciphertext <- eval_rotate(ciphertext, index_list[i])

    int_array_new <- decrypt(permuted_ciphertext, kp@secret, cc = cc)
    set_length(int_array_new, 10L)

    expected <- vector_of_ints[((0:9 + index_list[i]) %% n) + 1L]
    expect_equal(get_real_packed_value(int_array_new), expected,
                 tolerance = 1e-5,
                 info = paste("CKKS rotation at index", index_list[i]))
  }
}

# ── BFVrns.EvalMerge - Power-of-Two Cyclotomics ──────────
bfvrns_eval_merge_2n <- function() {
  parameters <- BFVParams()
  set_plaintext_modulus(parameters, 65537)
  set_multiplicative_depth(parameters, 2L)
  set_max_relin_sk_deg(parameters, 3L)

  cc <- gen_crypto_context(parameters)
  # enable features that you wish to use
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)

  # Initialize the public key containers.
  kp <- key_gen(cc)

  index_list <- c(-1L, -2L, -3L, -4L, -5L)

  eval_rotate_key_gen(cc, kp@secret, index_list)

  vector_of_ints1 <- c(32, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  int_array1 <- make_packed_plaintext(cc, vector_of_ints1)

  vector_of_ints2 <- c(2, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  int_array2 <- make_packed_plaintext(cc, vector_of_ints2)

  vector_of_ints3 <- c(4, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  int_array3 <- make_packed_plaintext(cc, vector_of_ints3)

  vector_of_ints4 <- c(8, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  int_array4 <- make_packed_plaintext(cc, vector_of_ints4)

  vector_of_ints5 <- c(16, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  int_array5 <- make_packed_plaintext(cc, vector_of_ints5)

  ciphertexts <- lapply(
    list(int_array1, int_array2, int_array3, int_array4, int_array5),
    function(pt) encrypt(kp@public, pt, cc = cc))

  merged_ciphertext <- eval_merge(ciphertexts)

  int_array_new <- decrypt(merged_ciphertext, kp@secret, cc = cc)
  set_length(int_array_new, 10L)

  ## The merged ciphertext holds the first slot of each input, in
  ## order, followed by zeros.
  expected <- c(vector_of_ints1[1L], vector_of_ints2[1L], vector_of_ints3[1L],
                vector_of_ints4[1L], vector_of_ints5[1L], 0, 0, 0, 0, 0)
  expect_equal(as.numeric(get_packed_value(int_array_new)), expected)
}

# ── main ─────────────────────────────────────────────────
bfvrns_eval_rotate_2n()
ckks_eval_rotate_2n()
bfvrns_eval_merge_2n()
