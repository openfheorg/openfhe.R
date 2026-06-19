## Functional bootstrapping: extract MSB (sign bit) of a large-Q LWE ciphertext.
## @openfhe-python: binfhe/eval-sign.py [FULL]
library(openfhe.R)

log_q <- 17L
ctx <- bin_fhe_context(
  paramset = BinFHEParamSet$STD128,
  method = BinFHEMethod$GINX,
  arb_func = FALSE,
  log_q = log_q,
  n = 0L,
  time_optimization = FALSE)

Q <- bitwShiftL(1L, log_q)             # 1 << 17 = 131072
q <- 4096
factor <- bitwShiftL(1L, log_q - as.integer(log2(q)))   # 1 << 5 = 32
p <- get_max_plaintext_space(ctx) * factor

sk <- bin_key_gen(ctx)
bin_bt_key_gen(ctx, sk)

# Mirror eval-sign.py: 8 inputs centered on p/2; expected sign is 1 iff i >= 3.
for (i in 0:7) {
  msg <- p %/% 2 + i - 3
  ct <- bin_encrypt(ctx, sk, msg,
                    output = BinFHEOutput$LARGE_DIM, p = p, mod = Q)
  ct_sign <- eval_sign(ctx, ct)
  result <- bin_decrypt(ctx, sk, ct_sign, p = 2L)
  expect_equal(result, as.integer(i >= 3),
    info = sprintf("i=%d msg=%g expected=%d", i, msg, as.integer(i >= 3)))
}
