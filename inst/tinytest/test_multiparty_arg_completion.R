## @openfhe-python: src/lib/bindings.cpp (Multiparty arg completion) [PARTIAL]
##
## multiparty_key_gen argument completion
## (make_sparse + fresh), key_tag argument on the *AddKeys family,
## new multi_add_eval_mult_keys wrapper, and new multi_key_switch_gen
## wrapper for the existing cpp11 binding.
##
## Scope is **argument completion only** — verify each
## new argument reaches the cpp11 binding and round-trips through
## `get_key_tag()` where applicable. Full-protocol end-to-end
## tests involving the fresh-secret path or the symmetric
## multi_add_pub_keys flow are out of scope here; they arrive
## when the associated key-gen surface lands.
library(openfhe.R)

# ── Setup: BFV context, 2-party daisy-chain ─────────────
cc <- fhe_context("BFV",
  plaintext_modulus = 65537,
  multiplicative_depth = 2,
  features = c(Feature$MULTIPARTY)
)
kp1 <- key_gen(cc)

# ── multiparty_key_gen: make_sparse + fresh argument paths ──

## Default path still works (backward compat with the original signature).
kp2_default <- multiparty_key_gen(cc, kp1@public)
expect_true(S7::S7_inherits(kp2_default, KeyPair))
expect_true(is_good(kp2_default))

## Explicit make_sparse = FALSE, fresh = FALSE (same as default).
kp2_explicit <- multiparty_key_gen(cc, kp1@public,
                                   make_sparse = FALSE,
                                   fresh = FALSE)
expect_true(S7::S7_inherits(kp2_explicit, KeyPair))
expect_true(is_good(kp2_explicit))

## End-to-end decrypt round-trip using the daisy-chain
## protocol (party 2's public key IS the joint key after
## MultipartyKeyGen(pk1)). Verifies that the argument
## completion did not regress the existing path.
x <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L)
pt <- make_packed_plaintext(cc, x)
ct <- encrypt(kp2_default@public, pt, cc = cc)
partial1 <- multiparty_decrypt_lead(cc, kp1@secret, ct)
partial2 <- multiparty_decrypt_main(cc, kp2_default@secret, ct)
result <- multiparty_decrypt_fusion(cc, partial1, partial2)
set_length(result, 8L)
expect_identical(get_packed_value(result)[1:8], x)

## The fresh = TRUE branch produces a KeyPair but the
## resulting ciphertext is not guaranteed to round-trip through
## the daisy-chain decrypt flow — the `fresh` knob changes the
## upstream secret-derivation path. We assert the
## wrapper dispatches the argument correctly and returns a
## well-formed KeyPair; protocol-level semantics of `fresh`
## ride the header documentation.
kp2_fresh <- multiparty_key_gen(cc, kp1@public, fresh = TRUE)
expect_true(S7::S7_inherits(kp2_fresh, KeyPair))
expect_true(is_good(kp2_fresh))

# ── multi_add_pub_keys: key_tag round-trip ──────────────

## The key_tag argument is the R-side surface for the C++
## `keyTag` parameter. Verify it reaches the C++ call site by
## reading it back via get_key_tag(). We do NOT assert that
## combining pk1 with kp2_default@public produces a
## decryption-capable joint key — that protocol (symmetric
## multi-KeyGen) is distinct from the daisy-chain protocol
## exercised above.
joined_pk_tagged <- multi_add_pub_keys(cc, kp1@public, kp2_default@public,
                                       key_tag = "party-1+2-pub")
expect_true(S7::S7_inherits(joined_pk_tagged, PublicKey))
expect_equal(get_key_tag(joined_pk_tagged), "party-1+2-pub")

## Default (empty) key_tag path still compiles and returns a
## PublicKey wrapper.
joined_pk_default <- multi_add_pub_keys(cc, kp1@public, kp2_default@public)
expect_true(S7::S7_inherits(joined_pk_default, PublicKey))
tag_default <- get_key_tag(joined_pk_default)
expect_true(is.character(tag_default))
expect_equal(length(tag_default), 1L)

# ── multi_add_eval_mult_keys: wrapper dispatch ──────────

## Only the wrapper existence is testable here — the eval-mult
## key generators that produce the inputs to this function live
## on a separate surface. Assert the function is exported and has
## the expected argument list.
expect_true(exists("multi_add_eval_mult_keys", mode = "function"))
args_ml <- names(formals(multi_add_eval_mult_keys))
expect_identical(args_ml, c("cc", "ek1", "ek2", "key_tag"))

# ── multi_key_switch_gen: wrapper dispatch ──────────────

## Same situation: the EvalKey scaffold input to this function
## comes from a key-gen surface that is not yet exposed.
## Verify the wrapper exists with the documented signature.
expect_true(exists("multi_key_switch_gen", mode = "function"))
args_ks <- names(formals(multi_key_switch_gen))
expect_identical(args_ks, c("cc", "sk_orig", "sk_new", "eval_key"))

# ── Formals check on the extended generators ────────────

## multiparty_key_gen has 4 args (was 2 originally).
args_mkg <- names(formals(multiparty_key_gen))
expect_identical(args_mkg, c("cc", "lead_pk", "make_sparse", "fresh"))

## multi_add_pub_keys / multi_add_eval_keys have 4 args (were 3).
expect_identical(names(formals(multi_add_pub_keys)),
                 c("cc", "pk1", "pk2", "key_tag"))
expect_identical(names(formals(multi_add_eval_keys)),
                 c("cc", "ek1", "ek2", "key_tag"))
