## @openfhe-python: src/lib/binfhe_bindings.cpp (BTKeyGen keygen_mode + EvalFloor) [PARTIAL]
##
## BinFHE argument-completion pass.
## Three changes:
##   1. bin_bt_key_gen gains keygen_mode arg (default
##      KeygenMode$SYM_ENCRYPT matching the C++ default at
##      binfhecontext.h line 273 and the openfhe-python default
##      at binfhe_bindings.cpp ~line 186).
##   2. eval_floor R wrapper on the since-forever-bound
##      BinFHEContext__EvalFloor cpp11 binding — closes a
##      latent surface gap.
##   3. BinFHE enum verification (the scoping sweep confirmed
##      BinFHEParamSet / BinFHEMethod / BinGate / KeygenMode
##      were already at full header parity; this
##      test pins the current values so accidental regressions
##      are caught).
library(openfhe.R)

# ── BinFHE context + key generation ─────────────────────

ctx <- bin_fhe_context(paramset = BinFHEParamSet$TOY)
sk <- bin_key_gen(ctx)

# ── bin_bt_key_gen default path (symmetric, backward-compat) ──

## Original callers pass (ctx, sk) positionally; the new
## optional keygen_mode default preserves that.
bin_bt_key_gen(ctx, sk)

## End-to-end gate evaluation verifies the default-path
## bootstrap keys are actually functional.
ct1 <- bin_encrypt(ctx, sk, 1L)
ct0 <- bin_encrypt(ctx, sk, 0L)
ct_and <- eval_bin_gate(ctx, BinGate$AND, ct1, ct0)
expect_equal(bin_decrypt(ctx, sk, ct_and), 0L)
ct_or <- eval_bin_gate(ctx, BinGate$OR, ct1, ct0)
expect_equal(bin_decrypt(ctx, sk, ct_or), 1L)

# ── bin_bt_key_gen explicit keygen_mode = SYM_ENCRYPT ──

## Explicit-default path.
ctx2 <- bin_fhe_context(paramset = BinFHEParamSet$TOY)
sk2 <- bin_key_gen(ctx2)
bin_bt_key_gen(ctx2, sk2, keygen_mode = KeygenMode$SYM_ENCRYPT)

ct2_a <- bin_encrypt(ctx2, sk2, 1L)
ct2_b <- bin_encrypt(ctx2, sk2, 1L)
ct2_and <- eval_bin_gate(ctx2, BinGate$AND, ct2_a, ct2_b)
expect_equal(bin_decrypt(ctx2, sk2, ct2_and), 1L)

# ── bin_bt_key_gen with keygen_mode = PUB_ENCRYPT ──

## PUB_ENCRYPT is the alternative mode and is accepted by the
## C++ API for every BinFHE paramset. Smoke test the dispatch
## path — verify the wrapper accepts the alternative enum
## value without throwing at the binding boundary and that
## the returned keys still support boolean evaluation.
ctx3 <- bin_fhe_context(paramset = BinFHEParamSet$TOY)
sk3 <- bin_key_gen(ctx3)
bin_bt_key_gen(ctx3, sk3, keygen_mode = KeygenMode$PUB_ENCRYPT)

ct3_a <- bin_encrypt(ctx3, sk3, 1L)
ct3_b <- bin_encrypt(ctx3, sk3, 0L)
ct3_xor <- eval_bin_gate(ctx3, BinGate$XOR, ct3_a, ct3_b)
expect_equal(bin_decrypt(ctx3, sk3, ct3_xor), 1L)

# ── eval_floor R wrapper ────────────────────────────────

## eval_floor expects a LARGE_DIM ciphertext (the functional
## bootstrapping path). Encrypt with the large-dim output mode
## and a wide plaintext modulus so the floor operation has
## something to round.
ctx_f <- bin_fhe_context(paramset = BinFHEParamSet$TOY,
                         arb_func = TRUE)
sk_f <- bin_key_gen(ctx_f)
bin_bt_key_gen(ctx_f, sk_f)

p <- get_max_plaintext_space(ctx_f)
## Encrypt a value in the large-dim / functional-bootstrap
## path.
ct_f <- bin_encrypt(ctx_f, sk_f, message = 5L,
                    output = BinFHEOutput$LARGE_DIM, p = p)
ct_f_floor <- eval_floor(ctx_f, ct_f, roundbits = 2L)
expect_true(S7::S7_inherits(ct_f_floor, LWECiphertext))

# ── Enum parity pins (regression guards) ────────────────

## BinFHEParamSet is 44 values wide per
## binfhe-constants.h lines 49-96. Pin the count and a few
## representative entries so a regression that drops or
## re-numbers values is caught.
expect_equal(length(BinFHEParamSet), 44L)
expect_equal(BinFHEParamSet$TOY, 0L)
expect_equal(BinFHEParamSet$STD128, 3L)
expect_equal(BinFHEParamSet$STD192, 9L)
expect_equal(BinFHEParamSet$STD256, 15L)
expect_equal(BinFHEParamSet$SIGNED_MOD_TEST, 43L)

## BinFHEMethod has 4 values with INVALID_METHOD at 0 per
## binfhe-constants.h line 115.
expect_equal(length(BinFHEMethod), 4L)
expect_equal(BinFHEMethod$INVALID_METHOD, 0L)
expect_equal(BinFHEMethod$AP, 1L)
expect_equal(BinFHEMethod$GINX, 2L)
expect_equal(BinFHEMethod$LMKCDEY, 3L)

## BinGate has 14 values with CMUX at position 13 per
## binfhe-constants.h line 126.
expect_equal(length(BinGate), 14L)
expect_equal(BinGate$OR, 0L)
expect_equal(BinGate$AND, 1L)
expect_equal(BinGate$XOR, 4L)
expect_equal(BinGate$CMUX, 13L)

## KeygenMode has 2 values per binfhe-constants.h line 132.
expect_equal(length(KeygenMode), 2L)
expect_equal(KeygenMode$SYM_ENCRYPT, 0L)
expect_equal(KeygenMode$PUB_ENCRYPT, 1L)

# ── Formals shape assertions ────────────────────────────

expect_identical(names(formals(bin_bt_key_gen)),
                 c("ctx", "sk", "keygen_mode"))
expect_equal(eval(formals(bin_bt_key_gen)$keygen_mode), 0L)
expect_identical(names(formals(eval_floor)),
                 c("ctx", "ct", "roundbits"))
