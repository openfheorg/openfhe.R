## OPENFHE PYTHON SOURCE: examples/pke/threshold-fhe-5p.py
##
## @openfhe-python: threshold-fhe-5p.py [FULL]
##
## Threshold FHE with five parties in BFV: joint multiplication and
## summation keys, an addition, a product of depth four and a sum over
## the slots, each decrypted by the five parties together and checked
## against the same computation in the clear.
library(openfhe.R)

plaintext_modulus <- 65537
sigma <- 3.2
security_level <- SecurityLevel$HEStd_128_classic

batch_size <- 16L
mult_depth <- 4L
digit_size <- 30L
dcrt_bits <- 60L

parameters <- BFVParams()
set_plaintext_modulus(parameters, plaintext_modulus)
set_security_level(parameters, security_level)
set_standard_deviation(parameters, sigma)
set_secret_key_dist(parameters, SecretKeyDist$UNIFORM_TERNARY)
set_multiplicative_depth(parameters, mult_depth)
set_batch_size(parameters, batch_size)
set_digit_size(parameters, digit_size)
set_scaling_mod_size(parameters, dcrt_bits)
set_threshold_num_of_parties(parameters, 5L)
set_multiplication_technique(parameters,
                             MultiplicationTechnique$HPSPOVERQLEVELED)

cc <- gen_crypto_context(parameters)
# Enable features you wish to use
enable_feature(cc, Feature$PKE)
enable_feature(cc, Feature$KEYSWITCH)
enable_feature(cc, Feature$LEVELEDSHE)
enable_feature(cc, Feature$ADVANCEDSHE)
enable_feature(cc, Feature$MULTIPARTY)

# Set-up of parameters: the generated parameters the example prints
expect_equal(as.numeric(get_plaintext_modulus(cc)), plaintext_modulus)
expect_equal(get_cyclotomic_order(cc) / 2, ring_dimension(cc))
expect_true(log2(as.numeric(get_modulus(cc))) > 0)

# Perform Key Generation Operation

# Round 1 (party A)
kp1 <- key_gen(cc)
kp2 <- multiparty_key_gen(cc, kp1@public)
kp3 <- multiparty_key_gen(cc, kp2@public)
kp4 <- multiparty_key_gen(cc, kp3@public)
kp5 <- multiparty_key_gen(cc, kp4@public)

tag2 <- get_key_tag(kp2@public)
tag3 <- get_key_tag(kp3@public)
tag4 <- get_key_tag(kp4@public)
tag5 <- get_key_tag(kp5@public)

# Generate evalmult key part for A
eval_mult_key <- key_switch_gen(cc, kp1@secret, kp1@secret)
eval_mult_key2 <- multi_key_switch_gen(cc, kp2@secret, kp2@secret, eval_mult_key)
eval_mult_key3 <- multi_key_switch_gen(cc, kp3@secret, kp3@secret, eval_mult_key)
eval_mult_key4 <- multi_key_switch_gen(cc, kp4@secret, kp4@secret, eval_mult_key)
eval_mult_key5 <- multi_key_switch_gen(cc, kp5@secret, kp5@secret, eval_mult_key)

eval_mult_ab <- multi_add_eval_keys(cc, eval_mult_key, eval_mult_key2, tag2)
eval_mult_abc <- multi_add_eval_keys(cc, eval_mult_ab, eval_mult_key3, tag3)
eval_mult_abcd <- multi_add_eval_keys(cc, eval_mult_abc, eval_mult_key4, tag4)
eval_mult_abcde <- multi_add_eval_keys(cc, eval_mult_abcd, eval_mult_key5, tag5)

eval_mult_eabcde <- multi_mult_eval_key(cc, kp5@secret, eval_mult_abcde, tag5)
eval_mult_dabcde <- multi_mult_eval_key(cc, kp4@secret, eval_mult_abcde, tag5)
eval_mult_cabcde <- multi_mult_eval_key(cc, kp3@secret, eval_mult_abcde, tag5)
eval_mult_babcde <- multi_mult_eval_key(cc, kp2@secret, eval_mult_abcde, tag5)
eval_mult_aabcde <- multi_mult_eval_key(cc, kp1@secret, eval_mult_abcde, tag5)

eval_mult_deabcde <- multi_add_eval_mult_keys(
  cc, eval_mult_eabcde, eval_mult_dabcde, get_key_tag(eval_mult_eabcde))
eval_mult_cdeabcde <- multi_add_eval_mult_keys(
  cc, eval_mult_cabcde, eval_mult_deabcde, get_key_tag(eval_mult_cabcde))
eval_mult_bcdeabcde <- multi_add_eval_mult_keys(
  cc, eval_mult_babcde, eval_mult_cdeabcde, get_key_tag(eval_mult_babcde))

eval_mult_final <- multi_add_eval_mult_keys(cc, eval_mult_aabcde,
                                            eval_mult_bcdeabcde, tag5)
insert_eval_mult_key(list(eval_mult_final))

# EvalSum Key Generation

# Generate evalsum key part for A
eval_sum_key_gen(cc, kp1@secret)
eval_sum_keys <- get_eval_sum_key_map(get_key_tag(kp1@secret))

eval_sum_keys_b <- multi_eval_sum_key_gen(cc, kp2@secret, eval_sum_keys, tag2)
eval_sum_keys_c <- multi_eval_sum_key_gen(cc, kp3@secret, eval_sum_keys, tag3)
eval_sum_keys_d <- multi_eval_sum_key_gen(cc, kp4@secret, eval_sum_keys, tag4)
eval_sum_keys_e <- multi_eval_sum_key_gen(cc, kp5@secret, eval_sum_keys, tag5)

eval_sum_keys_ab <- multi_add_eval_sum_keys(cc, eval_sum_keys, eval_sum_keys_b,
                                            tag2)
eval_sum_keys_abc <- multi_add_eval_sum_keys(cc, eval_sum_keys_c,
                                             eval_sum_keys_ab, tag3)
eval_sum_keys_abcd <- multi_add_eval_sum_keys(cc, eval_sum_keys_abc,
                                              eval_sum_keys_d, tag4)

eval_sum_keys_join <- multi_add_eval_sum_keys(cc, eval_sum_keys_e,
                                              eval_sum_keys_abcd, tag5)
insert_eval_sum_key(eval_sum_keys_join)

# Encode source data
vector_of_ints1 <- c(1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 0)
vector_of_ints2 <- c(1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0)
vector_of_ints3 <- c(2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 0)

plaintext1 <- make_packed_plaintext(cc, vector_of_ints1)
plaintext2 <- make_packed_plaintext(cc, vector_of_ints2)
plaintext3 <- make_packed_plaintext(cc, vector_of_ints3)

# Encryption
ciphertext1 <- encrypt(kp5@public, plaintext1, cc = cc)
ciphertext2 <- encrypt(kp5@public, plaintext2, cc = cc)
ciphertext3 <- encrypt(kp5@public, plaintext3, cc = cc)

# Homomorphic Operations
ciphertext_add12 <- eval_add(ciphertext1, ciphertext2)
ciphertext_add123 <- eval_add(ciphertext_add12, ciphertext3)

ciphertext_mult1 <- eval_mult(ciphertext1, ciphertext1)
ciphertext_mult2 <- eval_mult(ciphertext_mult1, ciphertext1)
ciphertext_mult3 <- eval_mult(ciphertext_mult2, ciphertext1)
ciphertext_mult <- eval_mult(ciphertext_mult3, ciphertext1)

ciphertext_eval_sum <- eval_sum(ciphertext3, batch_size)

# Decryption after Accumulation Operation on Encrypted Data with Multiparty

## Distributed decryption: a partial decryption by party A (the lead)
## and by each of the parties B, C, D and E, then the fusion.
five_party_decrypt <- function(ciphertext) {
  ciphertext_partial1 <- multiparty_decrypt_lead(cc, kp1@secret, list(ciphertext))
  ciphertext_partial2 <- multiparty_decrypt_main(cc, kp2@secret, list(ciphertext))
  ciphertext_partial3 <- multiparty_decrypt_main(cc, kp3@secret, list(ciphertext))
  ciphertext_partial4 <- multiparty_decrypt_main(cc, kp4@secret, list(ciphertext))
  ciphertext_partial5 <- multiparty_decrypt_main(cc, kp5@secret, list(ciphertext))
  multiparty_decrypt_fusion(
    cc, ciphertext_partial1[[1L]], ciphertext_partial2[[1L]],
    ciphertext_partial3[[1L]], ciphertext_partial4[[1L]],
    ciphertext_partial5[[1L]])
}

plaintext_multiparty_new <- five_party_decrypt(ciphertext_add123)

# Original Plaintext
expect_equal(as.numeric(get_packed_value(plaintext1)), vector_of_ints1)
expect_equal(as.numeric(get_packed_value(plaintext2)), vector_of_ints2)
expect_equal(as.numeric(get_packed_value(plaintext3)), vector_of_ints3)

n <- get_length(plaintext1)
set_length(plaintext_multiparty_new, n)

# Resulting Fused Plaintext
expect_equal(as.numeric(get_packed_value(plaintext_multiparty_new)),
             vector_of_ints1 + vector_of_ints2 + vector_of_ints3)

plaintext_multiparty_mult <- five_party_decrypt(ciphertext_mult)
set_length(plaintext_multiparty_mult, n)

# Resulting Fused Plaintext after Multiplication: the fifth power of
# plaintext 1
expect_equal(as.numeric(get_packed_value(plaintext_multiparty_mult)),
             vector_of_ints1^5)

plaintext_multiparty_eval_sum <- five_party_decrypt(ciphertext_eval_sum)
set_length(plaintext_multiparty_eval_sum, n)

# Fused result after the Summation of ciphertext 3: each slot holds the
# sum of the batch_size slots from it onward, and the slots after the
# data are zero.
expect_equal(as.numeric(get_packed_value(plaintext_multiparty_eval_sum)),
             rev(cumsum(rev(vector_of_ints3))))
