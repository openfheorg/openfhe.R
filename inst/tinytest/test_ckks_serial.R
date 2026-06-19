## Phase 8: CKKS serialization round-trip
## @openfhe-python: simple-real-numbers-serial.py [FULL]
library(openfhe.R)

tmpdir <- tempdir()

cc <- fhe_context("CKKS", multiplicative_depth = 1L,
  scaling_mod_size = 50L, batch_size = 8L)
keys <- key_gen(cc, eval_mult = TRUE)

x <- c(0.25, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0)
pt <- make_ckks_packed_plaintext(cc, x)
ct <- encrypt(keys@public, pt, cc = cc)

## @openfhe-python: simple-real-numbers-serial.py — serialize
cc_f <- file.path(tmpdir, "ckks_cc.bin")
pk_f <- file.path(tmpdir, "ckks_pk.bin")
sk_f <- file.path(tmpdir, "ckks_sk.bin")
ct_f <- file.path(tmpdir, "ckks_ct.bin")
mk_f <- file.path(tmpdir, "ckks_mk.bin")

expect_true(fhe_serialize(cc, cc_f))
expect_true(fhe_serialize(keys@public, pk_f))
expect_true(fhe_serialize(keys@secret, sk_f))
expect_true(fhe_serialize(ct, ct_f))
expect_true(serialize_eval_keys(mk_f, "mult"))

## @openfhe-python: simple-real-numbers-serial.py — clear + deserialize
clear_fhe_state()

cc2 <- fhe_deserialize(cc_f, "CryptoContext")
sk2 <- fhe_deserialize(sk_f, "PrivateKey")
expect_true(deserialize_eval_keys(mk_f, "mult"))
ct2 <- fhe_deserialize(ct_f, "Ciphertext")

## @openfhe-python: simple-real-numbers-serial.py — decrypt after deserialize
result <- decrypt(ct2, sk2, cc = cc2)
set_length(result, 8L)
expect_equal(get_real_packed_value(result)[1:8], x, tolerance = 1e-6)

unlink(c(cc_f, pk_f, sk_f, ct_f, mk_f))
