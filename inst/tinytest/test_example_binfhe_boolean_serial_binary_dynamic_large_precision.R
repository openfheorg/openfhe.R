## OPENFHE PYTHON SOURCE: examples/binfhe/boolean-serial-binary-dynamic-large-precision.py
##
## @openfhe-python: boolean-serial-binary-dynamic-large-precision.py [FULL]
##
## FHEW with binary serialization for large-precision sign evaluation
## with dynamic bootstrapping keys.
library(openfhe.R)

## Skipped on CRAN: check time against the Windows budget (D022). Runs
## on GitHub Actions (which sets CI=true) and at home.
if (!at_home() && Sys.getenv("CI") != "true")
  exit_file("skipped on CRAN: check time (runs on CI and at_home)")

## Path where files will be written to
tmpdir <- tempfile("binfhe-serial-binary-dynamic-")
dir.create(tmpdir)
datafolder <- file.path(tmpdir, "demoData")
dir.create(datafolder)

## The name of the file of the bootstrapping key of one gadget base
map_key_file <- function(base_g) {
  file.path(datafolder,
            paste0(format(as.numeric(base_g), scientific = FALSE), "btKey.txt"))
}

## Generating the crypto context
log_q <- 17L
cc1 <- bin_fhe_context(BinFHEParamSet$TOY, arb_func = FALSE, log_q = log_q,
                       n = 0L, method = BinFHEMethod$GINX,
                       time_optimization = TRUE)
big_q <- 2^log_q

q <- 4096                                  # q
factor <- 2^(log_q - log2(q))              # Q/q
## Obtain the maximum plaintext space
p <- get_max_plaintext_space(cc1) * factor

## Generating the secret key
sk1 <- bin_key_gen(cc1)

## Generate the bootstrapping keys
bin_bt_key_gen(cc1, sk1)

## Encryption for a ciphertext that will be serialized
ct1 <- bin_encrypt(cc1, sk1, 1L)

# ══ Code for serialization ═══════════════════════════════
## Serializing key-independent crypto context
expect_true(fhe_serialize(cc1, file.path(datafolder, "cryptoContext.txt"),
                          format = "binary"))

## Serializing refreshing and key switching keys (needed for
## bootstrapping)
expect_true(fhe_serialize(get_bt_key(cc1), file.path(datafolder, "btKey.txt"),
                          format = "binary"))

bt_key_map <- get_bt_key_map(cc1)
for (index in names(bt_key_map)) {
  expect_true(fhe_serialize(bt_key_map[[index]], map_key_file(index),
                            format = "binary"))
}

## Serializing private keys
expect_true(fhe_serialize(sk1, file.path(datafolder, "sk1.txt"),
                          format = "binary"))

## Serializing a ciphertext
expect_true(fhe_serialize(ct1, file.path(datafolder, "ct1.txt"),
                          format = "binary"))

# ══ Code for deserialization ═════════════════════════════
## Deserializing the cryptocontext
cc <- fhe_deserialize(file.path(datafolder, "cryptoContext.txt"),
                      "BinFHEContext", format = "binary")
expect_true(S7::S7_inherits(cc, BinFHEContext))

## Deserializing the refreshing and switching keys (for bootstrapping)
bt_key <- fhe_deserialize(file.path(datafolder, "btKey.txt"), "RingGSWBTKey",
                          format = "binary")
expect_true(S7::S7_inherits(bt_key, RingGSWBTKey))

base_g_list <- c(2^14, 2^18, 2^27)
## The map of the first context holds exactly these gadget bases.
expect_equal(sort(as.numeric(names(bt_key_map))), base_g_list)

for (base_g in base_g_list) {
  map_key <- fhe_deserialize(map_key_file(base_g), "RingGSWBTKey",
                             format = "binary")
  expect_true(S7::S7_inherits(map_key, RingGSWBTKey))

  ## Loading the keys in the cryptocontext
  bin_bt_key_map_load_single_element(cc, base_g, map_key)
}

## Loading the keys in the cryptocontext
bin_bt_key_load(cc, bt_key)

## Deserializing the secret key
sk <- fhe_deserialize(file.path(datafolder, "sk1.txt"), "LWEPrivateKey",
                      format = "binary")
expect_true(S7::S7_inherits(sk, LWEPrivateKey))

## Deserializing a previously serialized ciphertext
ct <- fhe_deserialize(file.path(datafolder, "ct1.txt"), "LWECiphertext",
                      format = "binary")
expect_true(S7::S7_inherits(ct, LWECiphertext))

# ══ Operations with deserialized keys and ciphertexts ════
for (i in 0:7) {
  ## We first encrypt with large Q
  ct1 <- bin_encrypt(cc, sk, p %/% 2 + i - 3, BinFHEOutput$LARGE_DIM, p, big_q)

  ## Get the MSB
  ct1 <- eval_sign(cc, ct1)

  result <- bin_decrypt(cc, sk, ct1, 2L)
  ## Expected sign
  expect_identical(result, as.integer(i >= 3))
}

unlink(tmpdir, recursive = TRUE)

## Release the bootstrapping keys now: R's collector does not see the
## memory behind a context, so the keys would otherwise stay until a
## collection happens to run (notes/discoveries/D043).
bin_clear_bt_keys(cc1)
bin_clear_bt_keys(cc)
