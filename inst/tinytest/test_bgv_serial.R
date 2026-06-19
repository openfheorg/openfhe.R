## Phase 8: BGV serialization round-trip with evaluation keys
## @openfhe-python: simple-integers-serial-bgvrns.py [FULL]
library(openfhe.R)

tmpdir <- tempdir()

# ── Setup: BGV context, keys (mult + rotations), three ciphertexts ───
cc <- fhe_context("BGV", plaintext_modulus = 65537, multiplicative_depth = 2)
keys <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, 2L, -1L, -2L))

v1 <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 10L, 11L, 12L)
v2 <- c(3L, 2L, 1L, 4L, 5L, 6L, 7L, 8L, 9L, 10L, 11L, 12L)
v3 <- c(1L, 2L, 5L, 2L, 5L, 6L, 7L, 8L, 9L, 10L, 11L, 12L)

ct1 <- encrypt(keys@public, make_packed_plaintext(cc, v1), cc = cc)
ct2 <- encrypt(keys@public, make_packed_plaintext(cc, v2), cc = cc)
ct3 <- encrypt(keys@public, make_packed_plaintext(cc, v3), cc = cc)

# ── Serialize context, keys, eval keys, ciphertexts ──────────────────
cc_file  <- file.path(tmpdir, "bgv_cc.bin")
pk_file  <- file.path(tmpdir, "bgv_pk.bin")
sk_file  <- file.path(tmpdir, "bgv_sk.bin")
mk_file  <- file.path(tmpdir, "bgv_mk.bin")
rk_file  <- file.path(tmpdir, "bgv_rk.bin")
ct1_file <- file.path(tmpdir, "bgv_ct1.bin")
ct2_file <- file.path(tmpdir, "bgv_ct2.bin")
ct3_file <- file.path(tmpdir, "bgv_ct3.bin")

expect_true(fhe_serialize(cc, cc_file))
expect_true(fhe_serialize(keys@public, pk_file))
expect_true(fhe_serialize(keys@secret, sk_file))
expect_true(serialize_eval_keys(mk_file, "mult"))
expect_true(serialize_eval_keys(rk_file, "automorphism"))
expect_true(fhe_serialize(ct1, ct1_file))
expect_true(fhe_serialize(ct2, ct2_file))
expect_true(fhe_serialize(ct3, ct3_file))

# ── Clear all state and deserialize into a fresh session ─────────────
clear_fhe_state()

cc2 <- fhe_deserialize(cc_file, "CryptoContext")
pk2 <- fhe_deserialize(pk_file, "PublicKey")
sk2 <- fhe_deserialize(sk_file, "PrivateKey")
expect_true(deserialize_eval_keys(mk_file, "mult"))
expect_true(deserialize_eval_keys(rk_file, "automorphism"))

ct1_2 <- fhe_deserialize(ct1_file, "Ciphertext")
ct2_2 <- fhe_deserialize(ct2_file, "Ciphertext")
ct3_2 <- fhe_deserialize(ct3_file, "Ciphertext")

# ── Homomorphic addition through deserialized context ───────────────
## @openfhe-python: simple-integers-serial-bgvrns.py — ct1 + ct2 + ct3
ct_add <- ct1_2 + ct2_2 + ct3_2
res_add <- decrypt(ct_add, sk2, cc = cc2)
set_length(res_add, 12L)
expect_identical(get_packed_value(res_add)[1:12], (v1 + v2 + v3) %% 65537L)

# ── Homomorphic multiplication through deserialized context ──────────
## @openfhe-python: simple-integers-serial-bgvrns.py — ct1 * ct2 * ct3
ct_mul <- ct1_2 * ct2_2 * ct3_2
res_mul <- decrypt(ct_mul, sk2, cc = cc2)
set_length(res_mul, 12L)
expect_identical(get_packed_value(res_mul)[1:12], (v1 * v2 * v3) %% 65537L)

# ── Rotations through deserialized automorphism keys ─────────────────
## @openfhe-python: simple-integers-serial-bgvrns.py — EvalRotate ±1, ±2
rot1  <- decrypt(eval_rotate(ct1_2,  1L), sk2, cc = cc2)
rot2  <- decrypt(eval_rotate(ct2_2,  2L), sk2, cc = cc2)
rotm1 <- decrypt(eval_rotate(ct3_2, -1L), sk2, cc = cc2)
rotm2 <- decrypt(eval_rotate(ct3_2, -2L), sk2, cc = cc2)

set_length(rot1,  12L)
set_length(rot2,  12L)
set_length(rotm1, 12L)
set_length(rotm2, 12L)

# Left rotation by 1: element i moves to position i-1
expect_identical(get_packed_value(rot1)[1:7], v1[2:8])
# Left rotation by 2
expect_identical(get_packed_value(rot2)[1:6], v2[3:8])
# Right rotation by 1: element i moves to position i+1
expect_identical(get_packed_value(rotm1)[2:8], v3[1:7])
# Right rotation by 2
expect_identical(get_packed_value(rotm2)[3:8], v3[1:6])

# ── Cleanup ──────────────────────────────────────────────────────────
unlink(c(cc_file, pk_file, sk_file, mk_file, rk_file,
         ct1_file, ct2_file, ct3_file))
