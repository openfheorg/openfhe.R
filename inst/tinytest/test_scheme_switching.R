## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (SchSwchParams; scheme switching between CKKS and FHEW)
##
## @openfhe-python: scheme-switching.py [PARTIAL: steps omitted: FloorViaSchemeSwitching, FuncViaSchemeSwitching, PolyViaSchemeSwitching, the two Unit argmin functions, the digit decomposition and the large-precision inputs of SwitchCKKSToFHEW, the medium- and large-precision inputs of SwitchFHEWtoCKKS]
##
## Every scheme-switching binding is called here. The parameter sets
## are those of the Python example's functions of the same name.
library(openfhe.R)

at_home <- tinytest::at_home()
sl <- SecurityLevel$HEStd_NotSet
sl_bin <- BinFHEParamSet$TOY

# ══ SchSwchParams ════════════════════════════════════════
ns <- asNamespace("openfhe.R")
fields <- names(ns$.SCHSWCH_FIELD)
## The field codes are 0..17 in table order, as in enum SchSwchField.
expect_identical(unname(ns$.SCHSWCH_FIELD), 0:17)

p0 <- SchSwchParams()
expect_true(S7::S7_inherits(p0, SchSwchParams))
expect_equal(openfhe.R:::xptr_type(p0@ptr), "openfhe.R::SchSwchParams")
## The getters refuse an object whose CKKS fields have not been filled.
expect_error(get_num_slots_ckks(p0))
expect_true(is.character(format(p0)) && nzchar(format(p0)))
expect_true(any(grepl("SchSwchParams", capture.output(print(p0)))))

## Mark it filled; the library defaults are then readable.
expect_identical(set_params_from_ckks_cryptocontext_called(p0), p0)
expect_identical(get_security_level_ckks(p0), SecurityLevel$HEStd_128_classic)
expect_identical(get_security_level_fhew(p0), BinFHEParamSet$STD128)
expect_identical(get_ctxt_mod_size_fhew_large_prec(p0), 25L)
expect_identical(get_ctxt_mod_size_fhew_intermed_swch(p0), 27L)
expect_identical(get_level_ltr_ckks_to_fhew(p0), 1L)
expect_identical(get_level_ltr_fhew_to_ckks(p0), 0L)
expect_identical(get_one_hot_encoding(p0), TRUE)
expect_identical(get_compute_argmin(p0), FALSE)
expect_identical(get_initial_ckks_modulus(p0), "0")

## Every setter, twice with different values, read back through its
## getter: a field code that reached the wrong C++ setter fails here.
values <- list(
  security_level_ckks = list(SecurityLevel$HEStd_NotSet, SecurityLevel$HEStd_192_classic),
  security_level_fhew = list(BinFHEParamSet$TOY, BinFHEParamSet$MEDIUM),
  arbitrary_function_evaluation = list(TRUE, FALSE),
  use_dynamic_mode_fhew = list(TRUE, FALSE),
  compute_argmin = list(TRUE, FALSE),
  one_hot_encoding = list(FALSE, TRUE),
  use_alt_argmin = list(TRUE, FALSE),
  num_slots_ckks = list(16L, 32L),
  num_values = list(8L, 4L),
  ctxt_mod_size_fhew_large_prec = list(23L, 26L),
  ctxt_mod_size_fhew_intermed_swch = list(28L, 29L),
  b_step_ltr_ckks_to_fhew = list(3L, 5L),
  b_step_ltr_fhew_to_ckks = list(7L, 9L),
  level_ltr_ckks_to_fhew = list(2L, 3L),
  level_ltr_fhew_to_ckks = list(4L, 6L),
  ring_dimension = list(4096L, 8192L),
  scaling_mod_size = list(50L, 45L),
  batch_size = list(16L, 64L)
)
expect_identical(sort(names(values)), sort(fields))
for (f in fields) {
  setter <- get(paste0("set_", f), envir = ns)
  getter <- get(paste0("get_", f), envir = ns)
  for (v in values[[f]]) {
    expect_identical(setter(p0, v), p0, info = f)
    expect_identical(getter(p0), v, info = f)
  }
}
set_initial_ckks_modulus(p0, "1152921504606846976")
expect_identical(get_initial_ckks_modulus(p0), "1152921504606846976")
set_initial_ckks_modulus(p0, 12345)
expect_identical(get_initial_ckks_modulus(p0), "12345")
## Each setter changes its own field in the printed form.
before <- format(p0)
set_num_values(p0, 2L)
expect_false(identical(format(p0), before))

expect_error(set_num_slots_ckks(p0, -1), "non-negative")
expect_error(set_num_slots_ckks(p0, 1.5), "non-negative")
expect_error(set_compute_argmin(p0, 1L), "TRUE")
expect_error(set_initial_ckks_modulus(p0, -5))
expect_error(set_num_values(SecurityLevel, 1L))

new_params <- function(slots, log_q, num_values = NULL) {
  p <- SchSwchParams()
  set_security_level_ckks(p, sl)
  set_security_level_fhew(p, sl_bin)
  set_ctxt_mod_size_fhew_large_prec(p, log_q)
  set_num_slots_ckks(p, slots)
  if (!is.null(num_values)) set_num_values(p, num_values)
  p
}

# ══ CKKS -> FHEW (SwitchCKKSToFHEW) ══════════════════════
slots <- 16L
log_q <- 25L
cc <- fhe_context("CKKS",
  multiplicative_depth = 3L, first_mod_size = 60L, scaling_mod_size = 50L,
  scaling_technique = ScalingTechnique$FIXEDMANUAL, security_level = sl,
  ring_dim = 4096L, batch_size = slots,
  features = Feature$SCHEMESWITCH)
keys <- key_gen(cc)
expect_null(get_bin_cc_for_scheme_switch(cc))

params <- new_params(slots, log_q)
sk_fhew <- eval_ckks_to_fhew_setup(cc, params)
expect_true(S7::S7_inherits(sk_fhew, LWEPrivateKey))
## The setup filled the CKKS fields of the parameter object.
expect_identical(get_ring_dimension(params), 4096L)
expect_identical(get_scaling_mod_size(params), 50L)
expect_identical(get_batch_size(params), slots)
expect_identical(get_initial_ckks_modulus(params), get_modulus_ckks(cc))
expect_identical(get_num_slots_ckks(params), slots)

cc_lwe <- get_bin_cc_for_scheme_switch(cc)
expect_true(S7::S7_inherits(cc_lwe, BinFHEContext))
expect_identical(eval_ckks_to_fhew_key_gen(cc, keys, sk_fhew), cc)
expect_error(eval_ckks_to_fhew_key_gen(cc, keys@public, sk_fhew), "KeyPair")

p_lwe1 <- get_max_plaintext_space(cc_lwe)
expect_identical(eval_ckks_to_fhew_precompute(cc, 1 / p_lwe1), cc)

x1 <- c(0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 2.0, 3.0, 4.0,
        5.0, 6.0)
c1 <- encrypt(keys@public, make_ckks_packed_plaintext(cc, x1, 1L, 0L), cc = cc)
lwe <- eval_ckks_to_fhew(c1, length(x1))
expect_true(is.list(lwe) && length(lwe) == length(x1))
expect_true(all(vapply(lwe, function(z) S7::S7_inherits(z, LWECiphertext),
                       logical(1))))
got <- vapply(lwe, function(z) bin_decrypt(cc_lwe, sk_fhew, z, p_lwe1),
              integer(1))
## Rounded values modulo the FHEW plaintext modulus; a value on a
## rounding boundary may land on either side.
want <- round(x1) %% p_lwe1
ok <- got == want | (abs(x1 - floor(x1) - 0.5) < 1e-9 &
                     got %in% c(floor(x1) %% p_lwe1, ceiling(x1) %% p_lwe1))
expect_true(all(ok))
## num_ctxts limits the number of ciphertexts.
expect_identical(length(eval_ckks_to_fhew(c1, 4L)), 4L)

## The FHEW context can be replaced.
expect_identical(set_bin_cc_for_scheme_switch(cc, cc_lwe), cc)
expect_true(S7::S7_inherits(get_bin_cc_for_scheme_switch(cc), BinFHEContext))

# ══ FHEW -> CKKS (SwitchFHEWtoCKKS) ══════════════════════
log_q2 <- 28L
cf <- fhe_context("CKKS",
  multiplicative_depth = 3L + 9L + 1L, scaling_mod_size = 50L,
  scaling_technique = ScalingTechnique$FIXEDAUTO, security_level = sl,
  ring_dim = 8192L, batch_size = slots,
  features = c(Feature$ADVANCEDSHE, Feature$SCHEMESWITCH))
kf <- key_gen(cf)
bl <- bin_fhe_context(BinFHEParamSet$TOY, arb_func = FALSE, log_q = log_q2,
                      n = 0L, method = BinFHEMethod$GINX,
                      time_optimization = FALSE)
lwesk <- bin_key_gen(bl)
expect_null(get_swk_fc(cf))
expect_identical(eval_fhew_to_ckks_setup(cf, bl, slots, log_q2), cf)
expect_identical(eval_fhew_to_ckks_key_gen(cf, kf, lwesk), cf)
## The key generation stored the switching key, a CKKS ciphertext.
swk <- get_swk_fc(cf)
expect_true(S7::S7_inherits(swk, Ciphertext))
expect_identical(set_swk_fc(cf, swk), cf)

decf <- function(ct) {
  pt <- decrypt(ct, kf@secret, cc = cf)
  set_length(pt, slots)
  get_real_packed_value(pt)
}
b1 <- rep(c(1L, 1L, 0L, 0L), 4L)
lwe1 <- lapply(b1, function(b) bin_encrypt(bl, lwesk, b))
expect_equal(decf(eval_fhew_to_ckks(cf, lwe1, slots, slots)), b1,
             tolerance = 0.05)
## With the plaintext modulus and range given.
p_small <- get_max_plaintext_space(bl)
lwe2 <- lapply(b1, function(b) bin_encrypt(bl, lwesk, b, BinFHEOutput$FRESH,
                                           p_small))
expect_equal(decf(eval_fhew_to_ckks(cf, lwe2, slots, slots, p_small, 0,
                                    p_small)), b1, tolerance = 0.05)
expect_error(eval_fhew_to_ckks(cf, lwe1[[1L]], slots, slots), "must be a list")
expect_error(eval_fhew_to_ckks(cf, list(swk), slots, slots), "LWECiphertext")

# ══ Comparison (ComparisonViaSchemeSwitching) ════════════
if (at_home) {
  cs <- fhe_context("CKKS",
    multiplicative_depth = 17L, scaling_mod_size = 50L, first_mod_size = 60L,
    scaling_technique = ScalingTechnique$FIXEDAUTO, security_level = sl,
    ring_dim = 8192L, batch_size = slots,
    secret_key_dist = SecretKeyDist$UNIFORM_TERNARY,
    key_switch_technique = KeySwitchTechnique$HYBRID, num_large_digits = 3L,
    features = c(Feature$ADVANCEDSHE, Feature$SCHEMESWITCH))
  ks <- key_gen(cs)
  ps <- new_params(slots, log_q, slots)
  sks <- eval_scheme_switching_setup(cs, ps)
  expect_true(S7::S7_inherits(sks, LWEPrivateKey))
  expect_identical(get_num_values(ps), slots)
  bs <- get_bin_cc_for_scheme_switch(cs)
  expect_identical(eval_scheme_switching_key_gen(cs, ks, sks), cs)

  p_lwe2 <- 2^log_q / (2 * get_beta(bs))
  expect_identical(eval_compare_switch_precompute(cs, p_lwe2, 1), cs)

  a <- as.numeric(0:15)
  b <- rep(5.25, slots)
  ca <- encrypt(ks@public, make_ckks_packed_plaintext(cs, a, 1L, 0L, NULL, slots),
                cc = cs)
  cb <- encrypt(ks@public, make_ckks_packed_plaintext(cs, b, 1L, 0L, NULL, slots),
                cc = cs)
  res <- eval_compare_scheme_switching(ca, cb, slots, slots)
  pt <- decrypt(res, ks@secret, cc = cs)
  set_length(pt, slots)
  ## 1 where a < b, on the differences as FHEW sees them: with
  ## scale_sign = 1 they are rounded to whole numbers, so 5 - 5.25
  ## counts as zero and not as negative.
  expect_equal(round(get_real_packed_value(pt)), as.numeric(round(a - b) < 0))

  # ══ Minimum and maximum (ArgminViaSchemeSwitching) ══════
  argmin_case <- function(alt) {
    num_values <- 16L
    ca <- fhe_context("CKKS",
      multiplicative_depth = 9L + 3L + 1L + log2(num_values),
      scaling_mod_size = 50L, first_mod_size = 60L,
      scaling_technique = ScalingTechnique$FIXEDMANUAL, security_level = sl,
      ring_dim = 8192L, batch_size = slots,
      features = c(Feature$ADVANCEDSHE, Feature$SCHEMESWITCH))
    ka <- key_gen(ca)
    pa <- new_params(slots, log_q, num_values)
    set_compute_argmin(pa, TRUE)
    if (alt) set_use_alt_argmin(pa, TRUE)
    ska <- eval_scheme_switching_setup(ca, pa)
    ba <- get_bin_cc_for_scheme_switch(ca)
    eval_scheme_switching_key_gen(ca, ka, ska)
    eval_compare_switch_precompute(ca, 2^log_q / (2 * get_beta(ba)), 512)

    v <- c(-1.125, -1.12, 5.0, 6.0, -1.0, 2.0, 8.0, -1.0, 9.0, 10.0, 11.0,
           12.0, 13.0, 14.0, 15.25, 15.30)
    cv <- encrypt(ka@public, make_ckks_packed_plaintext(ca, v), cc = ca)
    read <- function(ct, n) {
      pt <- decrypt(ct, ka@secret, cc = ca)
      set_length(pt, n)
      get_real_packed_value(pt)
    }
    f_min <- if (alt) eval_min_scheme_switching_alt else eval_min_scheme_switching
    f_max <- if (alt) eval_max_scheme_switching_alt else eval_max_scheme_switching
    rmin <- f_min(cv, ka@public, num_values, slots)
    rmax <- f_max(cv, ka@public, num_values, slots)
    list(n = c(length(rmin), length(rmax)),
         min = read(rmin[[1L]], 1L), argmin = read(rmin[[2L]], num_values),
         max = read(rmax[[1L]], 1L), argmax = read(rmax[[2L]], num_values),
         v = v)
  }
  for (alt in c(FALSE, TRUE)) {
    r <- argmin_case(alt)
    expect_identical(r$n, c(2L, 2L))
    expect_equal(r$min, min(r$v), tolerance = 0.01)
    expect_equal(r$max, max(r$v), tolerance = 0.01)
    ## One-hot encoded index.
    expect_identical(which(round(r$argmin) == 1), which.min(r$v))
    expect_identical(which(round(r$argmax) == 1), which.max(r$v))
  }
}
