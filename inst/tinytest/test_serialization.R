## Phase 3: Serialization round-trip tests
## @openfhe-python: simple-integers-serial.py [FULL]
library(openfhe.R)

tmpdir <- tempdir()

# ── Setup: create context, keys, ciphertext ──────────────
cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2)
keys <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, -1L))

x <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L)
pt <- make_packed_plaintext(cc, x)
ct <- encrypt(keys@public, pt, cc = cc)

# ── Serialize all objects ────────────────────────────────
cc_file <- file.path(tmpdir, "cc.bin")
pk_file <- file.path(tmpdir, "pk.bin")
sk_file <- file.path(tmpdir, "sk.bin")
ct_file <- file.path(tmpdir, "ct.bin")
mk_file <- file.path(tmpdir, "mult_keys.bin")
rk_file <- file.path(tmpdir, "rot_keys.bin")

expect_true(fhe_serialize(cc, cc_file))
expect_true(fhe_serialize(keys@public, pk_file))
expect_true(fhe_serialize(keys@secret, sk_file))
expect_true(fhe_serialize(ct, ct_file))
expect_true(serialize_eval_keys(mk_file, "mult"))
expect_true(serialize_eval_keys(rk_file, "automorphism"))

# ── Clear all state ──────────────────────────────────────
clear_fhe_state()

# ── Deserialize ──────────────────────────────────────────
cc2 <- fhe_deserialize(cc_file, "CryptoContext")
expect_true(S7::S7_inherits(cc2, CryptoContext))

pk2 <- fhe_deserialize(pk_file, "PublicKey")
expect_true(S7::S7_inherits(pk2, PublicKey))

sk2 <- fhe_deserialize(sk_file, "PrivateKey")
expect_true(S7::S7_inherits(sk2, PrivateKey))

expect_true(deserialize_eval_keys(mk_file, "mult"))
expect_true(deserialize_eval_keys(rk_file, "automorphism"))

ct2 <- fhe_deserialize(ct_file, "Ciphertext")
expect_true(S7::S7_inherits(ct2, Ciphertext))

# ── Decrypt the deserialized ciphertext ──────────────────
result <- decrypt(ct2, sk2, cc = cc2)
set_length(result, 8L)
expect_identical(get_packed_value(result)[1:8], x)

# ── Cleanup ──────────────────────────────────────────────
unlink(c(cc_file, pk_file, sk_file, ct_file, mk_file, rk_file))
