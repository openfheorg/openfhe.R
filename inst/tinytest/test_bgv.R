## Phase 2: BGV basic tests
## @openfhe-python: simple-integers-bgvrns.py [PARTIAL: only encrypt/decrypt + add]
library(openfhe.R)

# ── BGV encrypt/decrypt round-trip ───────────────────────
cc <- fhe_context("BGV", plaintext_modulus = 65537, multiplicative_depth = 2)
keys <- key_gen(cc, eval_mult = TRUE)

x <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L)
pt <- make_packed_plaintext(cc, x)
ct <- encrypt(keys@public, pt, cc = cc)
result <- decrypt(ct, keys@secret, cc = cc)
set_length(result, 8L)

expect_identical(get_packed_value(result)[1:8], x)

# ── BGV arithmetic ───────────────────────────────────────
ct2 <- ct + ct
result2 <- decrypt(ct2, keys@secret, cc = cc)
set_length(result2, 8L)
expect_identical(get_packed_value(result2)[1:8], (x + x) %% 65537L)
