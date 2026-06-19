## Phase 5: CKKS advanced operations
## @openfhe-python: simple-ckks-bootstrapping.py [FULL]
## Note: function-evaluation.py is now covered by its own dedicated
## test file test_ckks_function_evaluation.R.
library(openfhe.R)

# ── Transcendental functions ─────────────────────────────
# Need sufficient depth for Chebyshev approximation
cc <- fhe_context("CKKS",
  multiplicative_depth = 6L,
  scaling_mod_size = 50L,
  batch_size = 8L,
  features = c(Feature$ADVANCEDSHE)
)
keys <- key_gen(cc, eval_mult = TRUE)

x <- c(0.25, 0.5, 0.1, 0.3, 0.15, 0.45, 0.35, 0.2)
pt <- make_ckks_packed_plaintext(cc, x)
ct <- encrypt(keys@public, pt, cc = cc)

tol <- 0.05  # Chebyshev approximation tolerance at low degree

# ── EvalLogistic (sigmoid) ───────────────────────────────
ct_logistic <- eval_logistic(ct, a = -4, b = 4, degree = 16L)
res_logistic <- decrypt(ct_logistic, keys@secret, cc = cc)
set_length(res_logistic, 8L)
expected <- 1 / (1 + exp(-x))
expect_equal(get_real_packed_value(res_logistic)[1:8], expected, tolerance = tol)

# ── EvalSin ──────────────────────────────────────────────
ct_sin <- eval_sin(ct, a = -1, b = 1, degree = 16L)
res_sin <- decrypt(ct_sin, keys@secret, cc = cc)
set_length(res_sin, 8L)
expect_equal(get_real_packed_value(res_sin)[1:8], sin(x), tolerance = tol)

# ── EvalCos ──────────────────────────────────────────────
ct_cos <- eval_cos(ct, a = -1, b = 1, degree = 16L)
res_cos <- decrypt(ct_cos, keys@secret, cc = cc)
set_length(res_cos, 8L)
expect_equal(get_real_packed_value(res_cos)[1:8], cos(x), tolerance = tol)

# ── Bootstrapping ────────────────────────────────────────
# This is expensive — use minimal parameters
level_budget <- c(3L, 3L)
secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
depth <- get_bootstrap_depth(level_budget, secret_key_dist)
levels_after <- 2L
total_depth <- depth + levels_after

cc2 <- fhe_context("CKKS",
  multiplicative_depth = total_depth,
  scaling_mod_size = 59L,
  first_mod_size = 60L,
  ring_dim = 4096L,
  security_level = SecurityLevel$HEStd_NotSet,
  scaling_technique = ScalingTechnique$FLEXIBLEAUTO,
  features = c(Feature$ADVANCEDSHE, Feature$FHE)
)

keys2 <- key_gen(cc2, eval_mult = TRUE)
ring_dim <- openfhe.R:::CryptoContext__GetRingDimension(cc2@ptr)
num_slots <- as.integer(ring_dim / 2)

eval_bootstrap_setup(cc2, level_budget)
eval_bootstrap_key_gen(cc2, keys2@secret, num_slots)

y <- c(0.25, 0.5, 0.75, 1.0)
pt2 <- make_ckks_packed_plaintext(cc2, y)
ct2 <- encrypt(keys2@public, pt2, cc = cc2)

# Bootstrap: refresh levels
ct_boot <- eval_bootstrap(ct2)

res_boot <- decrypt(ct_boot, keys2@secret, cc = cc2)
set_length(res_boot, 4L)
expect_equal(get_real_packed_value(res_boot)[1:4], y, tolerance = 0.01)
