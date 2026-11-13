## OPENFHE PYTHON SOURCE: examples/pke/polynomial-evaluation-high-precision-composite-scaling.py
##
## @openfhe-python: polynomial-evaluation-high-precision-composite-scaling.py [FULL]
##
## Example of polynomial evaluation using CKKS with composite scaling.
## The example's command-line overrides are not ported; the test runs
## at the default parameters.
library(openfhe.R)

# Parameters for d=4
# first_mod_size     = 106
# scaling_mod_size   = 104
# register_word_size = 32
# Parameters for d=3
first_mod_size <- 96L
scaling_mod_size <- 80L
register_word_size <- 32L

mult_depth <- 6L

parameters <- CKKSParams()
set_multiplicative_depth(parameters, mult_depth)
set_first_mod_size(parameters, first_mod_size)
set_scaling_mod_size(parameters, scaling_mod_size)

set_register_word_size(parameters, register_word_size)
set_scaling_technique(parameters, ScalingTechnique$COMPOSITESCALINGAUTO)

cc <- gen_crypto_context(parameters)
enable_feature(cc, Feature$PKE)
enable_feature(cc, Feature$KEYSWITCH)
enable_feature(cc, Feature$LEVELEDSHE)
enable_feature(cc, Feature$ADVANCEDSHE)

composite_degree <- get_composite_degree(cc)

## Composite degree, and the prime moduli size that follows from it
expect_equal(composite_degree, 3L)
expect_equal(scaling_mod_size / composite_degree, 80 / 3)

input <- c(0.5, 0.7, 0.9, 0.95, 0.93)

encoded_length <- length(input)

coefficients1 <- c(0.15, 0.75, 0, 1.25, 0, 0, 1, 0, 1, 2, 0, 1, 0, 0, 0, 0, 1)
coefficients2 <- c(1, 2, 3, 4, 5, -1, -2, -3, -4, -5,
                   0.1, 0.2, 0.3, 0.4, 0.5, -0.1, -0.2, -0.3, -0.4, -0.5,
                   0.1, 0.2, 0.3, 0.4, 0.5, -0.1, -0.2, -0.3, -0.4, -0.5)

plaintext1 <- make_ckks_packed_plaintext(cc, input)

key_pair <- key_gen(cc)

## Evaluation key for homomorphic multiplication
eval_mult_key_gen(cc, key_pair@secret)

ciphertext1 <- encrypt(key_pair@public, plaintext1, cc = cc)

result <- eval_poly(ciphertext1, coefficients1)

result2 <- eval_poly(ciphertext1, coefficients2)

plaintext_dec <- decrypt(result, key_pair@secret, cc = cc)
set_length(plaintext_dec, encoded_length)

plaintext_dec2 <- decrypt(result2, key_pair@secret, cc = cc)
set_length(plaintext_dec2, encoded_length)

## Original Plaintext #1
expect_equal(get_real_packed_value(plaintext1)[seq_len(encoded_length)], input,
             tolerance = 1e-12)

## The polynomials on the unencrypted input: coefficients are in
## increasing order of degree.
eval_poly_clear <- function(x, coefficients) {
  vapply(x, function(v) sum(coefficients * v^(seq_along(coefficients) - 1L)),
         numeric(1))
}

## Result of evaluating a polynomial with coefficients1, against the
## cleartext evaluation and against the values the example prints.
## The first printed value, 0.70519107, is 3e-8 above the cleartext
## value 0.70519104, so the printed values are matched to 1e-7.
decrypted <- get_real_packed_value(plaintext_dec)
expect_equal(decrypted, eval_poly_clear(input, coefficients1), tolerance = 1e-10)
expect_true(all(abs(
  decrypted - c(0.70519107, 1.38285078, 3.97211180, 5.60215665, 4.86357575)
) < 1e-7))

## Result of evaluating a polynomial with coefficients2
decrypted2 <- get_real_packed_value(plaintext_dec2)
expect_equal(decrypted2, eval_poly_clear(input, coefficients2), tolerance = 1e-10)
expect_true(all(abs(
  decrypted2 - c(3.4515092326, 5.3752765397, 4.8993108833, 3.2495023573,
                 4.0485229982)
) < 1e-10))
