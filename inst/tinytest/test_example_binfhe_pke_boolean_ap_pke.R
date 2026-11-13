## OPENFHE PYTHON SOURCE: examples/binfhe/pke/boolean-ap-pke.py
##
## @openfhe-python: boolean-ap-pke.py [FULL]
##
## Boolean gates on bits encrypted under the public key, with the AP
## bootstrapping method: (1 AND 1) OR (1 AND (NOT 1)).
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

# ══ Step 1: Set CryptoContext ════════════════════════════
## The second argument is the bootstrapping method (AP or GINX). The
## default method is GINX. Here we explicitly set AP. GINX typically
## provides better performance: the bootstrapping key is much smaller
## in GINX (by 20x) while the runtime is roughly the same.
cc <- bin_fhe_context(BinFHEParamSet$STD128, BinFHEMethod$AP)

# ══ Step 2: Key Generation ═══════════════════════════════
## Generate the secret key
sk <- bin_key_gen(cc)

## Generate the bootstrapping keys (refresh, switching and public
## keys). Public keys are generated when the keygen mode is set to
## PUB_ENCRYPT.
bin_bt_key_gen(cc, sk, KeygenMode$PUB_ENCRYPT)

pk <- get_public_key(cc)
expect_true(S7::S7_inherits(pk, LWEPublicKey))

# ══ Step 3: Encryption ═══════════════════════════════════
## Encrypt two ciphertexts representing Boolean True (1)
ct1 <- bin_encrypt(cc, pk, 1L)
ct2 <- bin_encrypt(cc, pk, 1L)

# ══ Step 4: Evaluation ═══════════════════════════════════
## Compute (1 AND 1) = 1; other binary gate options are OR, NAND, NOR
ct_and1 <- eval_bin_gate(cc, BinGate$AND, ct1, ct2)

## Compute (NOT 1) = 0
ct2_not <- eval_not(cc, ct2)

## Compute (1 AND (NOT 1)) = 0
ct_and2 <- eval_bin_gate(cc, BinGate$AND, ct2_not, ct1)

## Computes OR of the results in ct_and1 and ct_and2 = 1
ct_result <- eval_bin_gate(cc, BinGate$OR, ct_and1, ct_and2)

# ══ Step 5: Decryption ═══════════════════════════════════
result <- bin_decrypt(cc, sk, ct_result)

## (1 AND 1) OR (1 AND (NOT 1)) in the clear
expected <- as.integer((1L && 1L) || (1L && !1L))
expect_identical(result, expected)
