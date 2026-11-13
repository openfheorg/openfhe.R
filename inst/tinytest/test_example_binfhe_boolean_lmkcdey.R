## OPENFHE PYTHON SOURCE: examples/binfhe/boolean-lmkcdey.py
##
## @openfhe-python: boolean-lmkcdey.py [FULL]
##
## Boolean gates on encrypted bits with the LMKCDEY bootstrapping
## method: (1 AND 1) OR (1 AND (NOT 1)).
library(openfhe.R)

# ══ Step 1: Set CryptoContext ════════════════════════════
## We use the STD128 setting optimized for the LMKCDEY mode.
cc <- bin_fhe_context(BinFHEParamSet$STD128, BinFHEMethod$LMKCDEY)

# ══ Step 2: Key Generation ═══════════════════════════════
## Generate the secret key
sk <- bin_key_gen(cc)

## Generate the bootstrapping keys (refresh and switching keys)
bin_bt_key_gen(cc, sk)

# ══ Step 3: Encryption ═══════════════════════════════════
## Encrypt two ciphertexts representing Boolean True (1). By default,
## freshly encrypted ciphertexts are bootstrapped.
ct1 <- bin_encrypt(cc, sk, 1L)
ct2 <- bin_encrypt(cc, sk, 1L)

# ══ Step 4: Evaluation ═══════════════════════════════════
## Compute (1 AND 1) = 1; other binary gate options are OR, NAND, NOR
ct_and1 <- eval_bin_gate(cc, BinGate$AND, ct1, ct2)

## Compute (NOT 1) = 0
ct2_not <- eval_not(cc, ct2)

## Compute (1 AND (NOT 1)) = 0
ct_and2 <- eval_bin_gate(cc, BinGate$AND, ct2_not, ct1)

## Compute OR of the result in ct_and1 and ct_and2
ct_result <- eval_bin_gate(cc, BinGate$OR, ct_and1, ct_and2)

# ══ Step 5: Decryption ═══════════════════════════════════
result <- bin_decrypt(cc, sk, ct_result)

## (1 AND 1) OR (1 AND (NOT 1)) in the clear
expected <- as.integer((1L && 1L) || (1L && !1L))
expect_identical(result, expected)

## Release the bootstrapping keys now: R's collector does not see the
## memory behind a context, so the keys would otherwise stay until a
## collection happens to run (notes/discoveries/D043).
bin_clear_bt_keys(cc)
