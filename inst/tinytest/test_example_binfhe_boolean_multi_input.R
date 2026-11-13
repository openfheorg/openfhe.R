## OPENFHE PYTHON SOURCE: examples/binfhe/boolean-multi-input.py
##
## @openfhe-python: boolean-multi-input.py [FULL]
##
## Gates of three and four inputs: AND3, OR3, MAJORITY, CMUX, AND4 and
## OR4.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

# ══ Step 1: Set CryptoContext ════════════════════════════
cc <- bin_fhe_context(BinFHEParamSet$STD128_4, BinFHEMethod$GINX)

# ══ Step 2: Key Generation ═══════════════════════════════
## Generate the secret key
sk <- bin_key_gen(cc)

## Generate the bootstrapping keys (refresh and switching keys)
bin_bt_key_gen(cc, sk)

# ══ Step 3: Encryption ═══════════════════════════════════
## Encrypt several ciphertexts representing Boolean True (1) or
## False (0). The plaintext modulus is set higher than 4, to
## 2 * num_of_inputs.
p <- 6L
ct1_3input <- bin_encrypt(cc, sk, 1L, BinFHEOutput$SMALL_DIM, p)
ct2_3input <- bin_encrypt(cc, sk, 1L, BinFHEOutput$SMALL_DIM, p)
ct3_3input <- bin_encrypt(cc, sk, 0L, BinFHEOutput$SMALL_DIM, p)

## 1, 1, 0
ct123 <- list(ct1_3input, ct2_3input, ct3_3input)

## 1, 1, 0
ct_and3 <- eval_bin_gate(cc, BinGate$AND3, ct123)

## 1, 1, 0
ct_or3 <- eval_bin_gate(cc, BinGate$OR3, ct123)

# ══ Step 5: Decryption ═══════════════════════════════════
## AND(1, 1, 0)
expect_identical(bin_decrypt(cc, sk, ct_and3, p), as.integer(all(c(1, 1, 0) == 1)))
## OR(1, 1, 0)
expect_identical(bin_decrypt(cc, sk, ct_or3, p), as.integer(any(c(1, 1, 0) == 1)))

## The majority gate and CMUX for 3 inputs do not need a higher
## plaintext modulus.
p <- 4L
ct1_3input_p4 <- bin_encrypt(cc, sk, 1L, BinFHEOutput$SMALL_DIM, p)
ct2_3input_p4 <- bin_encrypt(cc, sk, 1L, BinFHEOutput$SMALL_DIM, p)
ct3_3input_p4 <- bin_encrypt(cc, sk, 0L, BinFHEOutput$SMALL_DIM, p)
ct4_3input_p4 <- bin_encrypt(cc, sk, 0L, BinFHEOutput$SMALL_DIM, p)

## 1, 1, 0
ct123_p4 <- list(ct1_3input_p4, ct2_3input_p4, ct3_3input_p4)

## 1, 0, 0
ct134_p4 <- list(ct1_3input_p4, ct3_3input_p4, ct4_3input_p4)

## 1, 0, 1
ct132_p4 <- list(ct1_3input_p4, ct3_3input_p4, ct2_3input_p4)

## 1, 1, 0
ct_majority <- eval_bin_gate(cc, BinGate$MAJORITY, ct123_p4)

## 1, 0, 1
ct_cmux0 <- eval_bin_gate(cc, BinGate$CMUX, ct132_p4)

## 1, 0, 0
ct_cmux1 <- eval_bin_gate(cc, BinGate$CMUX, ct134_p4)

## Majority(1, 1, 0)
expect_identical(bin_decrypt(cc, sk, ct_majority), as.integer(sum(c(1, 1, 0)) >= 2))

## CMUX takes the first input when the third is 0 and the second input
## when the third is 1.
cmux <- function(x) if (x[3L] == 0L) x[1L] else x[2L]
## CMUX(1, 0, 0) = 1
expect_identical(bin_decrypt(cc, sk, ct_cmux1), cmux(c(1L, 0L, 0L)))
## CMUX(1, 0, 1) = 0
expect_identical(bin_decrypt(cc, sk, ct_cmux0), cmux(c(1L, 0L, 1L)))

## For 4 input gates
p <- 8L
ct1_4input <- bin_encrypt(cc, sk, 1L, BinFHEOutput$SMALL_DIM, p)
ct2_4input <- bin_encrypt(cc, sk, 0L, BinFHEOutput$SMALL_DIM, p)
ct3_4input <- bin_encrypt(cc, sk, 0L, BinFHEOutput$SMALL_DIM, p)
ct4_4input <- bin_encrypt(cc, sk, 0L, BinFHEOutput$SMALL_DIM, p)

## 1, 0, 0, 0
ct1234 <- list(ct1_4input, ct2_4input, ct3_4input, ct4_4input)

# ══ Step 4: Evaluation ═══════════════════════════════════
## 1, 0, 0, 0
ct_and4 <- eval_bin_gate(cc, BinGate$AND4, ct1234)

## 1, 0, 0, 0
ct_or4 <- eval_bin_gate(cc, BinGate$OR4, ct1234)

# ══ Step 5: Decryption ═══════════════════════════════════
## AND(1, 0, 0, 0)
expect_identical(bin_decrypt(cc, sk, ct_and4, p),
                 as.integer(all(c(1, 0, 0, 0) == 1)))
## OR(1, 0, 0, 0)
expect_identical(bin_decrypt(cc, sk, ct_or4, p),
                 as.integer(any(c(1, 0, 0, 0) == 1)))

## Release the bootstrapping keys now: R's collector does not see the
## memory behind a context, so the keys would otherwise stay until a
## collection happens to run (notes/discoveries/D043).
bin_clear_bt_keys(cc)
