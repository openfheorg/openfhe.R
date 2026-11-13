## @openfhe-python: inner-product.py [FULL]
##
## The example builds each context step by step (CCParams setters,
## GenCryptoContext, Enable), generates the multiplication and
## summation keys, and checks EvalInnerProduct of a vector with itself
## against the cleartext value, in BFV and in CKKS.
library(openfhe.R)

plain_inner_product <- function(vec) sum(vec * vec)

# ── inner_product_bfv ────────────────────────────────────
inner_product_bfv <- function(incoming_vector) {
  expected_result <- plain_inner_product(incoming_vector)

  parameters <- BFVParams()
  set_plaintext_modulus(parameters, 65537)
  set_multiplicative_depth(parameters, 20L)
  set_security_level(parameters, SecurityLevel$HEStd_NotSet)
  set_ring_dim(parameters, bitwShiftL(1L, 7L))
  batch_size <- get_ring_dim(parameters) %/% 2L

  cc <- gen_crypto_context(parameters)
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)

  keys <- key_gen(cc)
  eval_mult_key_gen(cc, keys@secret)
  eval_sum_key_gen(cc, keys@secret)

  plaintext1 <- make_packed_plaintext(cc, incoming_vector)
  ct1 <- encrypt(keys@public, plaintext1, cc = cc)
  final_result <- eval_inner_product(ct1, ct1, batch_size)
  res <- decrypt(final_result, keys@secret, cc = cc)
  final <- get_packed_value(res)[1L]
  list(expected = expected_result, final = final)
}

# ── inner_product_ckks ───────────────────────────────────
inner_product_ckks <- function(incoming_vector) {
  expected_result <- plain_inner_product(incoming_vector)

  security_level <- SecurityLevel$HEStd_NotSet
  dcrt_bits <- 59L
  ring_dim <- bitwShiftL(1L, 8L)
  batch_size <- ring_dim %/% 2L
  mult_depth <- 10L

  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, dcrt_bits)
  set_batch_size(parameters, batch_size)
  set_security_level(parameters, security_level)
  set_ring_dim(parameters, ring_dim)

  cc <- gen_crypto_context(parameters)
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)

  keys <- key_gen(cc)
  eval_mult_key_gen(cc, keys@secret)
  eval_sum_key_gen(cc, keys@secret)

  plaintext1 <- make_ckks_packed_plaintext(cc, incoming_vector)
  ct1 <- encrypt(keys@public, plaintext1, cc = cc)
  final_result <- eval_inner_product(ct1, ct1, batch_size)
  res <- decrypt(final_result, keys@secret, cc = cc)
  set_length(res, length(incoming_vector))
  final <- Re(get_complex_packed_value(res)[1L])
  list(expected = expected_result, final = final)
}

# ── main ─────────────────────────────────────────────────
vec <- c(1, 2, 3, 4, 5)
bfv_res <- inner_product_bfv(vec)
expect_equal(as.numeric(bfv_res$final), bfv_res$expected)

as_double <- vec + vec / 100
ckks_res <- inner_product_ckks(as_double)
expect_true(abs(ckks_res$expected - ckks_res$final) <= 0.0001)
