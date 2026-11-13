## OPENFHE PYTHON SOURCE: examples/pke/ckks-noise-flooding.py
##
## @openfhe-python: ckks-noise-flooding.py [FULL]
##
## CKKS with the experimental NOISE_FLOODING_DECRYPT mode. All encrypted
## operations are run twice: a preliminary run measures the noise, and
## the actual run takes that noise as a parameter, which decryption
## uses to enhance security.
library(openfhe.R)

## Part of the CryptoContext is built inside a function because all
## parameters must be the same in the two phases, except the execution
## mode and the noise estimate.
get_crypto_context <- function(parameters) {
  ## The security mode NOISE_FLOODING_DECRYPT gives enhanced security.
  set_decryption_noise_mode(parameters,
                            DecryptionNoiseMode$NOISE_FLOODING_DECRYPT)

  ## Specify main parameters
  set_secret_key_dist(parameters, SecretKeyDist$UNIFORM_TERNARY)

  ## The same ring dimension must be used in both iterations, so the
  ## security level is HEStd_NotSet and the ring dimension is set.
  set_security_level(parameters, SecurityLevel$HEStd_NotSet)
  set_ring_dim(parameters, 2^16)

  rescale_tech <- ScalingTechnique$FIXEDAUTO
  dcrt_bits <- 59L
  first_mod <- 60L

  set_scaling_technique(parameters, rescale_tech)
  set_scaling_mod_size(parameters, dcrt_bits)
  set_first_mod_size(parameters, first_mod)

  ## In this example, we perform two multiplications and an addition.
  set_multiplicative_depth(parameters, 2L)

  ## Generate crypto context.
  crypto_context <- gen_crypto_context(parameters)

  ## Enable features that you wish to use.
  enable_feature(crypto_context, Feature$PKE)
  enable_feature(crypto_context, Feature$LEVELEDSHE)

  crypto_context
}

## The encrypted computation is inside a function because it is
## performed twice. The first iteration returns a ciphertext that
## contains a noise measurement; the second the actual result.
encrypted_computation <- function(crypto_context, public_key) {
  vec1 <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
  vec2 <- c(1, 1, 0, 0, 1, 0, 0, 1)

  ## Encoding as plaintexts and encrypt
  ptxt1 <- make_ckks_packed_plaintext(crypto_context, vec1)
  ptxt2 <- make_ckks_packed_plaintext(crypto_context, vec2)
  ciph1 <- encrypt(public_key, ptxt1, cc = crypto_context)
  ciph2 <- encrypt(public_key, ptxt2, cc = crypto_context)

  ciph_mult <- eval_mult(ciph1, ciph2)
  ciph_mult2 <- eval_mult(ciph_mult, ciph1)
  eval_add(ciph_mult2, ciph2)
}

# ══ Phase 1: noise estimation ════════════════════════════
parameters_noise_estimation <- CKKSParams()
## EXEC_NOISE_ESTIMATION indicates that the resulting plaintext will
## estimate the amount of noise in the computation.
set_execution_mode(parameters_noise_estimation,
                   ExecutionMode$EXEC_NOISE_ESTIMATION)

crypto_context_noise_estimation <-
  get_crypto_context(parameters_noise_estimation)

ring_dim <- ring_dimension(crypto_context_noise_estimation)
expect_equal(ring_dim, 65536L)

## Key Generation
key_pair_noise_estimation <- key_gen(crypto_context_noise_estimation)
eval_mult_key_gen(crypto_context_noise_estimation,
                  key_pair_noise_estimation@secret)

## We run the encrypted computation the first time.
noise_ciphertext <- encrypted_computation(crypto_context_noise_estimation,
                                          key_pair_noise_estimation@public)

## Decrypt noise
noise_plaintext <- decrypt(noise_ciphertext, key_pair_noise_estimation@secret,
                           cc = crypto_context_noise_estimation)
noise <- get_log_error(noise_plaintext)
## The noise is a positive number of bits, far below the scaling factor.
expect_true(is.double(noise) && length(noise) == 1L)
expect_true(noise > 0 && noise < 30)

# ══ Phase 2: evaluation ══════════════════════════════════
## IMPORTANT: a different public/private key pair must be used here to
## achieve the security guarantees for noise flooding.
parameters_evaluation <- CKKSParams()
## EXEC_EVALUATION indicates that we are in phase 2 of computation, and
## will obtain the actual result.
set_execution_mode(parameters_evaluation, ExecutionMode$EXEC_EVALUATION)
## Here, we set the noise of our previous computation
set_noise_estimate(parameters_evaluation, noise)

## The desired precision applies to 128-bit CKKS only; for a native
## size of 64 the parameter is ignored.
set_desired_precision(parameters_evaluation, 25)

## The statistical security and the number of adversarial queries are
## set to their default values here.
set_statistical_security(parameters_evaluation, 30)
set_num_adversarial_queries(parameters_evaluation, 1)

## The remaining parameters must be the same as the first CryptoContext.
crypto_context_evaluation <- get_crypto_context(parameters_evaluation)

## IMPORTANT: Generate new keys
key_pair_evaluation <- key_gen(crypto_context_evaluation)
eval_mult_key_gen(crypto_context_evaluation, key_pair_evaluation@secret)

## We run the encrypted computation the second time.
ciphertext_result <- encrypted_computation(crypto_context_evaluation,
                                           key_pair_evaluation@public)

## Decrypt final result
result <- decrypt(ciphertext_result, key_pair_evaluation@secret,
                  cc = crypto_context_evaluation)
vec_size <- 8L
set_length(result, vec_size)
final_output <- get_complex_packed_value(result)

expected_result <- c(1.01, 1.04, 0, 0, 1.25, 0, 0, 1.64)
expect_equal(Re(final_output), expected_result, tolerance = 1e-6)

clear_fhe_state()
