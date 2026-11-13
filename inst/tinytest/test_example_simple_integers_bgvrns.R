## OPENFHE PYTHON SOURCE: examples/pke/simple-integers-bgvrns.py
##
## @openfhe-python: simple-integers-bgvrns.py [FULL]
##
## Additions, multiplications and rotations of packed integer vectors
## in BGV, each checked against the same computation in the clear.
library(openfhe.R)

# Sample Program: Step 1: Set CryptoContext
parameters <- BGVParams()
set_plaintext_modulus(parameters, 65537)
set_multiplicative_depth(parameters, 2L)

crypto_context <- gen_crypto_context(parameters)
# Enable features that you wish to use
enable_feature(crypto_context, Feature$PKE)
enable_feature(crypto_context, Feature$KEYSWITCH)
enable_feature(crypto_context, Feature$LEVELEDSHE)

# Sample Program: Step 2: Key Generation

# Generate a public/private key pair
key_pair <- key_gen(crypto_context)

# Generate the relinearization key
eval_mult_key_gen(crypto_context, key_pair@secret)

# Generate the rotation evaluation keys
eval_rotate_key_gen(crypto_context, key_pair@secret, c(1L, 2L, -1L, -2L))

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
ciphertext1 <- encrypt(key_pair@public, plaintext1, cc = crypto_context)
ciphertext2 <- encrypt(key_pair@public, plaintext2, cc = crypto_context)
ciphertext3 <- encrypt(key_pair@public, plaintext3, cc = crypto_context)

# Sample Program: Step 4: Evaluation

# Homomorphic additions
ciphertext_add12 <- eval_add(ciphertext1, ciphertext2)
ciphertext_add_result <- eval_add(ciphertext_add12, ciphertext3)

# Homomorphic Multiplication
ciphertext_mult12 <- eval_mult(ciphertext1, ciphertext2)
ciphertext_mult_result <- eval_mult(ciphertext_mult12, ciphertext3)

# Homomorphic Rotations
ciphertext_rot1 <- eval_rotate(ciphertext1, 1L)
ciphertext_rot2 <- eval_rotate(ciphertext1, 2L)
ciphertext_rot3 <- eval_rotate(ciphertext1, -1L)
ciphertext_rot4 <- eval_rotate(ciphertext1, -2L)

# Sample Program: Step 5: Decryption

# Decrypt the result of additions
plaintext_add_result <- decrypt(ciphertext_add_result, key_pair@secret,
                                cc = crypto_context)

# Decrypt the result of multiplications
plaintext_mult_result <- decrypt(ciphertext_mult_result, key_pair@secret,
                                 cc = crypto_context)

# Decrypt the result of rotations
plaintext_rot1 <- decrypt(ciphertext_rot1, key_pair@secret, cc = crypto_context)
plaintext_rot2 <- decrypt(ciphertext_rot2, key_pair@secret, cc = crypto_context)
plaintext_rot3 <- decrypt(ciphertext_rot3, key_pair@secret, cc = crypto_context)
plaintext_rot4 <- decrypt(ciphertext_rot4, key_pair@secret, cc = crypto_context)

n <- length(vector_of_ints1)
set_length(plaintext_rot1, n)
set_length(plaintext_rot2, n)
set_length(plaintext_rot3, n)
set_length(plaintext_rot4, n)

expect_equal(as.numeric(get_packed_value(plaintext1)), vector_of_ints1)
expect_equal(as.numeric(get_packed_value(plaintext2)), vector_of_ints2)
expect_equal(as.numeric(get_packed_value(plaintext3)), vector_of_ints3)

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
# Left rotation of #1 by 2
expect_equal(as.numeric(get_packed_value(plaintext_rot2)),
             c(vector_of_ints1[-(1:2)], 0, 0))
# Right rotation of #1 by 1
expect_equal(as.numeric(get_packed_value(plaintext_rot3)),
             c(0, vector_of_ints1[-n]))
# Right rotation of #1 by 2
expect_equal(as.numeric(get_packed_value(plaintext_rot4)),
             c(0, 0, vector_of_ints1[-c(n - 1L, n)]))
