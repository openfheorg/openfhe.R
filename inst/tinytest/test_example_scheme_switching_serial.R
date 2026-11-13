## OPENFHE PYTHON SOURCE: examples/pke/scheme-switching-serial.py
##
## @openfhe-python: scheme-switching-serial.py [FULL]
##
## A server sets up scheme switching and writes everything a client
## needs; the client reads it, computes an argmin through scheme
## switching and writes the result; the server decrypts it.
library(openfhe.R)

## Skipped on CRAN: check time against the Windows budget (D022). Runs
## on GitHub Actions (which sets CI=true) and at home.
if (!at_home() && Sys.getenv("CI") != "true")
  exit_file("skipped on CRAN: check time (runs on CI and at_home)")

datafolder <- tempfile("demoData-")
dir.create(datafolder)
cipher_argmin_location <- file.path(datafolder, "ciphertextArgmin.txt")

# ══ Part 1 and 2: the server sets up, encrypts and writes ═
server_setup_and_write <- function(ring_dim, batch_size, mult_depth,
                                   scale_mod_size, first_mod_size, log_q_lwe,
                                   one_hot) {
  sl <- SecurityLevel$HEStd_NotSet
  args <- list("CKKS",
    multiplicative_depth = mult_depth, security_level = sl,
    ring_dim = ring_dim, batch_size = batch_size,
    scaling_mod_size = scale_mod_size, first_mod_size = first_mod_size,
    features = c(Feature$ADVANCEDSHE, Feature$FHE, Feature$SCHEMESWITCH))
  if (get_native_int() != 128L) {
    args$scaling_technique <- ScalingTechnique$FLEXIBLEAUTO
  }
  server_cc <- do.call(fhe_context, args)
  server_kp <- key_gen(server_cc)

  params <- SchSwchParams()
  set_security_level_ckks(params, sl)
  set_security_level_fhew(params, BinFHEParamSet$TOY)
  set_ctxt_mod_size_fhew_large_prec(params, log_q_lwe)
  set_num_slots_ckks(params, batch_size)
  set_num_values(params, batch_size)
  set_compute_argmin(params, TRUE)
  set_one_hot_encoding(params, one_hot)
  private_key_fhew <- eval_scheme_switching_setup(server_cc, params)
  eval_scheme_switching_key_gen(server_cc, server_kp, private_key_fhew)

  vec <- c(1.0, 2.0, 3.0, 4.0)
  server_p <- make_ckks_packed_plaintext(server_cc, vec)
  server_c <- encrypt(server_kp@public, server_p, cc = server_cc)

  serializer <- SchemeSwitchingDataSerializer(server_cc, server_kp@public,
                                              server_c)
  expect_true(S7::S7_inherits(serializer, SchemeSwitchingDataSerializer))
  ## Nothing is written before a directory is named.
  expect_error(serialize_scheme_switching_data(serializer), "data directory")
  expect_identical(set_data_directory(serializer, datafolder), serializer)
  expect_identical(serialize_scheme_switching_data(serializer), serializer)

  list(cc = server_cc, kp = server_kp, vector_size = length(vec))
}

# ══ Part 3: the client reads, computes and writes ════════
client_process <- function(modulus_lwe) {
  clear_eval_mult_keys()
  clear_eval_sum_keys()
  clear_eval_automorphism_keys()
  clear_fhe_state("contexts")

  deserializer <- SchemeSwitchingDataDeserializer()
  expect_true(S7::S7_inherits(deserializer, SchemeSwitchingDataDeserializer))
  ## Before reading, it holds nothing and reads nothing.
  expect_null(get_crypto_context(deserializer))
  expect_null(get_public_key(deserializer))
  expect_null(get_raw_ciphertext(deserializer))
  expect_error(deserialize_scheme_switching_data(deserializer), "data directory")
  expect_identical(set_data_directory(deserializer, datafolder), deserializer)
  expect_identical(deserialize_scheme_switching_data(deserializer), deserializer)

  client_cc <- get_crypto_context(deserializer)
  client_public_key <- get_public_key(deserializer)
  client_bin_cc <- get_bin_cc_for_scheme_switch(client_cc)
  client_c <- get_raw_ciphertext(deserializer)
  expect_true(S7::S7_inherits(client_cc, CryptoContext))
  expect_true(S7::S7_inherits(client_public_key, PublicKey))
  expect_true(S7::S7_inherits(client_bin_cc, BinFHEContext))
  expect_true(S7::S7_inherits(client_c, Ciphertext))
  ## The switching key from FHEW to CKKS came with the context.
  expect_true(S7::S7_inherits(get_swk_fc(client_cc), Ciphertext))

  scale_sign <- 512
  beta <- get_beta(client_bin_cc)
  p_lwe <- modulus_lwe %/% (2 * beta)   # large precision
  eval_compare_switch_precompute(client_cc, p_lwe, scale_sign, FALSE)

  slots <- get_slots(client_c)
  client_ciphertext_argmin <- eval_min_scheme_switching(
    client_c, client_public_key, slots, slots, 0L, 1)

  fhe_serialize(client_ciphertext_argmin[[2L]], cipher_argmin_location)
}

# ══ Part 4 and 5: the server reads the result and decrypts ═
server_verification <- function(cc, kp, vector_size) {
  ct <- fhe_deserialize(cipher_argmin_location, "Ciphertext")
  pt <- decrypt(ct, kp@secret, cc = cc)
  set_length(pt, vector_size)
  get_real_packed_value(pt)
}

ring_dim <- 64L
batch_size <- 4L
mult_depth <- 13L + log2(batch_size)
log_q_cc_lwe <- 25L
one_hot <- TRUE
scale_mod_size <- 50L
first_mod_size <- 60L

server <- server_setup_and_write(ring_dim, batch_size, mult_depth,
                                 scale_mod_size, first_mod_size, log_q_cc_lwe,
                                 one_hot)
## The files of the serializer.
written <- list.files(datafolder)
expect_true(all(c("cryptocontext.txt", "key_pub.txt", "key_mult.txt",
                  "key_rot.txt", "key_switch_fhew_ckks.txt", "ciphertext.txt",
                  "binfhe_cryptocontext.txt", "key_binfhe_boot.txt",
                  "key_indices.txt") %in% written))

client_process(2^log_q_cc_lwe)
argmin_res <- server_verification(server$cc, server$kp, server$vector_size)
## The minimum of 1, 2, 3, 4 is the first value: one-hot 1, 0, 0, 0.
expect_equal(round(argmin_res), c(1, 0, 0, 0))

# ══ Argument checks ══════════════════════════════════════
expect_error(SchemeSwitchingDataSerializer(), "required")
expect_error(SchemeSwitchingDataSerializer(server$cc, server$kp@secret,
                                           server$kp@public), "PublicKey")
expect_error(set_data_directory(server$cc, datafolder), "must be a")
expect_error(set_data_directory(SchemeSwitchingDataDeserializer(), ""),
             "non-empty")
## A directory without the files.
empty_dir <- tempfile("empty-")
dir.create(empty_dir)
d2 <- SchemeSwitchingDataDeserializer()
set_data_directory(d2, empty_dir)
expect_error(deserialize_scheme_switching_data(d2))

unlink(c(datafolder, empty_dir), recursive = TRUE)
clear_fhe_state()
