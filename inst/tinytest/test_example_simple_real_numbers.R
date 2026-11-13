## OPENFHE PYTHON SOURCE: examples/pke/simple-real-numbers.py
##
## @openfhe-python: simple-real-numbers.py [FULL]
##
## Addition, subtraction, scalar and ciphertext multiplication, and
## rotations of real vectors in CKKS, each checked against the same
## computation in the clear.
library(openfhe.R)

mult_depth <- 1L
scale_mod_size <- 50L
batch_size <- 8L

parameters <- CKKSParams()
set_multiplicative_depth(parameters, mult_depth)
set_scaling_mod_size(parameters, scale_mod_size)
set_batch_size(parameters, batch_size)

cc <- gen_crypto_context(parameters)
enable_feature(cc, Feature$PKE)
enable_feature(cc, Feature$KEYSWITCH)
enable_feature(cc, Feature$LEVELEDSHE)

# The CKKS scheme is using this ring dimension
ring_dim <- ring_dimension(cc)
expect_true(ring_dim >= 2L * batch_size)
expect_equal(log2(ring_dim), round(log2(ring_dim)))

keys <- key_gen(cc)
eval_mult_key_gen(cc, keys@secret)
eval_rotate_key_gen(cc, keys@secret, c(1L, -2L))

x1 <- c(0.25, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0)
x2 <- c(5.0, 4.0, 3.0, 2.0, 1.0, 0.75, 0.5, 0.25)

ptx1 <- make_ckks_packed_plaintext(cc, x1)
ptx2 <- make_ckks_packed_plaintext(cc, x2)

expect_equal(get_real_packed_value(ptx1), x1)
expect_equal(get_real_packed_value(ptx2), x2)

# Encrypt the encoded vectors
c1 <- encrypt(keys@public, ptx1, cc = cc)
c2 <- encrypt(keys@public, ptx2, cc = cc)

# Step 4: Evaluation
# Homomorphic additions
c_add <- eval_add(c1, c2)
# Homomorphic subtraction
c_sub <- eval_sub(c1, c2)
# Homomorphic scalar multiplication
c_scalar <- eval_mult(c1, 4)
# Homomorphic multiplication
c_mult <- eval_mult(c1, c2)
# Homomorphic rotations
c_rot1 <- eval_rotate(c1, 1L)
c_rot2 <- eval_rotate(c1, -2L)

# Step 5: Decryption and output
tol <- 1e-8

# Decrypt the result of additions
pt_add <- decrypt(c_add, keys@secret, cc = cc)
expect_equal(get_real_packed_value(pt_add)[seq_len(batch_size)], x1 + x2,
             tolerance = tol)

# The example sets the precision to 8 decimal digits for a nicer output.
precision <- 8L
result <- decrypt(c1, keys@secret, cc = cc)
set_length(result, batch_size)
formatted <- get_formatted_values(result, precision)
expect_true(is.character(formatted) && length(formatted) == 1L)
expect_true(nzchar(formatted))
expect_equal(get_real_packed_value(result), x1, tolerance = tol)

# Decrypt the result of scalar multiplication
result <- decrypt(c_scalar, keys@secret, cc = cc)
set_length(result, batch_size)
expect_equal(get_real_packed_value(result), 4 * x1, tolerance = tol)

# Decrypt the result of multiplication
result <- decrypt(c_mult, keys@secret, cc = cc)
set_length(result, batch_size)
expect_equal(get_real_packed_value(result), x1 * x2, tolerance = tol)

# Decrypt the result of rotations. The vectors fill all the slots, so
# the rotations are cyclic.
result <- decrypt(c_rot1, keys@secret, cc = cc)
set_length(result, batch_size)
expect_equal(get_real_packed_value(result), c(x1[-1L], x1[1L]),
             tolerance = tol)

result <- decrypt(c_rot2, keys@secret, cc = cc)
set_length(result, batch_size)
expect_equal(get_real_packed_value(result), c(x1[7:8], x1[1:6]),
             tolerance = tol)

# The example computes the difference without decrypting it; it is
# decrypted here so that the subtraction is checked too.
result <- decrypt(c_sub, keys@secret, cc = cc)
set_length(result, batch_size)
expect_equal(get_real_packed_value(result), x1 - x2, tolerance = tol)
