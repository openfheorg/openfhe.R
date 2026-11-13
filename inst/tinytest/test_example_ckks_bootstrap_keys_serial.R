## OPENFHE PYTHON SOURCE: examples/pke/ckks-bootstrap-keys-serial.py
##
## @openfhe-python: ckks-bootstrap-keys-serial.py [FULL]
##
## Serializing and deserializing CKKS bootstrap evaluation keys: a
## server writes the context, the keys and a ciphertext; a client reads
## them and bootstraps the ciphertext with the keys it read.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

datafolder <- tempfile("demoData-")
dir.create(datafolder)
cc_location <- file.path(datafolder, "bootstrap-cryptocontext.txt")
public_key_location <- file.path(datafolder, "bootstrap-public-key.txt")
secret_key_location <- file.path(datafolder, "bootstrap-secret-key.txt")
ciphertext_location <- file.path(datafolder, "bootstrap-ciphertext.txt")
mult_key_location <- file.path(datafolder, "bootstrap-eval-mult-keys.txt")
bootstrap_key_location <- file.path(datafolder, "bootstrap-eval-keys.txt")

parameters <- CKKSParams()
## SPARSE_ENCAPSULATED is recommended for CKKS bootstrapping.
## UNIFORM_TERNARY, used here, is the distribution of the homomorphic
## encryption security guidelines.
secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
set_secret_key_dist(parameters, secret_key_dist)
set_security_level(parameters, SecurityLevel$HEStd_NotSet)
set_ring_dim(parameters, 2^12)

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

level_budget <- c(4L, 4L)
levels_available_after_bootstrap <- 10L
depth <- levels_available_after_bootstrap +
  get_bootstrap_depth(level_budget, secret_key_dist)
set_multiplicative_depth(parameters, depth)

server_cc <- gen_crypto_context(parameters)
enable_feature(server_cc, Feature$PKE)
enable_feature(server_cc, Feature$KEYSWITCH)
enable_feature(server_cc, Feature$LEVELEDSHE)
enable_feature(server_cc, Feature$ADVANCEDSHE)
enable_feature(server_cc, Feature$FHE)

num_slots <- ring_dimension(server_cc) %/% 2L
eval_bootstrap_setup(server_cc, level_budget, c(0L, 0L), num_slots)

key_pair <- key_gen(server_cc)
eval_mult_key_gen(server_cc, key_pair@secret)
eval_bootstrap_key_gen(server_cc, key_pair@secret, num_slots)

x <- c(0.25, 0.5, 0.75, 1.0)
plaintext <- make_ckks_packed_plaintext(server_cc, x, 1L, depth - 1L)
set_length(plaintext, length(x))
ciphertext <- encrypt(key_pair@public, plaintext, cc = server_cc)

# ══ The server writes ════════════════════════════════════
expect_true(fhe_serialize(server_cc, cc_location))
expect_true(fhe_serialize(key_pair@public, public_key_location))
expect_true(fhe_serialize(key_pair@secret, secret_key_location))
expect_true(fhe_serialize(ciphertext, ciphertext_location))

expect_true(serialize_eval_keys(mult_key_location, "mult", key_tag = ""))

expect_true(serialize_eval_bootstrap_key(bootstrap_key_location, server_cc,
                                         get_key_tag(key_pair@secret), num_slots))

server_key_indices <-
  get_existing_eval_automorphism_key_indices(get_key_tag(key_pair@secret))

clear_eval_mult_keys()
clear_eval_automorphism_keys()
clear_fhe_state("contexts")

# ══ The client reads ═════════════════════════════════════
client_cc <- fhe_deserialize(cc_location, "CryptoContext")
expect_true(S7::S7_inherits(client_cc, CryptoContext))
public_key <- fhe_deserialize(public_key_location, "PublicKey")
expect_true(S7::S7_inherits(public_key, PublicKey))
secret_key <- fhe_deserialize(secret_key_location, "PrivateKey")
expect_true(S7::S7_inherits(secret_key, PrivateKey))
client_ciphertext <- fhe_deserialize(ciphertext_location, "Ciphertext")
expect_true(S7::S7_inherits(client_ciphertext, Ciphertext))

eval_bootstrap_setup(client_cc, level_budget, c(0L, 0L), num_slots)

expect_true(deserialize_eval_keys(mult_key_location, "mult"))

## No automorphism key is registered before the bootstrap keys are read.
expect_equal(
  length(get_existing_eval_automorphism_key_indices(get_key_tag(secret_key))),
  0L)
expect_true(deserialize_eval_bootstrap_key(bootstrap_key_location, client_cc,
                                           get_key_tag(secret_key), num_slots))

## The bootstrap keys can also be deserialized by an explicit list of
## automorphism indices. Here we take the indices of the keys just
## loaded and load the same file again through the by-index form.
bootstrap_key_indices <-
  get_existing_eval_automorphism_key_indices(get_key_tag(secret_key))
expect_equal(bootstrap_key_indices, server_key_indices)
expect_true(deserialize_eval_bootstrap_key(bootstrap_key_location,
                                           key_tag = get_key_tag(secret_key),
                                           index_list = bootstrap_key_indices))

ciphertext_after <- eval_bootstrap(client_ciphertext)

result <- decrypt(ciphertext_after, secret_key, cc = client_cc)
set_length(result, length(x))

## Input
expect_equal(get_real_packed_value(plaintext), x)
## Output after deserialized-key bootstrapping
expect_equal(get_real_packed_value(result), x, tolerance = 1e-4)

clear_static_maps_and_vectors()

unlink(datafolder, recursive = TRUE)
clear_fhe_state()
