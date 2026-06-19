## Phase 8: CKKS EvalPoly — polynomial evaluation on ciphertexts
## @openfhe-python: polynomial-evaluation.py [FULL]
library(openfhe.R)

# ── Parameters from the Python example ──────────────────────────────
cc <- fhe_context("CKKS",
  multiplicative_depth = 6L,
  scaling_mod_size     = 50L,
  features             = c(Feature$ADVANCEDSHE)
)
keys <- key_gen(cc, eval_mult = TRUE)

# ── Input: same real vector as polynomial-evaluation.py ─────────────
input_vec <- c(0.5, 0.7, 0.9, 0.95, 0.93)
pt <- make_ckks_packed_plaintext(cc, input_vec)
ct <- encrypt(keys@public, pt, cc = cc)

# ── Coefficient set #1 (sparse polynomial of degree 16) ─────────────
## @openfhe-python: polynomial-evaluation.py — EvalPoly coefficients1
coefficients1 <- c(0.15, 0.75, 0, 1.25, 0, 0, 1, 0,
                   1, 2, 0, 1, 0, 0, 0, 0, 1)
expected1 <- c(0.70519107, 1.38285078, 3.97211180, 5.60215665, 4.86357575)

ct_res1 <- eval_poly(ct, coefficients1)
res1    <- decrypt(ct_res1, keys@secret, cc = cc)
set_length(res1, length(input_vec))
expect_equal(get_real_packed_value(res1)[seq_along(input_vec)],
             expected1, tolerance = 1e-3)

# ── Coefficient set #2 (dense polynomial of degree 29) ──────────────
## @openfhe-python: polynomial-evaluation.py — EvalPoly coefficients2
coefficients2 <- c( 1,    2,    3,    4,    5,   -1,   -2,   -3,   -4,   -5,
                    0.1,  0.2,  0.3,  0.4,  0.5, -0.1, -0.2, -0.3, -0.4, -0.5,
                    0.1,  0.2,  0.3,  0.4,  0.5, -0.1, -0.2, -0.3, -0.4, -0.5)
expected2 <- c(3.4515092326, 5.3752765397, 4.8993108833,
               3.2495023573, 4.0485229982)

ct_res2 <- eval_poly(ct, coefficients2)
res2    <- decrypt(ct_res2, keys@secret, cc = cc)
set_length(res2, length(input_vec))
expect_equal(get_real_packed_value(res2)[seq_along(input_vec)],
             expected2, tolerance = 1e-3)
