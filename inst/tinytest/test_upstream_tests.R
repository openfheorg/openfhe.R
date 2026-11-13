## OPENFHE PYTHON SOURCE: tests/test_bgv.py, tests/test_boolean.py, tests/test_ckks.py, tests/test_cryptocontext.py, tests/test_serial_cc.py, tests/test_examples.py
##
## R port of the remaining upstream openfhe-python tests. Each section
## names the Python test it ports.
library(openfhe.R)

## Rotation with infill of 0 (the Python helper `shift`).
shift <- function(a, n) {
  i <- seq_along(a) - n
  ifelse(i >= 1L & i <= length(a), a[pmin(pmax(i, 1L), length(a))], 0)
}
## 5^k modulo a power of two m, for a signed k (Python `pow(5, k, m)`).
pow5 <- function(k, m) {
  base <- if (k < 0) which((5 * seq_len(m)) %% m == 1)[1] else 5
  r <- 1
  for (j in seq_len(abs(k))) r <- (r * base) %% m
  r
}

# ══ tests/test_bgv.py ════════════════════════════════════
## @openfhe-python: tests/test_bgv.py::test_roll [N/A FOR R: tests a Python helper the other tests do not use]
## @openfhe-python: tests/test_bgv.py::test_shift [FULL]
expect_equal(shift(1:8, 0), 1:8)
expect_equal(shift(1:8, 2), c(0, 0, 1:6))
expect_equal(shift(1:8, 3), c(0, 0, 0, 1:5))
expect_equal(shift(1:8, -1), c(2:8, 0))

bgv <- fhe_context("BGV", plaintext_modulus = 65537, multiplicative_depth = 2L)
bgv_keys <- key_gen(bgv)
eval_mult_key_gen(bgv, bgv_keys@secret)
eval_rotate_key_gen(bgv, bgv_keys@secret, c(1L, 2L, -1L, -2L))
bgv_dec <- function(ct, len) {
  pt <- decrypt(ct, bgv_keys@secret, cc = bgv)
  set_length(pt, len)
  as.numeric(get_packed_value(pt))
}

## @openfhe-python: tests/test_bgv.py::test_make_coef_packed_plaintext_accepts_keywords [FULL]
pt <- make_coef_packed_plaintext(bgv, c(1L, 2L, 3L), noise_scale_deg = 1L,
                                 level = 0L)
expect_equal(as.numeric(get_coef_packed_value(pt))[1:3], c(1, 2, 3))

## @openfhe-python: tests/test_bgv.py::test_simple_integers [FULL]
set.seed(342342)
raw <- replicate(3, sample.int(12L, 12L, replace = TRUE), simplify = FALSE)
cts <- lapply(raw, function(r)
  encrypt(bgv_keys@public, make_packed_plaintext(bgv, r), cc = bgv))
expect_equal(bgv_dec(cts[[1]], 12L), raw[[1]])
ct_add <- eval_add(eval_add(cts[[1]], cts[[2]]), cts[[3]])
expect_equal(bgv_dec(ct_add, 12L), raw[[1]] + raw[[2]] + raw[[3]])
ct_mult <- eval_mult(eval_mult(cts[[1]], cts[[2]]), cts[[3]])
expect_equal(bgv_dec(ct_mult, 12L), raw[[1]] * raw[[2]] * raw[[3]])
## A rotation with infill of 0, not a circular rotation.
for (rotation in c(1L, 2L, -1L, -2L)) {
  expect_equal(bgv_dec(eval_rotate(cts[[1]], rotation), 12L),
               shift(raw[[1]], -rotation))
}

## @openfhe-python: tests/test_bgv.py::test_numpy_int64_encode_decode_fast_paths [PARTIAL: R has one vector type where Python has list and numpy array; the 2-D rejection has no R counterpart]
## The R analog of list versus array is integer versus double storage.
set.seed(42429842)
raw32 <- sample.int(1000L, 32L, replace = TRUE) - 1L
pt_int <- make_packed_plaintext(bgv, raw32)
pt_dbl <- make_packed_plaintext(bgv, as.numeric(raw32))
expect_equal(get_packed_value(pt_int), get_packed_value(pt_dbl))
pt_coef <- make_coef_packed_plaintext(bgv, raw32, level = 1L)
expect_equal(get_level(pt_coef), 1)
expect_equal(as.numeric(get_coef_packed_value(pt_coef))[1:32], raw32)
expect_equal(bgv_dec(encrypt(bgv_keys@public, pt_int, cc = bgv), 32L), raw32)

# ══ tests/test_boolean.py ════════════════════════════════
## @openfhe-python: tests/test_boolean.py::test_boolean_AND [FULL]
bcc <- bin_fhe_context(BinFHEParamSet$STD128, BinFHEMethod$GINX)
bsk <- bin_key_gen(bcc)
bin_bt_key_gen(bcc, bsk)
for (a in 0:1) for (b in 0:1) {
  ct1 <- bin_encrypt(bcc, bsk, a)
  ct2 <- bin_encrypt(bcc, bsk, b)
  ct_and1 <- eval_bin_gate(bcc, BinGate$AND, ct1, ct2)
  ct_and2 <- eval_bin_gate(bcc, BinGate$AND, eval_not(bcc, ct2), ct1)
  result <- bin_decrypt(bcc, bsk, eval_bin_gate(bcc, BinGate$OR, ct_and1, ct_and2))
  expect_equal(result, as.integer((a && b) || (a && !b)))
}
## Release the bootstrapping keys now: R's collector does not see the
## memory behind a context, so the keys would otherwise stay until a
## collection happens to run (notes/discoveries/D043).
bin_clear_bt_keys(bcc)

# ══ tests/test_cryptocontext.py ══════════════════════════
## @openfhe-python: tests/test_cryptocontext.py::test_ckks_context [BUILD-CONFIG: runs only on a 128-bit native integer build; the package is built with 64-bit]

# ══ tests/test_ckks.py ═══════════════════════════════════
## @openfhe-python: tests/test_ckks.py::test_ckks_depth_helpers_are_on_crypto_context [FULL]
expect_true(get_bootstrap_depth(c(2L, 2L), SecretKeyDist$UNIFORM_TERNARY) > 0)
expect_true(get_bootstrap_depth(c(2L, 2L), SecretKeyDist$UNIFORM_TERNARY,
                                approx_mod_depth = 9L) > 0)
expect_true(get_fbt_depth(c(3L, 3L), c(1L, -1L), 2, 1L,
                          SecretKeyDist$SPARSE_ENCAPSULATED) > 0)
expect_true(get_fbt_depth(c(3L, 3L), c(1 + 0i, -1 + 0i), 4, 1L,
                          SecretKeyDist$SPARSE_ENCAPSULATED) > 0)
expect_true(get_fefbt_depth(c(3L, 2L), c(1 + 0i, -1 + 0i),
                            SecretKeyDist$SPARSE_ENCAPSULATED) > 0)

## The Python fixture, 64-bit branch.
batch_size <- 8L
ckks <- fhe_context("CKKS", multiplicative_depth = 5L, first_mod_size = 60L,
                    scaling_mod_size = 56L, batch_size = batch_size,
                    scaling_technique = ScalingTechnique$FLEXIBLEAUTO,
                    num_large_digits = 2L)
ckks_keys <- key_gen(ckks)
eval_rotate_key_gen(ckks, ckks_keys@secret, c(1L, -2L))
ckks_dec <- function(ct) {
  pt <- decrypt(ct, ckks_keys@secret, cc = ckks)
  set_length(pt, batch_size)
  get_real_packed_value(pt)
}

## @openfhe-python: tests/test_ckks.py::test_add_two_numbers [FULL]
set.seed(42429842)
raw2 <- list(runif(batch_size, -1, 1), runif(batch_size, -1, 1))
ct2 <- lapply(raw2, function(x)
  encrypt(ckks_keys@public, make_ckks_packed_plaintext(ckks, x), cc = ckks))
expect_true(sum(abs(raw2[[1]] + raw2[[2]] -
                    ckks_dec(eval_add(ct2[[1]], ct2[[2]])))) < 1e-3)

## @openfhe-python: tests/test_ckks.py::test_existing_eval_automorphism_key_indices [FULL]
keys2 <- key_gen(ckks)
tag2 <- get_key_tag(keys2@secret)
expect_equal(length(get_existing_eval_automorphism_key_indices(tag2)), 0L)
eval_rotate_key_gen(ckks, keys2@secret, c(1L, -2L))
## CKKS rotation offsets map to powers of 5 modulo the cyclotomic order.
m <- 2 * ring_dimension(ckks)
expected <- sort(c(pow5(1, m), pow5(-2, m)))
indices <- get_existing_eval_automorphism_key_indices(tag2)
expect_equal(as.numeric(indices), expected)
for (offset in c(1L, -2L)) {
  expect_equal(find_automorphism_index(ckks, offset), pow5(offset, m))
  expect_true(find_automorphism_index(ckks, offset) %in% indices)
}
## The empty tag matches no key map.
expect_equal(length(get_existing_eval_automorphism_key_indices("")), 0L)
## Repeated key generation must not duplicate indices or affect another tag.
eval_rotate_key_gen(ckks, keys2@secret, c(1L, 3L))
expect_equal(as.numeric(get_existing_eval_automorphism_key_indices(tag2)),
             sort(c(expected, pow5(3, m))))
expect_equal(as.numeric(get_existing_eval_automorphism_key_indices(
  get_key_tag(ckks_keys@secret))), expected)

## @openfhe-python: tests/test_ckks.py::test_find_automorphism_indices_signed_offsets [FULL]
offsets <- c(0L, 1L, -2L, 3L, -1L, -2L)
expected_idx <- vapply(offsets, pow5, numeric(1), m = m)
expect_equal(as.numeric(find_automorphism_indices(ckks, offsets)), expected_idx)
expect_equal(vapply(offsets, function(o)
  as.numeric(find_automorphism_index(ckks, o)), numeric(1)), expected_idx)
expect_equal(length(find_automorphism_indices(ckks, integer())), 0L)
for (offset in c(-(2^31) - 1, 2^31)) {
  expect_error(find_automorphism_index(ckks, offset))
  expect_error(find_automorphism_indices(ckks, c(1, offset)))
}

## @openfhe-python: tests/test_ckks.py::test_existing_bootstrap_key_indices [FULL]
level_budget <- c(2L, 2L)
depth <- get_bootstrap_depth(level_budget, SecretKeyDist$UNIFORM_TERNARY)
boot <- fhe_context("CKKS",
  security_level = SecurityLevel$HEStd_NotSet, ring_dim = 512L,
  secret_key_dist = SecretKeyDist$UNIFORM_TERNARY,
  multiplicative_depth = depth + 2L,
  scaling_technique = ScalingTechnique$FIXEDAUTO,
  scaling_mod_size = 59L, first_mod_size = 60L,
  features = c(Feature$ADVANCEDSHE, Feature$FHE))
slots <- 8L
eval_bootstrap_setup(boot, level_budget, c(0L, 0L), slots)
boot_keys <- key_gen(boot)
boot_tag <- get_key_tag(boot_keys@secret)
expect_equal(length(get_existing_eval_automorphism_key_indices(boot_tag)), 0L)
eval_bootstrap_key_gen(boot, boot_keys@secret, slots)
boot_idx <- as.numeric(get_existing_eval_automorphism_key_indices(boot_tag))
expect_equal(boot_idx, sort(unique(boot_idx)))
expect_true(length(boot_idx) > 1L)
expect_true((2 * ring_dimension(boot) - 1) %in% boot_idx)   # conjugation key

## @openfhe-python: tests/test_ckks.py::test_numpy_encode_decode_fast_paths [PARTIAL: R has one vector type where Python has list and numpy array; the 2-D rejection has no R counterpart]
set.seed(42429842)
rawc <- runif(batch_size, -1, 1)
pt_real <- make_ckks_packed_plaintext(ckks, rawc)
pt_cplx <- make_ckks_packed_plaintext(ckks, as.complex(rawc))
expect_equal(get_real_packed_value(pt_real), get_real_packed_value(pt_cplx))
expect_equal(Re(get_complex_packed_value(pt_real)),
             get_real_packed_value(pt_real))
expect_true(max(abs(ckks_dec(encrypt(ckks_keys@public, pt_real, cc = ckks)) -
                      rawc)) < 1e-3)

## @openfhe-python: tests/test_ckks.py::test_eval_fast_rotation_matches_eval_rotate [FULL]
set.seed(7)
rawr <- runif(batch_size, -1, 1)
ctr <- encrypt(ckks_keys@public, make_ckks_packed_plaintext(ckks, rawr),
               cc = ckks)
digits <- eval_fast_rotation_precompute(ctr)
## An index is repeated: the reused digits must stay intact.
for (index in c(1L, -2L, 1L)) {
  expect_true(max(abs(ckks_dec(eval_fast_rotation(ctr, index, m, digits)) -
                        ckks_dec(eval_rotate(ctr, index)))) < 1e-3)
}

# ══ tests/test_serial_cc.py ══════════════════════════════
## @openfhe-python: tests/test_serial_cc.py::test_serial_cryptocontext [FULL]
dir_ser <- tempfile("serial_cc")
dir.create(dir_ser)
bfv <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2L)
kp <- key_gen(bfv)
ct_ser <- encrypt(kp@public, make_packed_plaintext(bfv, 0:11), cc = bfv)
f <- function(name) file.path(dir_ser, name)
expect_true(fhe_serialize(bfv, f("cryptocontext.json"), format = "json"))
expect_true(fhe_serialize(ct_ser, f("ciphertext1.json"), format = "json"))
clear_fhe_state()
cc_in <- fhe_deserialize(f("cryptocontext.json"), "CryptoContext", format = "json")
expect_true(S7::S7_inherits(cc_in, CryptoContext))
expect_true(fhe_serialize(cc_in, f("cryptocontext2.json"), format = "json"))
ct_in <- fhe_deserialize(f("ciphertext1.json"), "Ciphertext", format = "json")
expect_true(S7::S7_inherits(ct_in, Ciphertext))
expect_true(fhe_serialize(ct_in, f("ciphertext12.json"), format = "json"))
unlink(dir_ser, recursive = TRUE)

## @openfhe-python: tests/test_serial_cc.py::test_serial_cryptocontext_str [FULL]
rotate_vector <- function(v, rotation) {
  n <- length(v)
  if (rotation > 0) c(v[(rotation + 1L):n], rep(0, rotation))
  else if (rotation < 0) c(rep(0, -rotation), v[seq_len(n + rotation)])
  else v
}
rotations <- c(1L, 2L, -1L, -2L)
v1 <- 1:12
v2 <- c(3L, 2L, 1L, 4:12)
v3 <- c(1L, 2L, 5L, 2L, 5:12)
for (mode in c("json", "binary")) {
  cc0 <- fhe_context("BFV", plaintext_modulus = 65537,
                     multiplicative_depth = 2L, features = Feature$PRE)
  kp0 <- key_gen(cc0)
  c1 <- encrypt(kp0@public, make_packed_plaintext(cc0, v1), cc = cc0)
  c2 <- encrypt(kp0@public, make_packed_plaintext(cc0, v2), cc = cc0)
  c3 <- encrypt(kp0@public, make_packed_plaintext(cc0, v3), cc = cc0)
  eval_key <- re_key_gen(cc0, kp0@secret, kp0@public)
  eval_mult_key_gen(cc0, kp0@secret)
  eval_rotate_key_gen(cc0, kp0@secret, rotations)

  cc_ser <- fhe_serialize(cc0, format = mode)
  pk_ser <- fhe_serialize(kp0@public, format = mode)
  sk_ser <- fhe_serialize(kp0@secret, format = mode)
  c1_ser <- fhe_serialize(c1, format = mode)
  c2_ser <- fhe_serialize(c2, format = mode)
  c3_ser <- fhe_serialize(c3, format = mode)
  ek_ser <- fhe_serialize(eval_key, format = mode)
  mult_ser <- serialize_eval_keys(type = "mult", format = mode, key_tag = "")
  auto_ser <- serialize_eval_keys(type = "automorphism", format = mode,
                                  key_tag = "")

  clear_fhe_state()

  cc1 <- fhe_deserialize_string(cc_ser, "CryptoContext", format = mode)
  expect_true(S7::S7_inherits(cc1, CryptoContext))
  pk1 <- fhe_deserialize_string(pk_ser, "PublicKey", format = mode)
  expect_true(S7::S7_inherits(pk1, PublicKey))
  sk1 <- fhe_deserialize_string(sk_ser, "PrivateKey", format = mode)
  expect_true(S7::S7_inherits(sk1, PrivateKey))
  d1 <- fhe_deserialize_string(c1_ser, "Ciphertext", format = mode)
  d2 <- fhe_deserialize_string(c2_ser, "Ciphertext", format = mode)
  d3 <- fhe_deserialize_string(c3_ser, "Ciphertext", format = mode)
  expect_true(S7::S7_inherits(d1, Ciphertext))
  expect_true(S7::S7_inherits(d2, Ciphertext))
  expect_true(S7::S7_inherits(d3, Ciphertext))
  ek1 <- fhe_deserialize_string(ek_ser, "EvalKey", format = mode)
  expect_true(S7::S7_inherits(ek1, EvalKey))
  deserialize_eval_keys_string(mult_ser, type = "mult", format = mode)
  deserialize_eval_keys_string(auto_ser, type = "automorphism", format = mode)

  dec1 <- function(ct) {
    p <- decrypt(ct, sk1, cc = cc1)
    set_length(p, length(v1))
    as.numeric(get_packed_value(p))
  }
  expect_equal(dec1(eval_add(eval_add(d1, d2), d3)), v1 + v2 + v3)
  expect_equal(dec1(eval_mult(eval_mult(d1, d2), d3)), v1 * v2 * v3)
  expect_equal(dec1(eval_rotate(d1, 1L)), rotate_vector(v1, 1L))
  expect_equal(dec1(eval_rotate(d2, 2L)), rotate_vector(v2, 2L))
  expect_equal(dec1(eval_rotate(d3, -1L)), rotate_vector(v3, -1L))
  expect_equal(dec1(eval_rotate(d3, -2L)), rotate_vector(v3, -2L))
}

# ══ tests/test_examples.py ═══════════════════════════════
## @openfhe-python: tests/test_examples.py::test_run_scripts [N/A FOR R: each example is ported as a test_example_*.R or test_*.R file with assertions]
## @openfhe-python: tests/test_examples.py::test_run_slow_scripts [N/A FOR R: as above; test_fbt.R and the OPENFHE_R_LARGE_MEMORY_TESTS gate]
## @openfhe-python: tests/test_examples.py::test_run_binfhe_scripts [N/A FOR R: as above]
## @openfhe-python: tests/test_examples.py::test_example_inventory_is_complete [N/A FOR R: the inventory is notes/test_parity.md; the example sources are not part of the package]

clear_fhe_state()
