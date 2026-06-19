## Phase 8: BGV full arithmetic (matching BFV test coverage)
## @openfhe-python: simple-integers-bgvrns.py [FULL]
library(openfhe.R)

cc <- fhe_context("BGV", plaintext_modulus = 65537, multiplicative_depth = 2)
keys <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, -1L))

x <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L)
y <- c(10L, 20L, 30L, 40L, 50L, 60L, 70L, 80L)

ct_x <- encrypt(keys@public, make_packed_plaintext(cc, x), cc = cc)
ct_y <- encrypt(keys@public, make_packed_plaintext(cc, y), cc = cc)

get_result <- function(ct, n = 8L) {
  res <- decrypt(ct, keys@secret, cc = cc)
  set_length(res, n)
  get_packed_value(res)[1:n]
}

## @openfhe-python: simple-integers-bgvrns.py — encrypt/decrypt round-trip
expect_identical(get_result(ct_x), x)

## @openfhe-python: simple-integers-bgvrns.py — ct + ct
expect_identical(get_result(ct_x + ct_y), (x + y) %% 65537L)

## @openfhe-python: simple-integers-bgvrns.py — ct - ct
expect_identical(get_result(ct_y - ct_x), (y - x) %% 65537L)

## @openfhe-python: simple-integers-bgvrns.py — ct * ct
expect_identical(get_result(ct_x * ct_y), (x * y) %% 65537L)

## @openfhe-python: simple-integers-bgvrns.py — ct + scalar
expect_identical(get_result(ct_x + 100L), (x + 100L) %% 65537L)

## @openfhe-python: simple-integers-bgvrns.py — ct * scalar
expect_identical(get_result(ct_x * 3L), (x * 3L) %% 65537L)

## @openfhe-python: simple-integers-bgvrns.py — negate
expect_identical(get_result(-ct_x), -x)

## @openfhe-python: simple-integers-bgvrns.py — rotation
ct_rot <- eval_rotate(ct_x, 1L)
rotated <- get_result(ct_rot)
expect_identical(rotated[1:7], x[2:8])
