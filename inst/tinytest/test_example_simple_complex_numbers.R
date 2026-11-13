## OPENFHE PYTHON SOURCE: examples/pke/simple-complex-numbers.py
##
## @openfhe-python: simple-complex-numbers.py [FULL]
##
## CKKS on complex numbers: simple operations, bootstrapping, and
## bootstrapping with the slots-to-coefficients transformation first.
library(openfhe.R)

## Tolerances: a 50-bit scaling factor at depth 1 for the simple
## operations; bootstrapping at ring dimension 64 is far less precise.
tol <- 1e-8
tol_boot <- 1e-4

# ── Simple Operations on Complex Numbers ─────────────────
simple_complex_numbers <- function() {
  # Step 1: Setup CryptoContext
  mult_depth <- 1L
  scale_mod_size <- 50L
  batch_size <- 8L
  ckks_data_type <- CKKSDataType$COMPLEX

  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_batch_size(parameters, batch_size)
  set_ckks_data_type(parameters, ckks_data_type)

  cc <- gen_crypto_context(parameters)

  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)

  # Step 2: Key Generation
  keys <- key_gen(cc)
  eval_mult_key_gen(cc, keys@secret)
  eval_rotate_key_gen(cc, keys@secret, c(1L, -2L))

  # Conjugation key: automorphism with index 2N-1
  index_conj <- 2L * ring_dimension(cc) - 1L
  eval_automorphism_key_gen(cc, keys@secret, index_conj)

  # Step 3: Encoding and encryption of inputs
  x1 <- c(0.25 + 0.25i, 0.5 + 0.5i, 0.75 + 0.75i, 1.0 + 1.0i,
          2.0 + 2.0i, 3.0 + 3.0i, 4.0 + 4.0i, 5.0 + 5.0i)
  x2 <- c(5.0 - 5.0i, 4.0 - 4.0i, 3.0 - 3.0i, 2.0 - 2.0i,
          1.0 - 1.0i, 0.75 - 0.75i, 0.5 - 0.5i, 0.25 - 0.25i)

  const_complex <- 1.0 - 2.0i
  const_complex2 <- 1.0 + 0.5i

  ptxt1 <- make_ckks_packed_plaintext(cc, x1)
  ptxt2 <- make_ckks_packed_plaintext(cc, x2)

  expect_equal(get_complex_packed_value(ptxt1)[seq_len(batch_size)], x1,
               tolerance = tol)
  expect_equal(get_complex_packed_value(ptxt2)[seq_len(batch_size)], x2,
               tolerance = tol)

  c1 <- encrypt(keys@public, ptxt1, cc = cc)
  c2 <- encrypt(keys@public, ptxt2, cc = cc)

  # Step 4: Evaluation
  c_add <- eval_add(c1, c2)
  c_sub <- eval_sub(c1, c2)
  c_scalar <- eval_mult(c1, 4.0)
  c_mul <- eval_mult(c1, c2)
  c_rot1 <- eval_rotate(c1, 1L)
  c_rot2 <- eval_rotate(c1, -2L)

  # Conjugation (automorphism)
  eval_conj_key_map <- get_eval_automorphism_key_map(get_key_tag(c1))
  c_conj1 <- eval_automorphism(c1, index_conj, eval_conj_key_map)

  # Multiply by a complex constant
  c_mul_c <- eval_mult(c1, const_complex)

  # Additions by complex constants
  c_add_c <- eval_add(c2, const_complex)
  eval_add_in_place(c_add_c, const_complex2)

  # Subtractions by complex constants
  c_sub_c <- eval_sub(c2, const_complex)
  eval_sub_in_place(c_sub_c, const_complex2)

  # Step 5: Decryption and output
  decrypt_values <- function(ct) {
    result <- decrypt(ct, keys@secret, cc = cc)
    set_length(result, batch_size)
    get_complex_packed_value(result)
  }

  ## Decrypted complex inputs
  expect_equal(decrypt_values(c1), x1, tolerance = tol)
  expect_equal(decrypt_values(c2), x2, tolerance = tol)

  ## Results of homomorphic computations
  expect_equal(decrypt_values(c_add), x1 + x2, tolerance = tol)
  expect_equal(decrypt_values(c_sub), x1 - x2, tolerance = tol)
  expect_equal(decrypt_values(c_scalar), 4 * x1, tolerance = tol)
  expect_equal(decrypt_values(c_mul), x1 * x2, tolerance = tol)

  ## The eight values fill the eight slots, so the rotations are
  ## cyclic: to the left by 1 and to the right by 2.
  expect_equal(decrypt_values(c_rot1), x1[c(2:8, 1L)], tolerance = tol)
  expect_equal(decrypt_values(c_rot2), x1[c(7:8, 1:6)], tolerance = tol)

  expect_equal(decrypt_values(c_conj1), Conj(x1), tolerance = tol)
  expect_equal(decrypt_values(c_mul_c), x1 * const_complex, tolerance = tol)
  expect_equal(decrypt_values(c_add_c), x2 + const_complex + const_complex2,
               tolerance = tol)
  expect_equal(decrypt_values(c_sub_c), x2 - const_complex - const_complex2,
               tolerance = tol)
}

fill_to_length <- function(vec, n, fill_value = 0) {
  # C++ Fill<T>(x, numSlots) behavior for demos is usually "pad with zeros"
  if (length(vec) >= n) {
    return(vec[seq_len(n)])
  }
  c(vec, rep(fill_value, n - length(vec)))
}

# ── Bootstrapping Complex Numbers ────────────────────────
simple_bootstrapping_complex <- function() {
  parameters <- CKKSParams()

  secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
  set_secret_key_dist(parameters, secret_key_dist)

  set_security_level(parameters, SecurityLevel$HEStd_NotSet)
  ring_dim <- bitwShiftL(1L, 6L)
  set_ring_dim(parameters, ring_dim)

  if (get_native_int() == 128L) {
    rescale_tech <- ScalingTechnique$FIXEDAUTO
    dcrt_bits <- 78L
    first_mod <- 89L
  } else {
    rescale_tech <- ScalingTechnique$FLEXIBLEAUTO
    dcrt_bits <- 59L
    first_mod <- 60L
  }

  set_scaling_mod_size(parameters, dcrt_bits)
  set_scaling_technique(parameters, rescale_tech)
  set_first_mod_size(parameters, first_mod)

  set_ckks_data_type(parameters, CKKSDataType$COMPLEX)

  num_slots <- ring_dim %/% 2L
  # The batch size is intentionally not set, as in the C++ demo.

  level_budget <- c(2L, 2L)
  levels_available_after_bootstrap <- 10L
  depth <- levels_available_after_bootstrap +
    get_bootstrap_depth(level_budget, secret_key_dist)
  set_multiplicative_depth(parameters, depth)

  crypto_context <- gen_crypto_context(parameters)
  enable_feature(crypto_context, Feature$PKE)
  enable_feature(crypto_context, Feature$KEYSWITCH)
  enable_feature(crypto_context, Feature$LEVELEDSHE)
  enable_feature(crypto_context, Feature$ADVANCEDSHE)
  enable_feature(crypto_context, Feature$FHE)

  eval_bootstrap_setup(crypto_context, level_budget, c(0L, 0L), num_slots)

  key_pair <- key_gen(crypto_context)
  eval_mult_key_gen(crypto_context, key_pair@secret)
  eval_bootstrap_key_gen(crypto_context, key_pair@secret, num_slots)

  x <- c(0.25 + 0.25i, 0.5 - 0.5i, 0.75 + 0.75i, 1.0 - 1.0i,
         2.0 + 2.0i, 3.0 - 3.0i, 4.0 + 4.0i, 5.0 - 5.0i)
  x <- fill_to_length(x, num_slots, 0.0 + 0.0i)
  encoded_length <- length(x)

  # depleted ciphertext: level = depth-1
  ptxt <- make_ckks_packed_plaintext(crypto_context, x, 1L, depth - 1L, NULL,
                                     num_slots)
  set_length(ptxt, encoded_length)
  expect_equal(get_complex_packed_value(ptxt), x, tolerance = tol)

  ciph <- encrypt(key_pair@public, ptxt, cc = crypto_context)

  ## Initial number of levels remaining
  expect_equal(depth - get_level(ciph), 1L)

  ciphertext_after <- eval_bootstrap(ciph)

  ## Number of levels remaining after bootstrapping
  levels_after <- depth - get_level(ciphertext_after) -
    (get_noise_scale_deg(ciphertext_after) - 1L)
  expect_equal(levels_after, levels_available_after_bootstrap)

  result <- decrypt(ciphertext_after, key_pair@secret, cc = crypto_context)
  set_length(result, encoded_length)
  ## Output after bootstrapping
  expect_equal(get_complex_packed_value(result), x, tolerance = tol_boot)
}

# ── Bootstrapping Complex Numbers with StC Transformation First ──
simple_bootstrapping_stc_first_complex <- function() {
  parameters <- CKKSParams()

  secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
  set_secret_key_dist(parameters, secret_key_dist)

  set_security_level(parameters, SecurityLevel$HEStd_NotSet)
  ring_dim <- bitwShiftL(1L, 6L)
  set_ring_dim(parameters, ring_dim)

  if (get_native_int() == 128L) {
    rescale_tech <- ScalingTechnique$FIXEDAUTO
    dcrt_bits <- 78L
    first_mod <- 89L
  } else {
    rescale_tech <- ScalingTechnique$FLEXIBLEAUTO
    dcrt_bits <- 59L
    first_mod <- 60L
  }

  set_scaling_mod_size(parameters, dcrt_bits)
  set_scaling_technique(parameters, rescale_tech)
  set_first_mod_size(parameters, first_mod)

  set_ckks_data_type(parameters, CKKSDataType$COMPLEX)

  num_slots <- ring_dim %/% 2L
  # The batch size is intentionally not set, as in the C++ demo.

  level_budget <- c(2L, 2L)

  levels_available_after_bootstrap <- 10L + level_budget[2L]
  depth <- levels_available_after_bootstrap +
    get_bootstrap_depth(c(level_budget[1L], 0L), secret_key_dist)
  set_multiplicative_depth(parameters, depth)

  crypto_context <- gen_crypto_context(parameters)
  enable_feature(crypto_context, Feature$PKE)
  enable_feature(crypto_context, Feature$KEYSWITCH)
  enable_feature(crypto_context, Feature$LEVELEDSHE)
  enable_feature(crypto_context, Feature$ADVANCEDSHE)
  enable_feature(crypto_context, Feature$FHE)

  eval_bootstrap_setup(crypto_context, level_budget, c(0L, 0L), num_slots, 0L,
                       TRUE, TRUE)

  key_pair <- key_gen(crypto_context)
  eval_mult_key_gen(crypto_context, key_pair@secret)
  eval_bootstrap_key_gen(crypto_context, key_pair@secret, num_slots)

  x <- c(0.25 + 0.25i, 0.5 - 0.5i, 0.75 + 0.75i, 1.0 - 1.0i,
         2.0 + 2.0i, 3.0 - 3.0i, 4.0 + 4.0i, 5.0 - 5.0i)
  x <- fill_to_length(x, num_slots, 0.0 + 0.0i)
  encoded_length <- length(x)

  # depleted ciphertext: level = depth - 1 - levelBudget[1]
  ptxt <- make_ckks_packed_plaintext(crypto_context, x, 1L,
                                     depth - 1L - level_budget[2L], NULL,
                                     num_slots)
  set_length(ptxt, encoded_length)
  expect_equal(get_complex_packed_value(ptxt), x, tolerance = tol)

  ciph <- encrypt(key_pair@public, ptxt, cc = crypto_context)

  ## Initial number of levels remaining
  expect_equal(depth - get_level(ciph), 1L + level_budget[2L])

  ciphertext_after <- eval_bootstrap(ciph)

  ## Number of levels remaining after bootstrapping
  levels_after <- depth - get_level(ciphertext_after) -
    (get_noise_scale_deg(ciphertext_after) - 1L)
  expect_equal(levels_after, levels_available_after_bootstrap)

  result <- decrypt(ciphertext_after, key_pair@secret, cc = crypto_context)

  # C++: result->SetLength(2 * encodedLength);
  set_length(result, 2L * encoded_length)
  ## Output after bootstrapping
  ## The first half is the bootstrapped input; the length asked for is
  ## twice the number of slots, and the second half is filled with
  ## zeros.
  output <- get_complex_packed_value(result)
  expect_equal(length(output), 2L * encoded_length)
  expect_equal(output[seq_len(encoded_length)], x, tolerance = tol_boot)
  expect_true(all(output[encoded_length + seq_len(encoded_length)] == 0))
}

# ── main ─────────────────────────────────────────────────
simple_complex_numbers()
simple_bootstrapping_complex()
simple_bootstrapping_stc_first_complex()
