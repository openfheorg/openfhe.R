## OPENFHE PYTHON SOURCE: examples/pke/tckks-interactive-mp-bootstrapping.py
##
## @openfhe-python: tckks-interactive-mp-bootstrapping.py [FULL]
##
## Interactive multi-party bootstrapping of a threshold-CKKS ciphertext
## for 3 parties, following Protocol 5 in
## https://eprint.iacr.org/2020/304, "Multiparty Homomorphic Encryption
## from Ring-Learning-With-Errors".
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

tckks_collective_boot <- function(scale_tech) {
  supported <- c(ScalingTechnique$FIXEDMANUAL, ScalingTechnique$FIXEDAUTO,
                 ScalingTechnique$FLEXIBLEAUTO, ScalingTechnique$FLEXIBLEAUTOEXT)
  if (!(scale_tech %in% supported)) {
    stop("ERROR: Scaling technique is not supported!")
  }

  parameters <- CKKSParams()

  secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
  set_secret_key_dist(parameters, secret_key_dist)

  set_security_level(parameters, SecurityLevel$HEStd_128_classic)

  dcrt_bits <- 50L
  first_mod <- 60L

  set_scaling_mod_size(parameters, dcrt_bits)
  set_scaling_technique(parameters, scale_tech)
  set_first_mod_size(parameters, first_mod)

  multiplicative_depth <- 7L
  set_multiplicative_depth(parameters, multiplicative_depth)
  set_key_switch_technique(parameters, KeySwitchTechnique$HYBRID)

  batch_size <- 4L
  set_batch_size(parameters, batch_size)

  compression_level <- CompressionLevel$SLACK
  set_interactive_boot_compression_level(parameters, compression_level)

  crypto_context <- gen_crypto_context(parameters)
  enable_feature(crypto_context, Feature$PKE)
  enable_feature(crypto_context, Feature$KEYSWITCH)
  enable_feature(crypto_context, Feature$LEVELEDSHE)
  enable_feature(crypto_context, Feature$ADVANCEDSHE)
  enable_feature(crypto_context, Feature$MULTIPARTY)

  ring_dim <- ring_dimension(crypto_context)
  expect_equal(ring_dim, 32768L)

  num_parties <- 3L

  ## Key generation: the key pair of each party. A party is involved in
  ## the collective bootstrapping protocol with its id, its pair of
  ## shares and its key pair.
  parties <- vector("list", num_parties)
  for (i in seq_len(num_parties)) {
    ## define id of parties[[i]] as i - 1
    parties[[i]] <- list(id = i - 1L, shares_pair = NULL, kp_shard = NULL)
    if (i == 1L) {
      parties[[i]]$kp_shard <- key_gen(crypto_context)
    } else {
      parties[[i]]$kp_shard <-
        multiparty_key_gen(crypto_context, parties[[1L]]$kp_shard@public)
    }
  }

  ## Assert everything is good
  for (i in seq_len(num_parties)) {
    expect_true(is_good(parties[[i]]$kp_shard))
  }

  ## Generate collective public key
  secret_keys <- lapply(parties, function(p) p$kp_shard@secret)
  kp_multiparty <- multiparty_key_gen(crypto_context, secret_keys)

  ## Prepare input vector
  msg1 <- c(-0.9, -0.8, 0.2, 0.4)
  ptxt1 <- make_ckks_packed_plaintext(crypto_context, msg1)

  ## Encryption
  in_ctxt <- encrypt(kp_multiparty@public, ptxt1, cc = crypto_context)

  ## Compressing ctxt to the smallest possible number of towers!
  in_ctxt <- int_mp_boot_adjust_scale(in_ctxt)

  # ── Interactive bootstrapping starts ──────────────────

  ## Leading party (P0) generates a Common Random Poly (a) at max
  ## coefficient modulus (QNumPrime). a is sampled at random uniformly
  ## from R_{Q}
  a <- int_mp_boot_random_element_gen(crypto_context,
                                      parties[[1L]]$kp_shard@public)

  ## Each party generates its own shares: maskedDecryptionShare and
  ## reEncryptionShare

  ## Make a copy of input ciphertext and remove the first element (c0),
  ## we only need c1 for IntMPBootDecrypt
  c1 <- clone(in_ctxt)
  remove_element(c1, 1L)
  expect_equal(length(get_elements(c1)), length(get_elements(in_ctxt)) - 1L)

  share_pair_vec <- vector("list", num_parties)
  for (i in seq_len(num_parties)) {
    parties[[i]]$shares_pair <-
      int_mp_boot_decrypt(parties[[i]]$kp_shard@secret, c1, a)
    share_pair_vec[[i]] <- parties[[i]]$shares_pair
  }

  ## P0 finalizes the protocol by aggregating the shares and
  ## reEncrypting the results
  aggregated_shares_pair <- int_mp_boot_add(crypto_context, share_pair_vec)
  ## Make sure you provide the non-striped ciphertext (in_ctxt) in
  ## IntMPBootEncrypt
  out_ctxt <- int_mp_boot_encrypt(parties[[1L]]$kp_shard@public,
                                  aggregated_shares_pair, a, in_ctxt)

  # ── Interactive bootstrapping ended ───────────────────
  ## The refreshed ciphertext has more levels than the one that went in.
  expect_true(get_level(out_ctxt) < get_level(in_ctxt))

  # ── Distributed decryption ────────────────────────────
  partial_ciphertext_vec <- vector("list", num_parties)
  partial_ciphertext_vec[[1L]] <- multiparty_decrypt_lead(
    crypto_context, parties[[1L]]$kp_shard@secret, list(out_ctxt))[[1L]]

  for (i in seq_len(num_parties)[-1L]) {
    partial_ciphertext_vec[[i]] <- multiparty_decrypt_main(
      crypto_context, parties[[i]]$kp_shard@secret, list(out_ctxt))[[1L]]
  }

  ## Checking the results
  plaintext_multiparty <- do.call(multiparty_decrypt_fusion,
                                  c(list(crypto_context),
                                    partial_ciphertext_vec))
  set_length(plaintext_multiparty, length(msg1))

  ## Original plaintext
  expect_equal(Re(get_complex_packed_value(ptxt1)), msg1)
  ## Result after bootstrapping
  expect_equal(Re(get_complex_packed_value(plaintext_multiparty)), msg1,
               tolerance = 1e-6)
}

## Same test with different rescaling techniques in CKKS
tckks_collective_boot(ScalingTechnique$FIXEDMANUAL)
tckks_collective_boot(ScalingTechnique$FIXEDAUTO)
if (get_native_int() != 128L) {
  tckks_collective_boot(ScalingTechnique$FLEXIBLEAUTO)
  tckks_collective_boot(ScalingTechnique$FLEXIBLEAUTOEXT)
}

clear_fhe_state()
