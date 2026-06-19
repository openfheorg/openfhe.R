## Functional bootstrapping: evaluate an arbitrary plaintext function via LUT.
## @openfhe-python: binfhe/eval-function.py [FULL: GenerateLUTviaFunction
## replaced by an R-side helper since R is natively vectorised — no R
## callback through cpp11 needed]
library(openfhe.R)

## Functional bootstrapping (one functional bootstrap per evaluation) — skip
## on CRAN for time/memory, but run everywhere else: on CI (GitHub Actions
## sets CI=true) and locally via tinytest::test_all() (sets TT_AT_HOME).
if (!at_home() && Sys.getenv("CI") != "true")
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")

ctx <- bin_fhe_context(
  paramset = BinFHEParamSet$STD128,
  method = BinFHEMethod$GINX,
  arb_func = TRUE,
  log_q = 12L)

sk <- bin_key_gen(ctx)
bin_bt_key_gen(ctx, sk)

p <- get_max_plaintext_space(ctx)

# Mirror eval-function.py: f(x) = x^3 mod p, with the negative-half wrap.
fp <- function(m, p1) {
  ifelse(m < p1,
         (m^3) %% p1,
         ((m - p1 %/% 2)^3) %% p1)
}

lut <- generate_lut_via_function(fp, p)
expect_equal(length(lut), p)

# Evaluate for every plaintext value.
for (i in seq.int(0L, p - 1L)) {
  ct <- bin_encrypt(ctx, sk, i %% p,
                    output = BinFHEOutput$LARGE_DIM, p = p)
  ct_out <- eval_func(ctx, ct, lut)
  result <- bin_decrypt(ctx, sk, ct_out, p = as.integer(p))
  expect_equal(result, as.integer(fp(i, p)),
    info = sprintf("i=%d expected=%d", i, as.integer(fp(i, p))))
}
