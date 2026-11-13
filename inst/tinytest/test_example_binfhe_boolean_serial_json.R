## OPENFHE PYTHON SOURCE: examples/binfhe/boolean-serial-json.py
##
## @openfhe-python: boolean-serial-json.py [FULL]
##
## FHEW with JSON serialization: the context, the bootstrapping keys,
## the secret key and a ciphertext are written, read back and used.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: large JSON key files (runs on CI and at_home)")
}

## Path where files will be written to
tmpdir <- tempfile("binfhe-serial-json-")
dir.create(tmpdir)
datafolder <- file.path(tmpdir, "demoData")
dir.create(datafolder)

## Generating the crypto context
cc1 <- bin_fhe_context(BinFHEParamSet$TOY)

## Generating the secret key
sk1 <- bin_key_gen(cc1)

## Generate the bootstrapping keys
bin_bt_key_gen(cc1, sk1)

## Encryption for a ciphertext that will be serialized
ct1 <- bin_encrypt(cc1, sk1, 1L)

# ══ Code for serialization ═══════════════════════════════
## Serializing key-independent crypto context
expect_true(fhe_serialize(cc1, file.path(datafolder, "cryptoContext.txt"),
                          format = "json"))

## Serializing refreshing and key switching keys (needed for
## bootstrapping)
expect_true(fhe_serialize(get_bt_key(cc1), file.path(datafolder, "btKey.txt"),
                          format = "json"))

## Serializing private keys
expect_true(fhe_serialize(sk1, file.path(datafolder, "sk1.txt"),
                          format = "json"))

## Serializing a ciphertext
expect_true(fhe_serialize(ct1, file.path(datafolder, "ct1.txt"),
                          format = "json"))

# ══ Code for deserialization ═════════════════════════════
## Deserializing the cryptocontext
cc <- fhe_deserialize(file.path(datafolder, "cryptoContext.txt"),
                      "BinFHEContext", format = "json")
expect_true(S7::S7_inherits(cc, BinFHEContext))

## Deserializing the refreshing and switching keys (for bootstrapping)
bt_key <- fhe_deserialize(file.path(datafolder, "btKey.txt"), "RingGSWBTKey",
                          format = "json")
expect_true(S7::S7_inherits(bt_key, RingGSWBTKey))

## Loading the keys in the cryptocontext
bin_bt_key_load(cc, bt_key)

## Deserializing the secret key
sk <- fhe_deserialize(file.path(datafolder, "sk1.txt"), "LWEPrivateKey",
                      format = "json")
expect_true(S7::S7_inherits(sk, LWEPrivateKey))

## Deserializing a previously serialized ciphertext
ct <- fhe_deserialize(file.path(datafolder, "ct1.txt"), "LWECiphertext",
                      format = "json")
expect_true(S7::S7_inherits(ct, LWECiphertext))

# ══ Operations with deserialized keys and ciphertexts ════
ct2 <- bin_encrypt(cc, sk, 1L)

ct_result <- eval_bin_gate(cc, BinGate$AND, ct, ct2)

result <- bin_decrypt(cc, sk, ct_result)

## 1 AND 1
expect_identical(result, as.integer(1L && 1L))

unlink(tmpdir, recursive = TRUE)
