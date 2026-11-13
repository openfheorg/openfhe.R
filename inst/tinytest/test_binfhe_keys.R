## OPENFHE PYTHON SOURCE: src/lib/binfhe_bindings.cpp (public-key encryption, key and parameter accessors, bootstrapping key management, LWE object accessors, serialization)
##
## @openfhe-python: src/lib/binfhe_bindings.cpp [FULL: KeyGenN, KeyGenPair, PubKeyGen, KeySwitchGen, Encrypt with a public key, SwitchCTtoqn, Bootstrap, EvalConstant, EvalDecomp, GetBTKey, GetBTKeyMap, GetSwitchKey, GetPublicKey, BTKeyLoad, BTKeyMapLoadSingleElement, ClearBTKeys, HasInternal32RefreshKey, HasInternal32SwitchKey, Getn, GetN, Getq, GetQ, GetBeta, SerializedObjectName, SerializedVersion, the LWE object accessors and comparisons, SerializeToFile and the five Deserialize functions of the BinFHE types]
library(openfhe.R)

## Skipped on CRAN: this file takes about 4 s against the Windows
## check-time budget (D022). It runs on GitHub Actions (which sets
## CI=true) and at home.
if (!at_home() && Sys.getenv("CI") != "true")
  exit_file("skipped on CRAN: check time (runs on CI and at_home)")

tmpdir <- tempfile("binfhe-keys-")
dir.create(tmpdir)

# ══ Parameters ═══════════════════════════════════════════
ctx <- bin_fhe_context(BinFHEParamSet$TOY)
n <- get_n(ctx)
big_n <- get_big_n(ctx)
q <- get_q(ctx)
big_q <- get_big_q(ctx)
expect_true(is.integer(n) && is.integer(big_n) && big_n > n)
expect_true(is.numeric(q) && is.numeric(big_q) && big_q > q)
expect_identical(get_beta(ctx), 128)
## The plaintext space of the context is q / (2 * beta).
expect_equal(get_max_plaintext_space(ctx), q / (2 * get_beta(ctx)))
expect_identical(serialized_object_name(ctx), "BinFHEContext")
expect_identical(serialized_version(ctx), 1L)
## A context that has not been generated has no parameters.
expect_error(get_n(BinFHEContext(ptr = openfhe.R:::BinFHEContext__new())),
             "no parameters")

# ══ Secret-key side: accessors and comparisons ═══════════
sk <- bin_key_gen(ctx)
expect_identical(get_length(sk), n)
## The key is held over the key-switching modulus, which is above q.
expect_true(grepl("^[0-9]+$", get_modulus(sk)))
expect_true(as.numeric(get_modulus(sk)) > q)
expect_true(sk == sk)
sk_b <- bin_key_gen(ctx)
expect_true(sk != sk_b)
expect_false(sk == sk_b)

## Without bootstrapping keys there is no public key and no switching
## key in the context.
expect_null(get_public_key(ctx))
expect_null(get_switch_key(ctx))

bin_bt_key_gen(ctx, sk, KeygenMode$PUB_ENCRYPT)
ct1 <- bin_encrypt(ctx, sk, 1L)
ct0 <- bin_encrypt(ctx, sk, 0L)
expect_identical(get_length(ct1), n)
expect_identical(get_modulus(ct1), as.character(q))
expect_identical(get_pt_modulus(ct1), 4)
expect_true(ct1 == ct1)
expect_true(ct1 != ct0)
## Two encryptions of one bit are different ciphertexts.
expect_false(ct1 == bin_encrypt(ctx, sk, 1L))

## The recorded moduli can be changed in place.
ctm <- bin_encrypt(ctx, sk, 1L)
r <- set_pt_modulus(ctm, 8)
expect_identical(r, ctm)
expect_identical(get_pt_modulus(ctm), 8)
set_modulus(ctm, 2 * q)
expect_identical(get_modulus(ctm), as.character(2 * q))
expect_error(set_modulus(ctm, -1))

# ══ Public-key encryption ════════════════════════════════
pk <- get_public_key(ctx)
expect_true(S7::S7_inherits(pk, LWEPublicKey))
expect_identical(get_length(pk), big_n)
expect_identical(get_modulus(pk), as.character(big_q))
expect_true(pk == pk)

## The default output with a public key is SMALL_DIM: a ciphertext of
## dimension n, ready for the gates.
ctp <- bin_encrypt(ctx, pk, 1L)
expect_identical(get_length(ctp), n)
expect_identical(bin_decrypt(ctx, sk, ctp), 1L)
expect_identical(bin_decrypt(ctx, sk, bin_encrypt(ctx, pk, 0L)), 0L)
expect_identical(bin_decrypt(ctx, sk,
                             eval_bin_gate(ctx, BinGate$AND, ctp, ct1)), 1L)
expect_identical(bin_decrypt(ctx, sk,
                             eval_bin_gate(ctx, BinGate$AND, ctp, ct0)), 0L)

## LARGE_DIM leaves it at dimension N and modulus Q; the switching key
## of the context brings it to (q, n).
ctl <- bin_encrypt(ctx, pk, 1L, BinFHEOutput$LARGE_DIM)
expect_identical(get_length(ctl), big_n)
expect_identical(get_modulus(ctl), as.character(big_q))
ksk <- get_switch_key(ctx)
if (is.null(ksk)) {
  ## The key is held in the 32-bit internal form only.
  expect_true(has_internal32_switch_key(ctx))
} else {
  expect_true(S7::S7_inherits(ksk, LWESwitchingKey))
  cts <- switch_ct_to_qn(ctx, ksk, ctl)
  expect_identical(get_length(cts), n)
  expect_identical(bin_decrypt(ctx, sk, cts), 1L)
}
expect_true(is.logical(has_internal32_refresh_key(ctx)))
expect_true(is.logical(has_internal32_switch_key(ctx)))

## A key pair, and a public key made for an existing secret key.
ctx2 <- bin_fhe_context(BinFHEParamSet$TOY)
kp <- bin_key_gen_pair(ctx2)
expect_true(S7::S7_inherits(kp, LWEKeyPair))
expect_true(is_good(kp))
expect_true(S7::S7_inherits(kp@public, LWEPublicKey))
expect_true(S7::S7_inherits(kp@secret, LWEPrivateKey))
expect_false(is_good(LWEKeyPair(public = kp@public, secret = NULL)))
## The secret key of a pair has dimension N: under it a LARGE_DIM
## public-key ciphertext decrypts directly.
expect_identical(get_length(kp@secret), get_big_n(ctx2))
ctq <- bin_encrypt(ctx2, kp@public, 1L, BinFHEOutput$LARGE_DIM)
expect_identical(bin_decrypt(ctx2, kp@secret, ctq), 1L)

## KeyGenN, KeySwitchGen, PubKeyGen and SwitchCTtoqn by hand: a
## ciphertext under the public key of sk_n, switched to sk2.
sk2 <- bin_key_gen(ctx2)
sk_n <- bin_key_gen_n(ctx2)
expect_identical(get_length(sk_n), get_big_n(ctx2))
pk_n <- bin_pub_key_gen(ctx2, sk_n)
expect_true(S7::S7_inherits(pk_n, LWEPublicKey))
ksk2 <- bin_key_switch_gen(ctx2, sk2, sk_n)
expect_true(S7::S7_inherits(ksk2, LWESwitchingKey))
for (bit in 0:1) {
  big <- bin_encrypt(ctx2, pk_n, bit, BinFHEOutput$LARGE_DIM)
  expect_identical(bin_decrypt(ctx2, sk_n, big), bit)
  small <- switch_ct_to_qn(ctx2, ksk2, big)
  expect_identical(get_length(small), get_n(ctx2))
  expect_identical(bin_decrypt(ctx2, sk2, small), bit)
}
expect_error(switch_ct_to_qn(ctx2, pk_n, ctq), "LWESwitchingKey")
expect_error(bin_pub_key_gen(ctx2, pk_n), "LWEPrivateKey")

# ══ Bootstrap and EvalConstant ═══════════════════════════
fresh <- bin_encrypt(ctx, sk, 1L, BinFHEOutput$FRESH)
boot <- bin_bootstrap(ctx, fresh)
expect_true(S7::S7_inherits(boot, LWECiphertext))
expect_identical(bin_decrypt(ctx, sk, boot), 1L)
expect_false(boot == fresh)
expect_identical(get_length(boot), n)
## extended = TRUE stops before key switching.
boot_x <- bin_bootstrap(ctx, fresh, TRUE)
expect_identical(get_length(boot_x), big_n)

one <- eval_constant(ctx, TRUE)
zero <- eval_constant(ctx, FALSE)
expect_identical(bin_decrypt(ctx, sk, one), 1L)
expect_identical(bin_decrypt(ctx, sk, zero), 0L)
## A constant needs no key: any secret key reads it.
expect_identical(bin_decrypt(ctx, sk_b, one), 1L)
expect_identical(bin_decrypt(ctx, sk,
                             eval_bin_gate(ctx, BinGate$AND, ct1, one)), 1L)
expect_identical(bin_decrypt(ctx, sk,
                             eval_bin_gate(ctx, BinGate$OR, ct0, zero)), 0L)

# ══ Bootstrapping keys: get, clear, load, files ══════════
bt <- get_bt_key(ctx)
expect_true(S7::S7_inherits(bt, RingGSWBTKey))
expect_equal(openfhe.R:::xptr_type(bt@ptr), "openfhe.R::RingGSWBTKey")

for (fmt in c("binary", "json")) {
  f <- function(name) file.path(tmpdir, paste0(name, ".", fmt))
  expect_true(fhe_serialize(ctx, f("cc"), format = fmt))
  expect_true(fhe_serialize(bt, f("bt"), format = fmt))
  expect_true(fhe_serialize(sk, f("sk"), format = fmt))
  expect_true(fhe_serialize(pk, f("pk"), format = fmt))
  expect_true(fhe_serialize(ct1, f("ct"), format = fmt))

  cc_r <- fhe_deserialize(f("cc"), "BinFHEContext", format = fmt)
  expect_true(S7::S7_inherits(cc_r, BinFHEContext))
  expect_identical(get_n(cc_r), n)
  expect_identical(get_big_q(cc_r), big_q)
  bt_r <- fhe_deserialize(f("bt"), "RingGSWBTKey", format = fmt)
  expect_true(S7::S7_inherits(bt_r, RingGSWBTKey))
  sk_r <- fhe_deserialize(f("sk"), "LWEPrivateKey", format = fmt)
  pk_r <- fhe_deserialize(f("pk"), "LWEPublicKey", format = fmt)
  ct_r <- fhe_deserialize(f("ct"), "LWECiphertext", format = fmt)
  ## The copies equal the originals by content.
  expect_true(sk_r == sk)
  expect_true(pk_r == pk)
  expect_true(ct_r == ct1)

  ## The restored context has no bootstrapping keys until they are
  ## loaded.
  expect_null(get_public_key(cc_r))
  expect_identical(bin_bt_key_load(cc_r, bt_r), cc_r)
  expect_true(get_public_key(cc_r) == pk)
  ct2 <- bin_encrypt(cc_r, pk_r, 1L)
  expect_identical(bin_decrypt(cc_r, sk_r,
                               eval_bin_gate(cc_r, BinGate$AND, ct_r, ct2)), 1L)
}
expect_error(fhe_serialize(ctx), "filename")
expect_error(fhe_deserialize(file.path(tmpdir, "absent.bin"), "LWECiphertext"))

## internal32 = FALSE keeps the 64-bit form.
cc_64 <- fhe_deserialize(file.path(tmpdir, "cc.binary"), "BinFHEContext")
bin_bt_key_load(cc_64, fhe_deserialize(file.path(tmpdir, "bt.binary"),
                                       "RingGSWBTKey"), internal32 = FALSE)
expect_false(has_internal32_refresh_key(cc_64))
expect_false(has_internal32_switch_key(cc_64))
expect_true(S7::S7_inherits(get_switch_key(cc_64), LWESwitchingKey))
expect_identical(bin_decrypt(cc_64, sk,
                             eval_bin_gate(cc_64, BinGate$OR, ct0, ct1)), 1L)

## Clearing removes them.
expect_identical(bin_clear_bt_keys(cc_64), cc_64)
expect_null(get_public_key(cc_64))
expect_null(get_switch_key(cc_64))

# ══ Large precision: the key map and EvalDecomp ══════════
## A context with dynamic gadget bases keeps one bootstrapping key per
## base (boolean-serial-binary-dynamic-large-precision.py).
log_q <- 17L
ctd <- bin_fhe_context(BinFHEParamSet$TOY, arb_func = FALSE, log_q = log_q,
                       n = 0L, method = BinFHEMethod$GINX,
                       time_optimization = TRUE)
big <- 2^log_q
factor <- 2^(log_q - log2(4096))
p <- get_max_plaintext_space(ctd) * factor
skd <- bin_key_gen(ctd)
bin_bt_key_gen(ctd, skd)

key_map <- get_bt_key_map(ctd)
expect_true(is.list(key_map) && length(key_map) >= 1L)
expect_true(all(vapply(key_map, function(k) S7::S7_inherits(k, RingGSWBTKey),
                       logical(1))))
bases <- as.numeric(names(key_map))
expect_true(all(bases == 2^round(log2(bases))))

fhe_serialize(ctd, file.path(tmpdir, "ccd.bin"))
fhe_serialize(get_bt_key(ctd), file.path(tmpdir, "btd.bin"))
for (b in names(key_map)) {
  fhe_serialize(key_map[[b]], file.path(tmpdir, paste0(b, "btd.bin")))
}
ctd_r <- fhe_deserialize(file.path(tmpdir, "ccd.bin"), "BinFHEContext")
expect_identical(length(get_bt_key_map(ctd_r)), 0L)
for (b in names(key_map)) {
  k <- fhe_deserialize(file.path(tmpdir, paste0(b, "btd.bin")), "RingGSWBTKey")
  expect_identical(bin_bt_key_map_load_single_element(ctd_r, as.numeric(b), k),
                   ctd_r)
}
bin_bt_key_load(ctd_r, fhe_deserialize(file.path(tmpdir, "btd.bin"),
                                       "RingGSWBTKey"))
expect_identical(sort(names(get_bt_key_map(ctd_r))), sort(names(key_map)))

## The sign of a large-precision input on the restored context.
for (i in c(0, 3, 4, 7)) {
  m <- p / 2 + i - 3
  cts <- bin_encrypt(ctd_r, skd, m, BinFHEOutput$LARGE_DIM, p, big)
  expect_identical(bin_decrypt(ctd_r, skd, eval_sign(ctd_r, cts), 2L),
                   as.integer(m >= p / 2))
}

## Decomposition into digits (eval-decomp.py, on the TOY set).
m <- p / 2 + 1
ctm <- bin_encrypt(ctd, skd, m, BinFHEOutput$LARGE_DIM, p, big)
decomp <- eval_decomp(ctd, ctm)
expect_true(is.list(decomp) && length(decomp) >= 2L)
expect_true(all(vapply(decomp, function(z) S7::S7_inherits(z, LWECiphertext),
                       logical(1))))
p_digit <- get_max_plaintext_space(ctd)
digits <- numeric(length(decomp))
weights <- numeric(length(decomp))
w <- 1
for (i in seq_along(decomp)) {
  pd <- p_digit
  if (i == length(decomp)) {
    ## The last digit holds the bits that are left.
    pd <- 2^(log2(p) %% log2(p_digit))
    if (pd == 1) pd <- p_digit
  }
  digits[i] <- bin_decrypt(ctd, skd, decomp[[i]], pd)
  weights[i] <- w
  w <- w * pd
}
## The digits, least significant first, give the message back.
expect_equal(sum(digits * weights), m)

unlink(tmpdir, recursive = TRUE)
