## @openfhe-python: src/lib/bindings.cpp (CKKS complex plaintext + automorphism) [PARTIAL]
##
## Six new cpp11
## bindings covering:
##   - CKKS complex plaintext round-trip
##     (MakeCKKSPackedPlaintext complex overload +
##      GetCKKSPackedValue reader)
##   - Automorphism surface (FindAutomorphismIndex /
##     FindAutomorphismIndices / EvalAutomorphismKeyGen /
##     EvalAutomorphism)
##
## FindAutomorphismIndex and FindAutomorphismIndices are
## R-first (openfhe-python does not bind them) — logged in
## notes/upstream-defects.md.
library(openfhe.R)

clear_eval_mult_keys()
clear_eval_automorphism_keys()

# ── CKKS setup with COMPLEX data type ──────────────────

## CKKS contexts default to `CKKSDataType = REAL` which
## silently discards the imaginary parts of any complex
## plaintext. To exercise the complex round-trip we need to
## request `CKKSDataType$COMPLEX` at context construction
## — this is the usage
## pattern the Python bindings expose via the
## `ckks_data_type` CCParams setter.
cc <- fhe_context("CKKS",
  multiplicative_depth = 2L,
  scaling_mod_size     = 50L,
  batch_size           = 8L,
  ckks_data_type       = CKKSDataType$COMPLEX
)
kp <- key_gen(cc, eval_mult = TRUE)

tol <- 1e-6

# ── Complex plaintext round-trip ────────────────────────

## Encode a vector of complex numbers and verify the round-
## trip through GetCKKSPackedValue preserves both real and
## imaginary parts to CKKS tolerance.
z_in <- c(1 + 2i, 3 + 4i, -1 - 1i, 0.5 + 0.5i, 0 + 1i, 1 + 0i,
          -2 + 0.5i, 0.25 - 0.75i)
pt_complex <- make_ckks_packed_plaintext(cc, z_in)
expect_true(S7::S7_inherits(pt_complex, Plaintext))

## Read back via the new complex accessor.
z_out <- get_complex_packed_value(pt_complex)
expect_true(is.complex(z_out))
expect_true(length(z_out) >= length(z_in))

## Real and imaginary parts match to CKKS tolerance.
expect_equal(Re(z_out[1:length(z_in)]), Re(z_in), tolerance = tol)
expect_equal(Im(z_out[1:length(z_in)]), Im(z_in), tolerance = tol)

## Encrypt → decrypt round-trip also preserves the complex
## values.
ct_complex <- encrypt(kp@public, pt_complex, cc = cc)
pt_dec <- decrypt(ct_complex, kp@secret, cc = cc)
set_length(pt_dec, length(z_in))
z_dec <- get_complex_packed_value(pt_dec)
expect_equal(Re(z_dec[1:length(z_in)]), Re(z_in), tolerance = tol)
expect_equal(Im(z_dec[1:length(z_in)]), Im(z_in), tolerance = tol)

# ── Real fallback backward compat ──────────────────────

## The double path still works — dispatching on
## is.complex(values) with a numeric (non-complex) input
## routes to the original binding.
x_real <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
pt_real <- make_ckks_packed_plaintext(cc, x_real)
expect_true(S7::S7_inherits(pt_real, Plaintext))

## get_real_packed_value still works on the real plaintext.
ct_real <- encrypt(kp@public, pt_real, cc = cc)
pt_real_dec <- decrypt(ct_real, kp@secret, cc = cc)
set_length(pt_real_dec, 8L)
expect_equal(get_real_packed_value(pt_real_dec)[1:8], x_real,
             tolerance = tol)

## And get_complex_packed_value on a real-constructed plaintext
## gives complex numbers with ~0 imaginary parts.
pt_real2 <- make_ckks_packed_plaintext(cc, x_real)
z_from_real <- get_complex_packed_value(pt_real2)
expect_true(is.complex(z_from_real))
expect_equal(Re(z_from_real[1:8]), x_real, tolerance = tol)
expect_equal(Im(z_from_real[1:8]), rep(0, 8), tolerance = tol)

## Error path: complex values + non-NULL params aborts via
## cli::cli_abort.
expect_error(make_ckks_packed_plaintext(cc, c(1+2i, 3+4i),
                                        params = list(dummy = 1)),
             pattern = "complex path")

# ── FindAutomorphismIndex ───────────────────────────────

## For any CKKS context, FindAutomorphismIndex(1) should
## return a non-zero automorphism index corresponding to
## a left-by-1 rotation.
idx1 <- find_automorphism_index(cc, 1L)
expect_true(is.numeric(idx1))
expect_equal(length(idx1), 1L)
expect_true(idx1 > 0L)

## And for a different slot index, a different automorphism
## index (generally).
idx2 <- find_automorphism_index(cc, 2L)
expect_true(idx2 > 0L)

# ── FindAutomorphismIndices ─────────────────────────────

## Vector form returns a parallel vector of automorphism
## indices.
slot_indices <- c(1L, 2L, -1L, 3L)
auto_indices <- find_automorphism_indices(cc, slot_indices)
expect_true(is.integer(auto_indices))
expect_equal(length(auto_indices), length(slot_indices))
## The first element matches the scalar call.
expect_equal(auto_indices[1], idx1)
expect_equal(auto_indices[2], idx2)

# ── EvalAutomorphismKeyGen + EvalAutomorphism ──────────

## Generate automorphism eval keys for slot-index-1, then
## apply via eval_automorphism to a fresh ciphertext.
## The result is a rotated ciphertext whose decryption is a
## slot permutation of the original.
x2 <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0)
pt2 <- make_ckks_packed_plaintext(cc, x2)
ct2 <- encrypt(kp@public, pt2, cc = cc)

auto_idx_1 <- find_automorphism_index(cc, 1L)
eval_key_map <- eval_automorphism_key_gen(cc, kp@secret,
                                          c(auto_idx_1))
expect_true(S7::S7_inherits(eval_key_map, EvalKeyMap))
expect_true(openfhe.R:::ptr_is_valid(eval_key_map))

ct_auto <- eval_automorphism(ct2, auto_idx_1, eval_key_map)
expect_true(S7::S7_inherits(ct_auto, Ciphertext))

## Decrypt and verify the rotation: rotating c(1..8) left by 1
## gives c(2, 3, 4, 5, 6, 7, 8, 1).
pt_auto <- decrypt(ct_auto, kp@secret, cc = cc)
set_length(pt_auto, 8L)
expect_equal(get_real_packed_value(pt_auto)[1:7],
             x2[2:8], tolerance = tol)

# ── Formals shape assertions ────────────────────────────

expect_identical(names(formals(find_automorphism_index)),
                 c("cc", "index"))
expect_identical(names(formals(find_automorphism_indices)),
                 c("cc", "indices"))
expect_identical(names(formals(eval_automorphism_key_gen)),
                 c("cc", "sk", "indices"))
expect_identical(names(formals(eval_automorphism)),
                 c("ct", "index", "eval_key_map"))
expect_identical(names(formals(get_complex_packed_value)), "pt")

## make_ckks_packed_plaintext still has its original formals.
expect_identical(names(formals(make_ckks_packed_plaintext)),
                 c("cc", "values", "noise_scale_deg", "level",
                   "params", "slots"))
