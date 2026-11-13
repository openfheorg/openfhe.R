## OPENFHE PYTHON SOURCE: src/lib/pke/serialization.cpp (in-memory serialization, EvalKey and EvalKeyMap files, bootstrap keys)
##
## @openfhe-python: src/lib/pke/serialization.cpp [FULL: Serialize, DeserializeCryptoContextString, DeserializePublicKeyString, DeserializePrivateKeyString, DeserializeCiphertextString, DeserializeEvalKeyString, DeserializeEvalKeyMapString, DeserializeEvalKeyMapVectorString, DeserializeEvalKey, DeserializeEvalKeyMap, SerializeEvalMultKeyString, DeserializeEvalMultKeyString, SerializeEvalAutomorphismKeyString, DeserializeEvalAutomorphismKeyString, SerializeEvalSumKey with a context, SerializeEvalBootstrapKey, DeserializeEvalBootstrapKey]
library(openfhe.R)

## Skipped on CRAN: this file takes about 16 s, most of the CRAN-mode
## test time, against the Windows check-time budget (D022). It runs on
## GitHub Actions (which sets CI=true) and at home.
if (!at_home() && Sys.getenv("CI") != "true")
  exit_file("skipped on CRAN: check time (runs on CI and at_home)")

clear_fhe_state()
tmpdir <- tempfile("ser-mem-")
dir.create(tmpdir)

cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2,
                  features = c(Feature$ADVANCEDSHE))
keys <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, -1L))
tag <- get_key_tag(keys@secret)
x <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L)
ct <- encrypt(keys@public, make_packed_plaintext(cc, x), cc = cc)
dec <- function(ct, sk, cc) {
  pt <- decrypt(ct, sk, cc = cc)
  set_length(pt, length(x))
  as.integer(get_packed_value(pt))
}

# ══ Objects: binary is a raw vector, JSON a string ═══════
for (fmt in c("binary", "json")) {
  cc_s <- fhe_serialize(cc, format = fmt)
  pk_s <- fhe_serialize(keys@public, format = fmt)
  sk_s <- fhe_serialize(keys@secret, format = fmt)
  ct_s <- fhe_serialize(ct, format = fmt)
  if (fmt == "binary") {
    expect_true(is.raw(cc_s) && is.raw(pk_s) && is.raw(sk_s) && is.raw(ct_s))
  } else {
    expect_true(is.character(cc_s) && length(cc_s) == 1L)
    expect_true(startsWith(ct_s, "{"))
  }

  cc2 <- fhe_deserialize_string(cc_s, "CryptoContext")
  pk2 <- fhe_deserialize_string(pk_s, "PublicKey")
  sk2 <- fhe_deserialize_string(sk_s, "PrivateKey")
  ct2 <- fhe_deserialize_string(ct_s, "Ciphertext")
  expect_true(S7::S7_inherits(cc2, CryptoContext))
  expect_true(S7::S7_inherits(pk2, PublicKey))
  expect_true(S7::S7_inherits(sk2, PrivateKey))
  expect_true(S7::S7_inherits(ct2, Ciphertext))
  expect_identical(dec(ct2, sk2, cc2), x)
  ## A fresh encryption under the deserialized public key opens with
  ## the original secret key.
  expect_identical(dec(encrypt(pk2, make_packed_plaintext(cc2, x), cc = cc2),
                       keys@secret, cc), x)
}

## The in-memory bytes are the bytes of the file.
f <- file.path(tmpdir, "ct.bin")
fhe_serialize(ct, f)
expect_identical(fhe_serialize(ct), readBin(f, "raw", file.size(f)))
fj <- file.path(tmpdir, "ct.json")
fhe_serialize(ct, fj, format = "json")
expect_identical(fhe_serialize(ct, format = "json"),
                 readChar(fj, file.size(fj), useBytes = TRUE))

## format, when given, must agree with the data.
expect_error(fhe_deserialize_string(fhe_serialize(ct), "Ciphertext", format = "json"),
             "disagree")
expect_error(fhe_deserialize_string(42, "Ciphertext"), "raw vector")
expect_error(fhe_deserialize_string(as.raw(1:10), "Ciphertext"))

# ══ EvalKey: memory and file ═════════════════════════════
bob <- key_gen(cc)
swk <- key_switch_gen(cc, keys@secret, bob@secret)
for (fmt in c("binary", "json")) {
  swk2 <- fhe_deserialize_string(fhe_serialize(swk, format = fmt), "EvalKey")
  expect_true(S7::S7_inherits(swk2, EvalKey))
  expect_identical(dec(key_switch(ct, swk2), bob@secret, cc), x)

  fk <- file.path(tmpdir, paste0("swk.", fmt))
  expect_true(fhe_serialize(swk, fk, format = fmt))
  swk3 <- fhe_deserialize(fk, "EvalKey", format = fmt)
  expect_identical(dec(key_switch(ct, swk3), bob@secret, cc), x)
}
expect_error(fhe_deserialize(file.path(tmpdir, "absent.bin"), "EvalKey"))

# ══ A list of EvalKey ════════════════════════════════════
mult_keys <- get_eval_mult_key_vector(tag)
vec_s <- fhe_serialize(mult_keys)
expect_true(is.raw(vec_s))
vec2 <- fhe_deserialize_string(vec_s, "EvalKeyVector")
expect_true(is.list(vec2) && length(vec2) == length(mult_keys))
expect_true(all(vapply(vec2, function(k) S7::S7_inherits(k, EvalKey), logical(1))))
expect_identical(get_key_tag(vec2[[1L]]), tag)
expect_error(fhe_serialize(mult_keys, file.path(tmpdir, "v.bin")), "in memory only")
expect_error(fhe_serialize(list(1, 2)), "EvalKey")

# ══ EvalKeyMap: memory and file ══════════════════════════
eval_sum_key_gen(cc, keys@secret)
sum_map <- get_all_eval_sum_keys()[[tag]]
expect_true(S7::S7_inherits(sum_map, EvalKeyMap))
for (fmt in c("binary", "json")) {
  map2 <- fhe_deserialize_string(fhe_serialize(sum_map, format = fmt), "EvalKeyMap")
  expect_true(S7::S7_inherits(map2, EvalKeyMap))
  fm <- file.path(tmpdir, paste0("map.", fmt))
  expect_true(fhe_serialize(sum_map, fm, format = fmt))
  map3 <- fhe_deserialize(fm, "EvalKeyMap", format = fmt)
  expect_true(S7::S7_inherits(map3, EvalKeyMap))
  ## The copies are working keys: with only a copy registered, a
  ## summation decrypts correctly.
  for (m in list(map2, map3)) {
    clear_eval_sum_keys()
    expect_error(eval_sum(ct, 8L))
    insert_eval_sum_key(m)
    expect_identical(dec(eval_sum(ct, 8L), keys@secret, cc)[1L], sum(x))
  }
}
## The summation keys share the registry of the rotation keys; put
## those back for the sections below.
eval_rotate_key_gen(cc, keys@secret, c(1L, -1L))

# ══ Key registries, in memory ════════════════════════════
ct_sq <- function() dec(eval_mult(ct, ct), keys@secret, cc)
ct_rot <- function() dec(eval_rotate(ct, 1L), keys@secret, cc)
expect_identical(ct_sq(), x * x)

for (fmt in c("binary", "json")) {
  mk <- serialize_eval_keys(type = "mult", format = fmt)
  rk <- serialize_eval_keys(type = "automorphism", format = fmt)
  expect_true(if (fmt == "binary") is.raw(mk) && is.raw(rk)
              else is.character(mk) && is.character(rk))

  clear_eval_mult_keys()
  clear_eval_automorphism_keys()
  expect_error(eval_mult(ct, ct))
  expect_error(eval_rotate(ct, 1L))

  expect_true(deserialize_eval_keys_string(mk, "mult"))
  expect_true(deserialize_eval_keys_string(rk, "automorphism"))
  expect_identical(ct_sq(), x * x)
  expect_identical(ct_rot(), c(x[-1L], 0L))
}

## key_tag selects: an unknown tag has no keys.
expect_error(serialize_eval_keys(type = "mult", key_tag = "no-such-tag"))
expect_true(is.raw(serialize_eval_keys(type = "mult", key_tag = tag)))

## The in-memory bytes are the bytes of the file.
fmk <- file.path(tmpdir, "mk.bin")
serialize_eval_keys(fmk, "mult", key_tag = tag)
expect_identical(serialize_eval_keys(type = "mult", key_tag = tag),
                 readBin(fmk, "raw", file.size(fmk)))

# ══ The keys of one context ══════════════════════════════
## A second context with its own keys; by context, each serialization
## holds only that context's keys.
cc_b <- fhe_context("BFV", plaintext_modulus = 786433, multiplicative_depth = 2,
                    features = c(Feature$ADVANCEDSHE))
keys_b <- key_gen(cc_b, eval_mult = TRUE)
eval_sum_key_gen(cc, keys@secret)
eval_sum_key_gen(cc_b, keys_b@secret)

all_sum <- serialize_eval_keys(type = "sum")
a_sum <- serialize_eval_keys(type = "sum", cc = cc)
b_sum <- serialize_eval_keys(type = "sum", cc = cc_b)
expect_true(length(a_sum) < length(all_sum))
expect_true(length(b_sum) < length(all_sum))
expect_false(identical(a_sum, b_sum))

f_sum <- file.path(tmpdir, "sum_a.bin")
expect_true(serialize_eval_keys(f_sum, "sum", cc = cc))
expect_identical(readBin(f_sum, "raw", file.size(f_sum)), a_sum)

## Restoring only cc's keys leaves cc_b without summation keys.
tag_b <- get_key_tag(keys_b@secret)
clear_eval_sum_keys()
expect_true(deserialize_eval_keys_string(a_sum, "sum"))
expect_true(tag %in% names(get_all_eval_sum_keys()))
expect_false(tag_b %in% names(get_all_eval_sum_keys()))
expect_identical(dec(eval_sum(ct, 8L), keys@secret, cc)[1L], sum(x))

expect_true(is.raw(serialize_eval_keys(type = "mult", cc = cc)))
expect_true(is.raw(serialize_eval_keys(type = "automorphism", cc = cc)))

# ══ Bootstrap keys ═══════════════════════════════════════
level_budget <- c(3L, 3L)
depth <- get_bootstrap_depth(level_budget, SecretKeyDist$UNIFORM_TERNARY)
ck <- fhe_context("CKKS",
  multiplicative_depth = depth + 2L,
  scaling_mod_size = 59L,
  first_mod_size = 60L,
  ring_dim = 4096L,
  security_level = SecurityLevel$HEStd_NotSet,
  scaling_technique = ScalingTechnique$FLEXIBLEAUTO,
  features = c(Feature$ADVANCEDSHE, Feature$FHE)
)
kk <- key_gen(ck, eval_mult = TRUE)
slots <- 8L
eval_bootstrap_setup(ck, level_budget, slots = slots)
eval_bootstrap_key_gen(ck, kk@secret, slots)
ktag <- get_key_tag(kk@secret)

y <- c(0.25, 0.5, 0.75, 1.0)
ctk <- encrypt(kk@public, make_ckks_packed_plaintext(ck, y, slots = slots), cc = ck)
boot <- function() {
  pt <- decrypt(eval_bootstrap(ctk), kk@secret, cc = ck)
  set_length(pt, length(y))
  get_real_packed_value(pt)
}
expect_equal(boot(), y, tolerance = 0.01)

for (fmt in c("binary", "json")) {
  fb <- file.path(tmpdir, paste0("boot.", fmt))
  expect_true(serialize_eval_bootstrap_key(fb, ck, ktag, slots, format = fmt))
  expect_true(file.size(fb) > 0)

  clear_eval_automorphism_keys(ktag)
  expect_error(eval_bootstrap(ctk))
  expect_true(deserialize_eval_bootstrap_key(fb, ck, ktag, slots, format = fmt))
  expect_equal(boot(), y, tolerance = 0.01)
}

## By index: only the indices asked for are registered.
fb <- file.path(tmpdir, "boot.binary")
idx <- get_existing_eval_automorphism_key_indices(ktag)
expect_true(length(idx) > 2L)
clear_eval_automorphism_keys(ktag)
expect_true(deserialize_eval_bootstrap_key(fb, key_tag = ktag,
                                           index_list = idx[1:2]))
expect_identical(sort(get_existing_eval_automorphism_key_indices(ktag)),
                 sort(idx[1:2]))
expect_true(deserialize_eval_bootstrap_key(fb, key_tag = ktag, index_list = idx))
expect_equal(boot(), y, tolerance = 0.01)

expect_error(deserialize_eval_bootstrap_key(fb, key_tag = ktag), "index_list")
expect_error(deserialize_eval_bootstrap_key(fb, ck, ktag), "slots")
expect_error(serialize_eval_bootstrap_key(file.path(tmpdir, "no-dir", "b.bin"),
                                          ck, ktag, slots))

unlink(tmpdir, recursive = TRUE)
clear_fhe_state()
