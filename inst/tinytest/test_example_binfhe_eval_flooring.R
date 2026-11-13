## OPENFHE PYTHON SOURCE: examples/binfhe/eval-flooring.py
##
## @openfhe-python: eval-flooring.py [FULL]
##
## Homomorphic rounding down of an encrypted value by a number of bits.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

# ══ Step 1: Set CryptoContext ════════════════════════════
## The example calls GenerateBinFHEContext(STD128, False), the form
## that takes arbFunc, logQ = 11, N = 0, GINX; supplying `arb_func`
## selects it. Its lattice dimension differs from the table form's 554.
cc <- bin_fhe_context(BinFHEParamSet$STD128, arb_func = FALSE)
expect_identical(get_big_n(cc), 1024L)
expect_identical(get_n(cc), 1305L)

# ══ Step 2: Key Generation ═══════════════════════════════
## Generate the secret key
sk <- bin_key_gen(cc)

## Generate the bootstrapping keys (refresh and switching keys)
bin_bt_key_gen(cc, sk)

# ══ Step 3: Encryption ═══════════════════════════════════
## Obtain the maximum plaintext space
## With the default parameter, p = 8
p <- get_max_plaintext_space(cc)
expect_equal(p, 8)

## Number of bits to round down
bits <- 1L
input <- 6L

ct1 <- bin_encrypt(cc, sk, input %% p, BinFHEOutput$LARGE_DIM, p)

# ══ Step 4: Evaluation ═══════════════════════════════════
ct_rounded <- eval_floor(cc, ct1, bits)

# ══ Step 5: Decryption ═══════════════════════════════════
result <- bin_decrypt(cc, sk, ct_rounded, p %/% 2^bits)

## Expected: the input shifted right by `bits`
expect_identical(result, bitwShiftR(input, bits))

## Release the bootstrapping keys now: R's collector does not see the
## memory behind a context, so the keys would otherwise stay until a
## collection happens to run (notes/discoveries/D043).
bin_clear_bt_keys(cc)
