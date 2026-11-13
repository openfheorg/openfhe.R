## OPENFHE PYTHON SOURCE: examples/pke/simple-real-numbers-serial.py
##
## @openfhe-python: simple-real-numbers-serial.py [FULL]
##
## A server generates a CKKS context, keys and ciphertexts and writes
## them; a client reads them, computes, and writes its results and a
## ciphertext of its own; the server reads those and decrypts.
library(openfhe.R)

# Save-Load locations for keys
datafolder <- tempfile("demoData-")
dir.create(datafolder)
cc_location <- file.path(datafolder, "cryptocontext.txt")
pub_key_location <- file.path(datafolder, "key_pub.txt")    # Pub key
mult_key_location <- file.path(datafolder, "key_mult.txt")  # relinearization key
rot_key_location <- file.path(datafolder, "key_rot.txt")    # rotation key

# Save-load locations for RAW ciphertexts
cipher_one_location <- file.path(datafolder, "ciphertext1.txt")
cipher_two_location <- file.path(datafolder, "ciphertext2.txt")

# Save-load locations for evaluated ciphertexts
cipher_mult_location <- file.path(datafolder, "ciphertextMult.txt")
cipher_add_location <- file.path(datafolder, "ciphertextAdd.txt")
cipher_rot_location <- file.path(datafolder, "ciphertextRot.txt")
cipher_rot_neg_location <- file.path(datafolder, "ciphertextRotNegLocation.txt")
client_vector_location <- file.path(datafolder, "clientVectorFromClient.txt")

# ══ Part 1 and 2: the server sets up, encrypts and writes ═
## Simulates a server at startup where we generate a cryptocontext and
## keys, then generate some data (akin to loading raw data on an
## enclave) before encrypting the data.
server_setup_and_write <- function(mult_depth, scale_mod_size, batch_size) {
  parameters <- CKKSParams()
  set_multiplicative_depth(parameters, mult_depth)
  set_scaling_mod_size(parameters, scale_mod_size)
  set_batch_size(parameters, batch_size)

  server_cc <- gen_crypto_context(parameters)

  enable_feature(server_cc, Feature$PKE)
  enable_feature(server_cc, Feature$KEYSWITCH)
  enable_feature(server_cc, Feature$LEVELEDSHE)

  server_kp <- key_gen(server_cc)
  eval_mult_key_gen(server_cc, server_kp@secret)
  eval_rotate_key_gen(server_cc, server_kp@secret, c(1L, 2L, -1L, -2L))

  vec1 <- c(1.0, 2.0, 3.0, 4.0)
  vec2 <- c(12.5, 13.5, 14.5, 15.5)
  vec3 <- c(10.5, 11.5, 12.5, 13.5)

  server_p1 <- make_ckks_packed_plaintext(server_cc, vec1)
  server_p2 <- make_ckks_packed_plaintext(server_cc, vec2)
  server_p3 <- make_ckks_packed_plaintext(server_cc, vec3)

  server_c1 <- encrypt(server_kp@public, server_p1, cc = server_cc)
  server_c2 <- encrypt(server_kp@public, server_p2, cc = server_cc)
  server_c3 <- encrypt(server_kp@public, server_p3, cc = server_cc)

  ## Part 2: we serialize the cryptocontext, the public key, the
  ## relinearization (eval mult) keys, the rotation keys and some of
  ## the ciphertexts, all of them to files.
  expect_true(fhe_serialize(server_cc, cc_location, "binary"))
  expect_true(fhe_serialize(server_kp@public, pub_key_location, "binary"))
  expect_true(serialize_eval_keys(mult_key_location, "mult", "binary"))
  expect_true(serialize_eval_keys(rot_key_location, "automorphism", "binary"))
  expect_true(fhe_serialize(server_c1, cipher_one_location, "binary"))
  expect_true(fhe_serialize(server_c2, cipher_two_location, "binary"))

  list(cc = server_cc, kp = server_kp, vector_size = length(vec1))
}

# ══ Part 3: the client reads, computes and writes ════════
## Deserializes data from files, which simulates receiving data from a
## server after making a request, then processes the data by doing
## operations (multiplication, addition, rotation). It also creates an
## object and encrypts it before sending it off to the server to be
## decrypted.
client_process <- function() {
  clear_fhe_state("contexts")
  clear_eval_mult_keys()

  client_cc <- fhe_deserialize(cc_location, "CryptoContext", "binary")
  expect_true(S7::S7_inherits(client_cc, CryptoContext))

  ## We do NOT have a secret key. The client should not have access to
  ## this.
  client_public_key <- fhe_deserialize(pub_key_location, "PublicKey", "binary")
  expect_true(S7::S7_inherits(client_public_key, PublicKey))

  expect_true(deserialize_eval_keys(mult_key_location, "mult", "binary"))
  expect_true(deserialize_eval_keys(rot_key_location, "automorphism", "binary"))

  client_c1 <- fhe_deserialize(cipher_one_location, "Ciphertext", "binary")
  client_c2 <- fhe_deserialize(cipher_two_location, "Ciphertext", "binary")
  expect_true(S7::S7_inherits(client_c1, Ciphertext))
  expect_true(S7::S7_inherits(client_c2, Ciphertext))

  client_ciphertext_mult <- eval_mult(client_c1, client_c2)
  client_ciphertext_add <- eval_add(client_c1, client_c2)
  client_ciphertext_rot <- eval_rotate(client_c1, 1L)
  client_ciphertext_rot_neg <- eval_rotate(client_c1, -1L)

  ## Part 3.5: now we simulate a client who is encrypting data for the
  ## server to decrypt, e.g. weights of a machine learning algorithm.
  client_vector1 <- c(1.0, 2.0, 3.0, 4.0)
  client_plaintext1 <- make_ckks_packed_plaintext(client_cc, client_vector1)
  client_initialized_encryption <- encrypt(client_public_key, client_plaintext1,
                                           cc = client_cc)
  expect_true(fhe_serialize(client_ciphertext_mult, cipher_mult_location,
                            "binary"))
  expect_true(fhe_serialize(client_ciphertext_add, cipher_add_location,
                            "binary"))
  expect_true(fhe_serialize(client_ciphertext_rot, cipher_rot_location,
                            "binary"))
  expect_true(fhe_serialize(client_ciphertext_rot_neg, cipher_rot_neg_location,
                            "binary"))
  expect_true(fhe_serialize(client_initialized_encryption,
                            client_vector_location, "binary"))
}

# ══ Part 4 and 5: the server reads the results and decrypts ═
## Deserializes the data from the client and returns the plaintexts of
## the various operations.
server_verification <- function(cc, kp, vector_size) {
  ct_mult <- fhe_deserialize(cipher_mult_location, "Ciphertext", "binary")
  ct_add <- fhe_deserialize(cipher_add_location, "Ciphertext", "binary")
  ct_rot <- fhe_deserialize(cipher_rot_location, "Ciphertext", "binary")
  ct_rot_neg <- fhe_deserialize(cipher_rot_neg_location, "Ciphertext", "binary")
  ct_vec <- fhe_deserialize(client_vector_location, "Ciphertext", "binary")

  pt_mult <- decrypt(ct_mult, kp@secret, cc = cc)
  pt_add <- decrypt(ct_add, kp@secret, cc = cc)
  pt_rot <- decrypt(ct_rot, kp@secret, cc = cc)
  pt_rot_neg <- decrypt(ct_rot_neg, kp@secret, cc = cc)
  pt_vec <- decrypt(ct_vec, kp@secret, cc = cc)

  set_length(pt_mult, vector_size)
  set_length(pt_add, vector_size)
  set_length(pt_vec, vector_size)
  set_length(pt_rot, vector_size + 1L)
  set_length(pt_rot_neg, vector_size + 1L)

  list(mult = pt_mult, add = pt_add, vec = pt_vec, rot = pt_rot,
       rot_neg = pt_rot_neg)
}

# ── main ─────────────────────────────────────────────────
# Set main params
mult_depth <- 5L
scale_mod_size <- 40L
batch_size <- 32L

# Part 1: Cryptocontext generation, key generation, data encryption (server)
server <- server_setup_and_write(mult_depth, scale_mod_size, batch_size)

# Part 3: Client deserialize all data
client_process()

# Part 4: Server deserialization of data from client.
res <- server_verification(server$cc, server$kp, server$vector_size)

# vec1: [1,2,3,4]
# vec2: [12.5, 13.5, 14.5, 15.5]
tol <- 1e-6
expect_equal(get_real_packed_value(res$mult), c(12.5, 27.0, 43.5, 62),
             tolerance = tol)
expect_equal(get_real_packed_value(res$add), c(13.5, 15.5, 17.5, 19.5),
             tolerance = tol)
expect_equal(get_real_packed_value(res$vec), c(1, 2, 3, 4), tolerance = tol)

# Displaying 5 elements of a 4-element vector to illustrate rotation
rot_res <- get_real_packed_value(res$rot)          # [2, 3, 4, noise, noise]
expect_equal(length(rot_res), 5L)
expect_equal(rot_res[1:3], c(2, 3, 4), tolerance = tol)
expect_true(all(abs(rot_res[4:5]) < 1e-6))
rot_neg_res <- get_real_packed_value(res$rot_neg)  # [noise, 1, 2, 3, 4]
expect_equal(length(rot_neg_res), 5L)
expect_true(abs(rot_neg_res[1L]) < 1e-6)
expect_equal(rot_neg_res[2:5], c(1, 2, 3, 4), tolerance = tol)

unlink(datafolder, recursive = TRUE)
clear_fhe_state()
