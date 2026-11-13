## OPENFHE PYTHON SOURCE: examples/binfhe/pke/boolean-truth-tables-pke.py
##
## @openfhe-python: boolean-truth-tables-pke.py [FULL]
##
## The truth tables of NAND, AND, OR, NOR, XOR and XNOR on bits
## encrypted under the public key.
library(openfhe.R)

## Skipped on CRAN: check time against the Windows budget (D022). Runs
## on GitHub Actions (which sets CI=true) and at home.
if (!at_home() && Sys.getenv("CI") != "true")
  exit_file("skipped on CRAN: check time (runs on CI and at_home)")

# ══ Step 1: Set CryptoContext ════════════════════════════
## STD128 is the security level of 128 bits of security based on the
## LWE Estimator and the HE standard.
cc <- bin_fhe_context(BinFHEParamSet$STD128)

# ══ Step 2: Key Generation ═══════════════════════════════
## Generate the secret key
sk <- bin_key_gen(cc)

## Generate the bootstrapping keys (refresh, switching and public keys)
bin_bt_key_gen(cc, sk, KeygenMode$PUB_ENCRYPT)

pk <- get_public_key(cc)

# ══ Step 3: Encryption ═══════════════════════════════════
## Encrypt two ciphertexts representing Boolean True (1)
ct10 <- bin_encrypt(cc, pk, 1L)
ct11 <- bin_encrypt(cc, pk, 1L)

## Encrypt two ciphertexts representing Boolean False (0)
ct00 <- bin_encrypt(cc, pk, 0L)
ct01 <- bin_encrypt(cc, pk, 0L)

## The four rows of each table, in the order of the example:
## (1, 1), (1, 0), (0, 0), (0, 1).
a <- c(1L, 1L, 0L, 0L)
b <- c(1L, 0L, 0L, 1L)
truth_table <- function(gate) {
  c(bin_decrypt(cc, sk, eval_bin_gate(cc, gate, ct10, ct11)),
    bin_decrypt(cc, sk, eval_bin_gate(cc, gate, ct10, ct01)),
    bin_decrypt(cc, sk, eval_bin_gate(cc, gate, ct00, ct01)),
    bin_decrypt(cc, sk, eval_bin_gate(cc, gate, ct00, ct11)))
}

# ══ Step 4: Evaluation of NAND gates ═════════════════════
expect_identical(truth_table(BinGate$NAND), as.integer(!(a & b)))

# ══ Step 5: Evaluation of AND gates ══════════════════════
expect_identical(truth_table(BinGate$AND), as.integer(a & b))

# ══ Step 6: Evaluation of OR gates ═══════════════════════
expect_identical(truth_table(BinGate$OR), as.integer(a | b))

# ══ Step 7: Evaluation of NOR gates ══════════════════════
expect_identical(truth_table(BinGate$NOR), as.integer(!(a | b)))

# ══ Step 8: Evaluation of XOR gates ══════════════════════
expect_identical(truth_table(BinGate$XOR), as.integer(xor(a, b)))

# ══ Step 9: Evaluation of XNOR gates ═════════════════════
expect_identical(truth_table(BinGate$XNOR), as.integer(!xor(a, b)))
