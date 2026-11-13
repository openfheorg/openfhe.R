## OPENFHE PYTHON SOURCE: examples/binfhe/pke/eval-function-pke.py
##
## @openfhe-python: eval-function-pke.py [FULL]
##
## An arbitrary function, x^3 mod p, evaluated through a look-up table
## on values encrypted under the public key.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

# ══ Step 1: Set CryptoContext ════════════════════════════
cc <- bin_fhe_context(BinFHEParamSet$STD128, arb_func = TRUE, log_q = 12L)

# ══ Step 2: Key Generation ═══════════════════════════════
## Generate the secret key
sk <- bin_key_gen(cc)

## Generate the bootstrapping keys (refresh, switching and public keys)
bin_bt_key_gen(cc, sk, KeygenMode$PUB_ENCRYPT)

pk <- get_public_key(cc)

# ══ Step 3: The function and its look-up table ═══════════
## Obtain the maximum plaintext space
p <- get_max_plaintext_space(cc)

## Initialize Function f(x) = x^3 % p
fp <- function(m, p1) {
  ifelse(m < p1, m^3 %% p1, (m - p1 %/% 2)^3 %% p1)
}

## Generate LUT from function f(x)
lut <- generate_lut_via_function(fp, p)
expect_equal(lut, (seq_len(p) - 1)^3 %% p)

# ══ Step 4: Evaluate f(x) homomorphically and decrypt ════
## Note that we check for all the possible plaintexts.
for (i in seq_len(p) - 1) {
  ct1 <- bin_encrypt(cc, pk, i %% p, BinFHEOutput$SMALL_DIM, p)

  ct_cube <- eval_func(cc, ct1, lut)

  result <- bin_decrypt(cc, sk, ct_cube, p)

  expect_equal(result, fp(i, p))
}

## Release the bootstrapping keys now: R's collector does not see the
## memory behind a context, so the keys would otherwise stay until a
## collection happens to run (notes/discoveries/D043).
bin_clear_bt_keys(cc)
