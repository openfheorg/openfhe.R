## @openfhe-python: src/lib/bindings.cpp (Eval* arg completion) [PARTIAL]
##
## The Eval* argument-completion
## surface. Covers the in-place, mutable, no-relin+relinearize,
## and mod/level/compress families.
library(openfhe.R)

# ── CKKS setup (FIXEDMANUAL so level changes are explicit) ──
cc <- fhe_context(
  "CKKS",
  multiplicative_depth = 4L,
  scaling_mod_size     = 50L,
  batch_size           = 8L,
  scaling_technique    = ScalingTechnique$FIXEDMANUAL
)
kp <- key_gen(cc, eval_mult = TRUE)

x <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
y <- c(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0)
z <- 2.5

## CKKS tolerance: project-standard 1e-6 for depth-4 / 50-bit
## circuits. (fhe_ckks_tolerance()'s per-level loss table is a
## placeholder; using the validated fixed value here
## to avoid a flaky numeric gate on the binding tests.)
tol <- 1e-6

make_ct <- function(vec) {
  encrypt(kp@public, make_ckks_packed_plaintext(cc, vec), cc)
}
decode <- function(ct, n = 8L) {
  pt <- decrypt(ct, kp@secret, cc)
  set_length(pt, n)
  get_real_packed_value(pt)[1:n]
}

# ══ In-place family ═════════════════════════════════════

# eval_add_in_place: ct/ct
a <- make_ct(x); b <- make_ct(y)
ret <- eval_add_in_place(a, b)
expect_identical(ret, a)
expect_equal(decode(a), x + y, tolerance = tol)

# eval_add_in_place: ct/pt
a <- make_ct(x); pt_y <- make_ckks_packed_plaintext(cc, y)
eval_add_in_place(a, pt_y)
expect_equal(decode(a), x + y, tolerance = tol)

# eval_add_in_place: ct/scalar
a <- make_ct(x)
eval_add_in_place(a, z)
expect_equal(decode(a), x + z, tolerance = tol)

# eval_add_in_place: type error
a <- make_ct(x)
expect_error(eval_add_in_place(a, "nope"),
             pattern = "Ciphertext, Plaintext, or numeric")

# eval_sub_in_place: ct/ct
a <- make_ct(x); b <- make_ct(y)
eval_sub_in_place(a, b)
expect_equal(decode(a), x - y, tolerance = tol)

# eval_sub_in_place: ct/pt
a <- make_ct(x); pt_y <- make_ckks_packed_plaintext(cc, y)
eval_sub_in_place(a, pt_y)
expect_equal(decode(a), x - y, tolerance = tol)

# eval_sub_in_place: ct/scalar
a <- make_ct(x)
eval_sub_in_place(a, z)
expect_equal(decode(a), x - z, tolerance = tol)

# eval_mult_in_place: scalar only (header surface)
a <- make_ct(x)
eval_mult_in_place(a, z)
expect_equal(decode(a), x * z, tolerance = tol)

# eval_mult_in_place: ct/ct must abort (not in header)
a <- make_ct(x); b <- make_ct(y)
expect_error(eval_mult_in_place(a, b), pattern = "numeric scalar")

# eval_negate_in_place
a <- make_ct(x)
ret <- eval_negate_in_place(a)
expect_identical(ret, a)
expect_equal(decode(a), -x, tolerance = tol)

# ══ Mutable family ══════════════════════════════════════

a <- make_ct(x); b <- make_ct(y)
r <- eval_add_mutable(a, b)
expect_true(S7::S7_inherits(r, Ciphertext))
expect_equal(decode(r), x + y, tolerance = tol)

a <- make_ct(x); b <- make_ct(y)
r <- eval_sub_mutable(a, b)
expect_equal(decode(r), x - y, tolerance = tol)

a <- make_ct(x); b <- make_ct(y)
r <- eval_mult_mutable(a, b)
expect_equal(decode(r), x * y, tolerance = tol)

a <- make_ct(x)
r <- eval_square_mutable(a)
expect_equal(decode(r), x * x, tolerance = tol)

# ══ No-relin + relinearize ══════════════════════════════

# eval_mult_no_relin returns a higher-degree ciphertext;
# relinearize reduces it back, and the decrypted value should
# match the ordinary ct * ct product.
a <- make_ct(x); b <- make_ct(y)
raw <- eval_mult_no_relin(a, b)
expect_true(S7::S7_inherits(raw, Ciphertext))
relin <- relinearize(raw)
expect_true(S7::S7_inherits(relin, Ciphertext))
expect_equal(decode(relin), x * y, tolerance = tol)

# eval_mult_and_relinearize: fused variant, same semantics.
a <- make_ct(x); b <- make_ct(y)
fused <- eval_mult_and_relinearize(a, b)
expect_equal(decode(fused), x * y, tolerance = tol)

# ══ mod_reduce / rescale parity ═════════════════════════

# Under FIXEDMANUAL, rescale / mod_reduce advance the level by
# one. Both names must dispatch to the same operation.
a <- make_ct(x); b <- make_ct(y)
prod <- eval_mult(a, b)
lvl0 <- get_level(prod)

r_rescale <- rescale(prod)
r_modred  <- mod_reduce(prod)
expect_equal(get_level(r_rescale), lvl0 + 1L)
expect_equal(get_level(r_modred),  lvl0 + 1L)
expect_equal(decode(r_rescale), decode(r_modred), tolerance = tol)

# mod_reduce_in_place: the same ptr advances a level.
prod2 <- eval_mult(a, b)
lvlA  <- get_level(prod2)
ret <- mod_reduce_in_place(prod2)
expect_identical(ret, prod2)
expect_equal(get_level(prod2), lvlA + 1L)
expect_equal(decode(prod2), x * y, tolerance = tol)

# ══ Compress ════════════════════════════════════════════

# compress truncates the RNS representation to `towers_left`
# towers. Decrypted values should still approximate x within a
# loosened tolerance (compression introduces additional noise
# relative to a fresh ciphertext).
a <- make_ct(x)
c1 <- compress(a, towers_left = 2L)
expect_true(S7::S7_inherits(c1, Ciphertext))
expect_equal(decode(c1), x, tolerance = max(tol * 10, 1e-3))

# ══ level_reduce generics exist (not exercised end-to-end) ══

# level_reduce / level_reduce_in_place require an EvalKey
# argument; no R-side accessor for the cc-stored eval-mult key
# exists yet, so the bindings are verified to compile and
# dispatch but the full-circuit test is deferred. Check that
# the generics are exported and dispatch on Ciphertext.
expect_true(inherits(level_reduce, "S7_generic"))
expect_true(inherits(level_reduce_in_place, "S7_generic"))
