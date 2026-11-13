## OPENFHE PYTHON SOURCE: examples/binfhe/eval-decomp.py
##
## @openfhe-python: eval-decomp.py [FULL]
##
## Decomposition of a ciphertext with a large modulus into digits that
## fit in the small modulus q.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

## Number of bits of a non-negative whole number (Python's bit_length)
bit_length <- function(x) if (x == 0) 0L else as.integer(floor(log2(x))) + 1L

# ══ Step 1: Set CryptoContext ════════════════════════════
## Set the ciphertext modulus to be 1 << 23. Note that normally we do
## not use this way to obtain the input ciphertext. Instead, we assume
## that an LWE ciphertext with large ciphertext modulus is already
## provided (e.g., by extracting from a CKKS ciphertext). However, we
## do not provide such a step in this example. Therefore, we use a
## brute force way to create a large LWE ciphertext.
log_q <- 23L
cc <- bin_fhe_context(BinFHEParamSet$STD128, arb_func = FALSE, log_q = log_q,
                      n = 0L, method = BinFHEMethod$GINX,
                      time_optimization = FALSE)

big_q <- 2^log_q

q <- 4096                                  # q
factor <- 2^(log_q - log2(q))              # Q/q
## Obtain the maximum plaintext space
big_p <- get_max_plaintext_space(cc) * factor

# ══ Step 2: Key Generation ═══════════════════════════════
## Generate the secret key
sk <- bin_key_gen(cc)

## Generate the bootstrapping keys (refresh and switching keys)
bin_bt_key_gen(cc, sk)

# ══ Step 3: Encryption ═══════════════════════════════════
value <- big_p %/% 2 + 1
ct1 <- bin_encrypt(cc, sk, value, BinFHEOutput$LARGE_DIM, big_p, big_q)

# ══ Step 4: Evaluation ═══════════════════════════════════
## Decompose the large ciphertext into small ciphertexts that fit in q
decomp <- eval_decomp(cc, ct1)
expect_true(is.list(decomp) && length(decomp) >= 1L)

# ══ Step 5: Decryption ═══════════════════════════════════
p <- get_max_plaintext_space(cc)
digits <- numeric(length(decomp))
for (i in seq_along(decomp)) {
  ct <- decomp[[i]]
  if (i == length(decomp)) {
    ## After every evalfloor, the least significant digit is dropped so
    ## the last modulus is computed as
    ## log p = (log P) mod (log GetMaxPlaintextSpace)
    logp <- bit_length(big_p - 1) %% bit_length(p - 1)
    p <- 2^logp
  }
  digits[i] <- bin_decrypt(cc, sk, ct, p)
}

## The decomposed value is the sum of digit_i * GetMaxPlaintextSpace^i,
## which gives the encrypted value back.
weights <- get_max_plaintext_space(cc)^(seq_along(decomp) - 1L)
expect_equal(sum(digits * weights), value)
## Each digit of the value in the clear
expect_equal(digits,
             (value %/% weights) %% c(rep(get_max_plaintext_space(cc),
                                          length(decomp) - 1L), p))

## Release the bootstrapping keys now: R's collector does not see the
## memory behind a context, so the keys would otherwise stay until a
## collection happens to run (notes/discoveries/D043).
bin_clear_bt_keys(cc)
