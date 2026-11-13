## OPENFHE PYTHON SOURCE: examples/pke/function-evaluation.py
##
## @openfhe-python: function-evaluation.py [FULL]
##
## Chebyshev approximations on encrypted CKKS data: the logistic
## function on [-4, 4] at degree 16, and the square root on [0, 10] at
## degree 50, the latter also compared with the same approximation
## computed on cleartext data.
library(openfhe.R)

# ── eval_logistic_example ────────────────────────────────
eval_logistic_example <- function() {
  parameters <- CKKSParams()
  set_security_level(parameters, SecurityLevel$HEStd_NotSet)
  set_ring_dim(parameters, bitwShiftL(1L, 10L))

  scaling_mod_size <- 59L
  first_mod_size <- 60L

  set_scaling_mod_size(parameters, scaling_mod_size)
  set_first_mod_size(parameters, first_mod_size)

  poly_degree <- 16L
  mult_depth <- 6L

  set_multiplicative_depth(parameters, mult_depth)
  cc <- gen_crypto_context(parameters)
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)

  key_pair <- key_gen(cc)
  eval_mult_key_gen(cc, key_pair@secret)

  input <- c(-4, -3, -2, -1, 0, 1, 2, 3, 4)
  encoded_length <- length(input)
  plaintext <- make_ckks_packed_plaintext(cc, input)
  ciphertext <- encrypt(key_pair@public, plaintext, cc = cc)

  lower_bound <- -4
  upper_bound <- 4
  result <- eval_logistic(ciphertext, lower_bound, upper_bound, poly_degree)

  plaintext_dec <- decrypt(result, key_pair@secret, cc = cc)
  set_length(plaintext_dec, encoded_length)

  expected_output <- c(0.0179885, 0.0474289, 0.119205, 0.268936, 0.5, 0.731064,
                       0.880795, 0.952571, 0.982011)
  final_result <- get_complex_packed_value(plaintext_dec)
  list(input = input, expected = expected_output, final = final_result)
}

# ── eval_function_example ────────────────────────────────
eval_function_example <- function() {
  parameters <- CKKSParams()
  set_security_level(parameters, SecurityLevel$HEStd_NotSet)
  set_ring_dim(parameters, bitwShiftL(1L, 10L))

  if (get_native_int() == 128L) {
    scaling_mod_size <- 78L
    first_mod_size <- 89L
  } else {
    scaling_mod_size <- 50L
    first_mod_size <- 60L
  }

  set_scaling_mod_size(parameters, scaling_mod_size)
  set_first_mod_size(parameters, first_mod_size)

  poly_degree <- 50L
  mult_depth <- 7L

  set_multiplicative_depth(parameters, mult_depth)
  cc <- gen_crypto_context(parameters)
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)

  key_pair <- key_gen(cc)
  eval_mult_key_gen(cc, key_pair@secret)

  input <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)
  encoded_length <- length(input)
  plaintext <- make_ckks_packed_plaintext(cc, input)
  ciphertext <- encrypt(key_pair@public, plaintext, cc = cc)

  lower_bound <- 0
  upper_bound <- 10
  result <- eval_chebyshev_function(ciphertext, sqrt, lower_bound, upper_bound,
                                    poly_degree)

  plaintext_dec <- decrypt(result, key_pair@secret, cc = cc)
  set_length(plaintext_dec, encoded_length)

  expected_output <- c(1, 1.414213, 1.732050, 2, 2.236067, 2.449489, 2.645751,
                       2.828427, 3)

  # Compute the same approximation on cleartext data
  func <- function(x) sqrt(x)
  ptxt_approx <- eval_chebyshev_function_ptxt(func, input, lower_bound,
                                              upper_bound, poly_degree)

  final_result <- get_complex_packed_value(plaintext_dec)
  list(input = input, expected = expected_output, cleartext = ptxt_approx,
       final = final_result)
}

# ── main ─────────────────────────────────────────────────
logistic <- eval_logistic_example()
expect_equal(length(logistic$final), length(logistic$input))
## The values printed by the example are the degree-16 approximation,
## given to six significant digits.
expect_true(max(abs(Re(logistic$final) - logistic$expected)) < 1e-5)
expect_true(max(abs(Im(logistic$final))) < 1e-5)
## The approximation against the logistic function itself.
expect_true(max(abs(Re(logistic$final) - 1 / (1 + exp(-logistic$input)))) < 1e-3)

square_root <- eval_function_example()
expect_equal(length(square_root$final), length(square_root$input))
expect_equal(length(square_root$cleartext), length(square_root$input))
## The encrypted evaluation against the same approximation in the clear.
expect_true(max(abs(Re(square_root$final) - square_root$cleartext)) < 1e-6)
## Both against the square roots; the approximation error of degree 50
## on [0, 10] dominates.
expect_true(max(abs(Re(square_root$final) - square_root$expected)) < 2e-2)
expect_true(max(abs(square_root$cleartext - sqrt(square_root$input))) < 2e-2)
