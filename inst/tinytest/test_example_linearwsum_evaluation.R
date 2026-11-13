## OPENFHE PYTHON SOURCE: examples/pke/linearwsum-evaluation.py
##
## @openfhe-python: linearwsum-evaluation.py [FULL]
##
## Example of linear weighted sum evaluation using CKKS.
library(openfhe.R)

parameters <- CKKSParams()
set_multiplicative_depth(parameters, 1L)
set_scaling_mod_size(parameters, 50L)
set_batch_size(parameters, 8L)
set_security_level(parameters, SecurityLevel$HEStd_NotSet)
set_ring_dim(parameters, 2048L)
if (get_native_int() == 128L) {
  set_scaling_technique(parameters, ScalingTechnique$FIXEDAUTO)
} else {
  set_scaling_technique(parameters, ScalingTechnique$FLEXIBLEAUTO)
}
set_first_mod_size(parameters, 60L)

cc <- gen_crypto_context(parameters)
enable_feature(cc, Feature$PKE)
enable_feature(cc, Feature$KEYSWITCH)
enable_feature(cc, Feature$LEVELEDSHE)
enable_feature(cc, Feature$ADVANCEDSHE)

input <- list(
  c(0.5, 0.7, 0.9, 0.95, 0.93, 1.3),
  c(1.2, 1.7, -0.9, 0.85, -0.63, 2),
  c(0.5, 0, 1.9, 2.95, -3.93, 3.3),
  c(1.5, 0.7, 1.9, 2.95, -3.78, 3.3),
  c(0.5, 2.7, 1.9, 0.0, -3.43, 1.3),
  c(0.5, 0.7, -1.9, 2.95, 1.96, 0.0),
  c(0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
)

encoded_length <- length(input)

coefficients <- c(0.15, 0.75, 1.25, 1, 0, 0.5, 0.5)

key_pair <- key_gen(cc)

## Evaluation key for homomorphic multiplication
eval_mult_key_gen(cc, key_pair@secret)

ciphertext_vec <- lapply(input, function(values) {
  plaintext <- make_ckks_packed_plaintext(cc, values)
  encrypt(key_pair@public, plaintext, cc = cc)
})

result <- eval_linear_wsum(ciphertext_vec, coefficients)

## The same weighted sum on the unencrypted inputs, slot by slot.
unenc_ip <- vapply(seq_along(input[[1L]]), function(i) {
  x <- 0
  for (j in seq_len(encoded_length)) {
    x <- x + input[[j]][i] * coefficients[j]
  }
  x
}, numeric(1))

plaintext_dec <- decrypt(result, key_pair@secret, cc = cc)
set_length(plaintext_dec, encoded_length)

## The example shows one slot more than the inputs fill; that slot
## holds zero.
decrypted <- get_real_packed_value(plaintext_dec)
expect_equal(length(decrypted), encoded_length)
expect_equal(decrypted[seq_along(unenc_ip)], unenc_ip, tolerance = 1e-8)
expect_true(abs(decrypted[encoded_length]) < 1e-8)
