## @openfhe-python: src/lib/binfhe_bindings.cpp (EvalBinGate vector overload) [FULL]
##
## vector-form eval_bin_gate for the
## 3+-input gates (MAJORITY, AND3, OR3, AND4, OR4, CMUX). The
## R wrapper was extended with optional-NULL ct2 dispatch:
## single-ct2 path routes to the 2-input binding (original
## backward compat); NULL-ct2 path routes to the new vector
## binding.
##
## Multi-input gates require a paramset designed for multi-
## input evaluation (STD128_3 / STD128_4 / ...) and the
## plaintext modulus p must be set to 2 * num_inputs per
## openfhe-development/src/binfhe/examples/boolean-multi-input.cpp
## lines 44-61. TOY with the default p = 4 produces garbled
## decryption on AND3 / OR3 / MAJORITY.
library(openfhe.R)

# ── 2-input backward compat (regression guard) — TOY is fine ──

ctx_toy <- bin_fhe_context(paramset = BinFHEParamSet$TOY)
sk_toy <- bin_key_gen(ctx_toy)
bin_bt_key_gen(ctx_toy, sk_toy)

c1 <- bin_encrypt(ctx_toy, sk_toy, 1L)
c0 <- bin_encrypt(ctx_toy, sk_toy, 0L)

## The original positional signature
## eval_bin_gate(ctx, gate, ct1, ct2) must still work after
## the dispatcher refactor.
expect_equal(bin_decrypt(ctx_toy, sk_toy,
                         eval_bin_gate(ctx_toy, BinGate$AND, c1, c0)), 0L)
expect_equal(bin_decrypt(ctx_toy, sk_toy,
                         eval_bin_gate(ctx_toy, BinGate$OR,  c1, c0)), 1L)
expect_equal(bin_decrypt(ctx_toy, sk_toy,
                         eval_bin_gate(ctx_toy, BinGate$XOR, c1, c0)), 1L)
expect_equal(bin_decrypt(ctx_toy, sk_toy,
                         eval_bin_gate(ctx_toy, BinGate$NAND, c1, c0)), 1L)

# ── 3-input vector form setup (STD128_3, p = 6) ────────

## Use the paramset designed for 3-input gates per
## boolean-multi-input.cpp:44. The plaintext modulus is
## p = 2 * 3 = 6 per the example line 60; encryption uses
## SMALL_DIM output mode per line 61.
ctx3 <- bin_fhe_context(paramset = BinFHEParamSet$STD128_3)
sk3 <- bin_key_gen(ctx3)
bin_bt_key_gen(ctx3, sk3)

p3 <- 6
encrypt_bit_3 <- function(b) {
  bin_encrypt(ctx3, sk3, message = as.integer(b),
              output = BinFHEOutput$SMALL_DIM, p = p3)
}

# ── 3-input AND3: 1 AND 1 AND 0 = 0 ────────────────────

cts110 <- list(encrypt_bit_3(1L), encrypt_bit_3(1L),
               encrypt_bit_3(0L))
r_and3 <- eval_bin_gate(ctx3, BinGate$AND3, cts110)
expect_true(S7::S7_inherits(r_and3, LWECiphertext))
expect_equal(bin_decrypt(ctx3, sk3, r_and3, p = p3), 0L)

## 1 AND 1 AND 1 = 1
cts111 <- list(encrypt_bit_3(1L), encrypt_bit_3(1L),
               encrypt_bit_3(1L))
r_and3_1 <- eval_bin_gate(ctx3, BinGate$AND3, cts111)
expect_equal(bin_decrypt(ctx3, sk3, r_and3_1, p = p3), 1L)

# ── 3-input OR3: 0 OR 0 OR 0 = 0; 1 OR 0 OR 0 = 1 ──────

cts000 <- list(encrypt_bit_3(0L), encrypt_bit_3(0L),
               encrypt_bit_3(0L))
r_or3_0 <- eval_bin_gate(ctx3, BinGate$OR3, cts000)
expect_equal(bin_decrypt(ctx3, sk3, r_or3_0, p = p3), 0L)

cts100 <- list(encrypt_bit_3(1L), encrypt_bit_3(0L),
               encrypt_bit_3(0L))
r_or3_1 <- eval_bin_gate(ctx3, BinGate$OR3, cts100)
expect_equal(bin_decrypt(ctx3, sk3, r_or3_1, p = p3), 1L)

# ── 3-input MAJORITY: 1 1 0 -> 1; 1 0 0 -> 0 ───────────

## MAJORITY has a different plaintext encoding per
## boolean-multi-input.cpp line 120 area — uses p = 4, not
## p = 6. Generate fresh encryptions under p = 4 for this
## gate.
p_maj <- 4
encrypt_bit_maj <- function(b) {
  bin_encrypt(ctx3, sk3, message = as.integer(b),
              output = BinFHEOutput$SMALL_DIM, p = p_maj)
}
cts_maj_110 <- list(encrypt_bit_maj(1L), encrypt_bit_maj(1L),
                    encrypt_bit_maj(0L))
r_maj_1 <- eval_bin_gate(ctx3, BinGate$MAJORITY, cts_maj_110)
expect_equal(bin_decrypt(ctx3, sk3, r_maj_1, p = p_maj), 1L)

cts_maj_100 <- list(encrypt_bit_maj(1L), encrypt_bit_maj(0L),
                    encrypt_bit_maj(0L))
r_maj_0 <- eval_bin_gate(ctx3, BinGate$MAJORITY, cts_maj_100)
expect_equal(bin_decrypt(ctx3, sk3, r_maj_0, p = p_maj), 0L)

# ── Error: non-list, non-ciphertext third arg ──────────

## The dispatcher's NULL-ct2 branch only accepts a list; a
## bare string with ct2 = NULL should abort via cli::cli_abort.
expect_error(eval_bin_gate(ctx_toy, BinGate$AND3, "not a list"),
             pattern = "LWECiphertext.*list")

# ── Formals shape assertion ────────────────────────────

expect_identical(names(formals(eval_bin_gate)),
                 c("ctx", "gate", "ct1", "ct2"))
expect_null(formals(eval_bin_gate)$ct2)

# ── eval_sign formals + scheme_switch default check ────

## Doc review: verify the arg is still named
## `scheme_switch` and defaults to FALSE (the roxygen
## updated prose does not change the signature).
expect_identical(names(formals(eval_sign)),
                 c("ctx", "ct", "scheme_switch"))
expect_equal(formals(eval_sign)$scheme_switch, FALSE)
