## OPENFHE PYTHON SOURCE: examples/binfhe/pke/boolean-pke.py
##
## @openfhe-python: boolean-pke.py [FULL]
##
## Boolean gates on bits encrypted under the public key:
## (1 AND 1) OR (1 AND (NOT 1)), with every intermediate value checked.
library(openfhe.R)

# ══ Step 1: Set CryptoContext ════════════════════════════
## STD128 is the security level of 128 bits of security based on the
## LWE Estimator and the HE standard.
cc <- bin_fhe_context(BinFHEParamSet$STD128)

## Verifying public key encrypt and decrypt without bootstrap
## Generate the secret, public key pair
kp <- bin_key_gen_pair(cc)

## LARGE_DIM specifies the dimension of the output ciphertext
ctp <- bin_encrypt(cc, kp@public, 1L, BinFHEOutput$LARGE_DIM)

## Decryption check before computation
result <- bin_decrypt(cc, kp@secret, ctp)
expect_identical(result, 1L)

# ══ Step 2: Key Generation ═══════════════════════════════
## Generate the secret key
sk <- bin_key_gen(cc)

## Generate the bootstrapping keys (refresh, switching and public keys)
bin_bt_key_gen(cc, sk, KeygenMode$PUB_ENCRYPT)

# ══ Step 3: Encryption ═══════════════════════════════════
## Encrypt two ciphertexts representing Boolean True (1).
ct1 <- bin_encrypt(cc, get_public_key(cc), 1L)
ct2 <- bin_encrypt(cc, get_public_key(cc), 1L)

## Decryption check before computation
result <- bin_decrypt(cc, sk, ct1)
expect_identical(result, 1L)

# ══ Step 4: Evaluation ═══════════════════════════════════
## Compute (1 AND 1) = 1; other binary gate options are OR, NAND, NOR
ct_and1 <- eval_bin_gate(cc, BinGate$AND, ct1, ct2)

result1 <- bin_decrypt(cc, sk, ct_and1)
expect_identical(result1, as.integer(1L && 1L))

## Compute (NOT 1) = 0
ct2_not <- eval_not(cc, ct2)

result <- bin_decrypt(cc, sk, ct2_not)
expect_identical(result, as.integer(!1L))

## Compute (1 AND (NOT 1)) = 0
ct_and2 <- eval_bin_gate(cc, BinGate$AND, ct2_not, ct1)

result <- bin_decrypt(cc, sk, ct_and2)
expect_identical(result, as.integer(1L && !1L))

## Computes OR of the results in ct_and1 and ct_and2 = 1
ct_result <- eval_bin_gate(cc, BinGate$OR, ct_and1, ct_and2)

# ══ Step 5: Decryption ═══════════════════════════════════
result <- bin_decrypt(cc, sk, ct_result)
## (1 AND 1) OR (1 AND (NOT 1)) in the clear
expect_identical(result, as.integer((1L && 1L) || (1L && !1L)))

## Release the bootstrapping keys now: R's collector does not see the
## memory behind a context, so the keys would otherwise stay until a
## collection happens to run (notes/discoveries/D043).
bin_clear_bt_keys(cc)
