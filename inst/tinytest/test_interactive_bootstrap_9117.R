## @openfhe-python: src/lib/bindings.cpp (IntBoot + IntMPBoot families) [PARTIAL]
##                  NONE for KeySwitchDown [R-ONLY]
##
## KeySwitchDown + IntBoot 4-function
## family + IntMPBoot 6-function family.
##
## Full end-to-end validation of the interactive bootstrap
## protocols requires OpenFHE's PrivateKeyImpl clone + set-
## elements surface that is not bound here (out of scope).
## Instead this test file verifies:
##   - all 11 bindings dispatch cleanly and return the expected
##     wrapper type;
##   - the IntBoot single-party 4-method pipeline can be
##     chained end-to-end without throwing (numeric fidelity
##     of the refreshed ciphertext is cross-referenced against
##     the upstream UnitTestInteractiveBootstrap.cpp
##     `UnitTest_MultiPartyBootThresholdFHE2` protocol but
##     deferred to a later test file when Clone / SetElements
##     are bound);
##   - `key_switch_down()` accepts an ext-rotated ciphertext
##     (which lives in the P*Q basis) and returns a valid
##     Ciphertext in the Q basis;
##   - `int_mp_boot_random_element_gen()` dispatches on
##     PublicKey vs Ciphertext correctly.
library(openfhe.R)

## Interactive (multi-party) bootstrapping — skip on CRAN for time/memory,
## but run everywhere else: on CI (GitHub Actions sets CI=true) and locally
## via tinytest::test_all() (sets TT_AT_HOME).
if (!at_home() && Sys.getenv("CI") != "true")
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")

# ── CKKS setup with FHE + MULTIPARTY + ADVANCEDSHE ─────
cc <- fhe_context("CKKS",
  multiplicative_depth = 6L,
  scaling_mod_size     = 50L,
  first_mod_size       = 60L,
  ring_dim             = 4096L,
  security_level       = SecurityLevel$HEStd_NotSet,
  batch_size           = 8L,
  features             = c(Feature$ADVANCEDSHE, Feature$FHE,
                           Feature$MULTIPARTY)
)
kp1 <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, 2L))
kp2 <- multiparty_key_gen(cc, kp1@public)

x <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
pt <- make_ckks_packed_plaintext(cc, x)
## Encrypt under the joint (party 2) public key for the
## multi-party flow. Also encrypt a parallel copy under kp1's
## public key — kp1 has the rotation keys registered (via
## key_gen(cc, rotations = ...)) so the eval_fast_rotation_ext
## + key_switch_down sub-test can find an eval-key map for its
## key tag.
ct <- encrypt(kp2@public, pt, cc = cc)
ct_rot <- encrypt(kp1@public, pt, cc = cc)

# ── IntBoot single-party family: 4 bindings dispatch ────

## Each of the four IntBoot methods produces a new Ciphertext;
## chaining them mirrors the upstream
## UnitTestInteractiveBootstrap.cpp pipeline line 496-506.
ct_adjusted <- int_boot_adjust_scale(ct)
expect_true(S7::S7_inherits(ct_adjusted, Ciphertext))

ct_masked <- int_boot_decrypt(kp1@secret, ct_adjusted)
expect_true(S7::S7_inherits(ct_masked, Ciphertext))

ct_encrypted <- int_boot_encrypt(kp2@public, ct_masked)
expect_true(S7::S7_inherits(ct_encrypted, Ciphertext))

ct_added <- int_boot_add(ct_encrypted, ct_masked)
expect_true(S7::S7_inherits(ct_added, Ciphertext))

# ── KeySwitchDown on an ext-rotated ciphertext ──────────

## eval_fast_rotation_ext lands a ciphertext in the extended
## P*Q basis; key_switch_down brings it back to Q. The full
## numeric validation of the ext + key_switch_down pipeline
## is out of scope here — this test verifies the binding
## dispatches and returns a Ciphertext in the correct shape.
precomp <- eval_fast_rotation_precompute(ct_rot)
ct_ext <- eval_fast_rotation_ext(ct_rot, index = 1L, precomp = precomp,
                                 add_first = TRUE)
expect_true(S7::S7_inherits(ct_ext, Ciphertext))

ct_down <- key_switch_down(ct_ext)
expect_true(S7::S7_inherits(ct_down, Ciphertext))

# ── IntMPBoot family: all 6 bindings dispatch ───────────

## int_mp_boot_adjust_scale: single arg, returns Ciphertext.
ct_mp_adjusted <- int_mp_boot_adjust_scale(ct)
expect_true(S7::S7_inherits(ct_mp_adjusted, Ciphertext))

## int_mp_boot_random_element_gen: PublicKey overload.
a_from_pk <- int_mp_boot_random_element_gen(cc, kp1@public)
expect_true(S7::S7_inherits(a_from_pk, Ciphertext))

## int_mp_boot_random_element_gen: Ciphertext overload.
a_from_ct <- int_mp_boot_random_element_gen(cc, ct)
expect_true(S7::S7_inherits(a_from_ct, Ciphertext))

## int_mp_boot_random_element_gen: type error on wrong source.
expect_error(int_mp_boot_random_element_gen(cc, "not a key"),
             pattern = "PublicKey.*Ciphertext")

## int_mp_boot_decrypt: takes (sk, ct, a) and returns a list
## of two Ciphertexts (the shares pair).
shares1 <- int_mp_boot_decrypt(kp1@secret, ct_mp_adjusted, a_from_pk)
expect_true(is.list(shares1))
expect_equal(length(shares1), 2L)
for (s in shares1) expect_true(S7::S7_inherits(s, Ciphertext))

shares2 <- int_mp_boot_decrypt(kp2@secret, ct_mp_adjusted, a_from_pk)
expect_true(is.list(shares2))
expect_equal(length(shares2), 2L)

## int_mp_boot_add: aggregate the two parties' shares.
agg <- int_mp_boot_add(cc, list(shares1, shares2))
expect_true(is.list(agg))
for (a in agg) expect_true(S7::S7_inherits(a, Ciphertext))

## int_mp_boot_add: type error on non-list.
expect_error(int_mp_boot_add(cc, "not a list"),
             pattern = "shares_pair_list.*list")

## int_mp_boot_encrypt: final step, returns the refreshed ct.
ct_refreshed <- int_mp_boot_encrypt(kp1@public, agg, a_from_pk,
                                    ct_mp_adjusted)
expect_true(S7::S7_inherits(ct_refreshed, Ciphertext))

## int_mp_boot_encrypt: type error on non-list shares_pair.
expect_error(int_mp_boot_encrypt(kp1@public, "not a list",
                                 a_from_pk, ct_mp_adjusted),
             pattern = "shares_pair.*list")

# ── Formals shape assertions ────────────────────────────

expect_identical(names(formals(key_switch_down)), "ct")
expect_identical(names(formals(int_boot_decrypt)), c("sk", "ct"))
expect_identical(names(formals(int_boot_encrypt)), c("pk", "ct"))
expect_identical(names(formals(int_boot_add)), c("ct1", "ct2"))
expect_identical(names(formals(int_boot_adjust_scale)), "ct")
expect_identical(names(formals(int_mp_boot_adjust_scale)), "ct")
expect_identical(names(formals(int_mp_boot_random_element_gen)),
                 c("cc", "source"))
expect_identical(names(formals(int_mp_boot_decrypt)),
                 c("sk", "ct", "a"))
expect_identical(names(formals(int_mp_boot_add)),
                 c("cc", "shares_pair_list"))
expect_identical(names(formals(int_mp_boot_encrypt)),
                 c("pk", "shares_pair", "a", "ct"))
