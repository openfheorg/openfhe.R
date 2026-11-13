## OPENFHE PYTHON SOURCE: examples/binfhe/pke/boolean-serial-binary-pke.py
##
## @openfhe-python: boolean-serial-binary-pke.py [FULL]
##
## FHEW with binary serialization and public key encryption: the
## context, the bootstrapping keys, both keys and a ciphertext are
## written, read back and used.
library(openfhe.R)

## Path where files will be written to
tmpdir <- tempfile("binfhe-serial-binary-pke-")
dir.create(tmpdir)
datafolder <- file.path(tmpdir, "demoData")
dir.create(datafolder)

## Generating the crypto context
cc1 <- bin_fhe_context(BinFHEParamSet$TOY)

## Generating the secret key
sk1 <- bin_key_gen(cc1)

## Generate the bootstrapping keys and public key
bin_bt_key_gen(cc1, sk1, KeygenMode$PUB_ENCRYPT)

## The example prints Q, N, q and n.
big_q <- get_big_q(cc1)
big_n <- get_big_n(cc1)
q <- get_q(cc1)
n <- get_n(cc1)
expect_true(is.numeric(big_q) && big_q > q)
expect_true(is.integer(big_n) && big_n > n)
expect_true(is.numeric(q) && q > 0)
expect_true(is.integer(n) && n > 0L)

pk1 <- get_public_key(cc1)

## Encryption for a ciphertext that will be serialized
ct1 <- bin_encrypt(cc1, pk1, 1L)

# ══ Code for serialization ═══════════════════════════════
## Serializing key-independent crypto context
expect_true(fhe_serialize(cc1, file.path(datafolder, "cryptoContext.txt"),
                          format = "binary"))

## Serializing refreshing and key switching keys (needed for
## bootstrapping)
expect_true(fhe_serialize(get_bt_key(cc1), file.path(datafolder, "btKey.txt"),
                          format = "binary"))

## Serializing secret key
expect_true(fhe_serialize(sk1, file.path(datafolder, "sk1.txt"),
                          format = "binary"))

## Serializing public key
expect_true(fhe_serialize(pk1, file.path(datafolder, "pk1.txt"),
                          format = "binary"))

## Serializing a ciphertext
expect_true(fhe_serialize(ct1, file.path(datafolder, "ct1.txt"),
                          format = "binary"))

# ══ Code for deserialization ═════════════════════════════
## Deserializing the cryptocontext
cc <- fhe_deserialize(file.path(datafolder, "cryptoContext.txt"),
                      "BinFHEContext", format = "binary")
expect_true(S7::S7_inherits(cc, BinFHEContext))
## The restored context has the parameters of the first one.
expect_identical(get_big_q(cc), big_q)
expect_identical(get_big_n(cc), big_n)
expect_identical(get_q(cc), q)
expect_identical(get_n(cc), n)

## Deserializing the refreshing and switching keys (for bootstrapping)
bt_key <- fhe_deserialize(file.path(datafolder, "btKey.txt"), "RingGSWBTKey",
                          format = "binary")
expect_true(S7::S7_inherits(bt_key, RingGSWBTKey))

## Loading the keys in the cryptocontext
bin_bt_key_load(cc, bt_key)

## Deserializing the secret key
sk <- fhe_deserialize(file.path(datafolder, "sk1.txt"), "LWEPrivateKey",
                      format = "binary")
expect_true(S7::S7_inherits(sk, LWEPrivateKey))

## Deserializing the public key
pk <- fhe_deserialize(file.path(datafolder, "pk1.txt"), "LWEPublicKey",
                      format = "binary")
expect_true(S7::S7_inherits(pk, LWEPublicKey))

## Deserializing a previously serialized ciphertext
ct <- fhe_deserialize(file.path(datafolder, "ct1.txt"), "LWECiphertext",
                      format = "binary")
expect_true(S7::S7_inherits(ct, LWECiphertext))

# ══ Operations with deserialized keys and ciphertexts ════
ct2 <- bin_encrypt(cc, pk, 1L)

ct_result <- eval_bin_gate(cc, BinGate$AND, ct, ct2)

result <- bin_decrypt(cc, sk, ct_result)

## 1 AND 1
expect_identical(result, as.integer(1L && 1L))

unlink(tmpdir, recursive = TRUE)
