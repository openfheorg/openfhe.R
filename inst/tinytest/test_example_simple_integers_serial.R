## OPENFHE PYTHON SOURCE: examples/pke/simple-integers-serial.py
##
## @openfhe-python: simple-integers-serial.py [FULL]
##
## The BFV integer example with serialization: the context, the keys
## and the ciphertexts are written to files, the registries are
## cleared, and everything is read back before the evaluation.
library(openfhe.R)

datafolder <- tempfile("demoData-")
dir.create(datafolder)
ser_type <- "binary"  # "binary" or "json"

# Sample Program: Step 1: Set CryptoContext
parameters <- BFVParams()
set_plaintext_modulus(parameters, 65537)
set_multiplicative_depth(parameters, 2L)

crypto_context <- gen_crypto_context(parameters)
# Enable features that you wish to use
enable_feature(crypto_context, Feature$PKE)
enable_feature(crypto_context, Feature$KEYSWITCH)
enable_feature(crypto_context, Feature$LEVELEDSHE)

# Serialize cryptocontext
expect_true(fhe_serialize(crypto_context,
                          file.path(datafolder, "cryptocontext.txt"), ser_type))

# Sample Program: Step 2: Key Generation

# Generate a public/private key pair
keypair <- key_gen(crypto_context)

# Serialize the public key
expect_true(fhe_serialize(keypair@public,
                          file.path(datafolder, "key-public.txt"), ser_type))

# Serialize the secret key
expect_true(fhe_serialize(keypair@secret,
                          file.path(datafolder, "key-private.txt"), ser_type))

# Generate the relinearization key
eval_mult_key_gen(crypto_context, keypair@secret)

# Serialize the relinearization key
expect_true(serialize_eval_keys(file.path(datafolder, "key-eval-mult.txt"),
                                "mult", ser_type))

# Generate the rotation evaluation keys
eval_rotate_key_gen(crypto_context, keypair@secret, c(1L, 2L, -1L, -2L))

# Serialize the rotation evaluation keys
expect_true(serialize_eval_keys(file.path(datafolder, "key-eval-rot.txt"),
                                "automorphism", ser_type))

# Sample Program: Step 3: Encryption

# First plaintext vector is encoded
vector_of_ints1 <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
plaintext1 <- make_packed_plaintext(crypto_context, vector_of_ints1)

# Second plaintext vector is encoded
vector_of_ints2 <- c(3, 2, 1, 4, 5, 6, 7, 8, 9, 10, 11, 12)
plaintext2 <- make_packed_plaintext(crypto_context, vector_of_ints2)

# Third plaintext vector is encoded
vector_of_ints3 <- c(1, 2, 5, 2, 5, 6, 7, 8, 9, 10, 11, 12)
plaintext3 <- make_packed_plaintext(crypto_context, vector_of_ints3)

# The encoded vectors are encrypted
ciphertext1 <- encrypt(keypair@public, plaintext1, cc = crypto_context)
ciphertext2 <- encrypt(keypair@public, plaintext2, cc = crypto_context)
ciphertext3 <- encrypt(keypair@public, plaintext3, cc = crypto_context)

expect_true(fhe_serialize(ciphertext1,
                          file.path(datafolder, "ciphertext1.txt"), ser_type))
expect_true(fhe_serialize(ciphertext2,
                          file.path(datafolder, "ciphertext2.txt"), ser_type))
expect_true(fhe_serialize(ciphertext3,
                          file.path(datafolder, "ciphertext3.txt"), ser_type))

# Sample Program: Step 4: Evaluation

# OpenFHE maintains an internal map of CryptoContext objects which are
# indexed by a tag and the tag is applied to both the CryptoContext and some
# of the keys. When deserializing a context, OpenFHE checks for the tag and
# if it finds it in the CryptoContext map, it will return the stored version.
# Hence, we need to clear the context and clear the keys.
clear_eval_mult_keys()
clear_eval_automorphism_keys()
clear_fhe_state("contexts")

# Deserialize the crypto context
cc <- fhe_deserialize(file.path(datafolder, "cryptocontext.txt"),
                      "CryptoContext", ser_type)
expect_true(S7::S7_inherits(cc, CryptoContext))

# Deserialize the public key
pk <- fhe_deserialize(file.path(datafolder, "key-public.txt"), "PublicKey",
                      ser_type)
expect_true(S7::S7_inherits(pk, PublicKey))

expect_true(deserialize_eval_keys(file.path(datafolder, "key-eval-mult.txt"),
                                  "mult", ser_type))
expect_true(deserialize_eval_keys(file.path(datafolder, "key-eval-rot.txt"),
                                  "automorphism", ser_type))

# Deserialize the ciphertexts
ct1 <- fhe_deserialize(file.path(datafolder, "ciphertext1.txt"), "Ciphertext",
                       ser_type)
ct2 <- fhe_deserialize(file.path(datafolder, "ciphertext2.txt"), "Ciphertext",
                       ser_type)
ct3 <- fhe_deserialize(file.path(datafolder, "ciphertext3.txt"), "Ciphertext",
                       ser_type)
expect_true(S7::S7_inherits(ct1, Ciphertext))
expect_true(S7::S7_inherits(ct2, Ciphertext))
expect_true(S7::S7_inherits(ct3, Ciphertext))

# Homomorphic addition
ciphertext_add12 <- eval_add(ct1, ct2)
ciphertext_add_result <- eval_add(ciphertext_add12, ct3)

# Homomorphic multiplication
ciphertext_mult12 <- eval_mult(ct1, ct2)
ciphertext_mult_result <- eval_mult(ciphertext_mult12, ct3)

# Homomorphic rotation
ciphertext_rot1 <- eval_rotate(ct1, 1L)
ciphertext_rot2 <- eval_rotate(ct2, 2L)
ciphertext_rot3 <- eval_rotate(ct3, -1L)
ciphertext_rot4 <- eval_rotate(ct3, -2L)

# Sample Program: Step 5: Decryption

sk <- fhe_deserialize(file.path(datafolder, "key-private.txt"), "PrivateKey",
                      ser_type)
expect_true(S7::S7_inherits(sk, PrivateKey))

# Decrypt the result of additions
plaintext_add_result <- decrypt(ciphertext_add_result, sk, cc = cc)

# Decrypt the result of multiplications
plaintext_mult_result <- decrypt(ciphertext_mult_result, sk, cc = cc)

# Decrypt the result of rotations
plaintext_rot1 <- decrypt(ciphertext_rot1, sk, cc = cc)
plaintext_rot2 <- decrypt(ciphertext_rot2, sk, cc = cc)
plaintext_rot3 <- decrypt(ciphertext_rot3, sk, cc = cc)
plaintext_rot4 <- decrypt(ciphertext_rot4, sk, cc = cc)

# Shows only the same number of elements as in the original plaintext vector
# By default it will show all coefficients in the BFV-encoded polynomial
n <- length(vector_of_ints1)
set_length(plaintext_rot1, n)
set_length(plaintext_rot2, n)
set_length(plaintext_rot3, n)
set_length(plaintext_rot4, n)

# Results of homomorphic computations
# #1 + #2 + #3
expect_equal(as.numeric(get_packed_value(plaintext_add_result))[seq_len(n)],
             vector_of_ints1 + vector_of_ints2 + vector_of_ints3)
# #1 * #2 * #3
expect_equal(as.numeric(get_packed_value(plaintext_mult_result))[seq_len(n)],
             vector_of_ints1 * vector_of_ints2 * vector_of_ints3)
# Left rotation of #1 by 1
expect_equal(as.numeric(get_packed_value(plaintext_rot1)),
             c(vector_of_ints1[-1L], 0))
# Left rotation of #2 by 2
expect_equal(as.numeric(get_packed_value(plaintext_rot2)),
             c(vector_of_ints2[-(1:2)], 0, 0))
# Right rotation of #3 by 1
expect_equal(as.numeric(get_packed_value(plaintext_rot3)),
             c(0, vector_of_ints3[-n]))
# Right rotation of #3 by 2
expect_equal(as.numeric(get_packed_value(plaintext_rot4)),
             c(0, 0, vector_of_ints3[-c(n - 1L, n)]))

unlink(datafolder, recursive = TRUE)
clear_fhe_state()
