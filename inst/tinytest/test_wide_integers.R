## @openfhe-python: (no direct example) [N/A FOR R: R-specific transport of 64-bit and big integers]
##
## OpenFHE integers that can exceed 53 bits cross the R boundary as
## strings of decimal digits. openfhe-python returns and accepts exact
## Python int for the same values (src/include/integer_conversions.h).
library(openfhe.R)

wide <- openfhe.R:::wide_integer

## ── wide_integer(): the one normalizer on the way in ────────────
expect_identical(wide(0), "0")
expect_identical(wide(65537L), "65537")
expect_identical(wide(65537), "65537")
expect_identical(wide(2^53), "9007199254740992")
expect_identical(wide("1152921504606846976"), "1152921504606846976")
expect_identical(wide("000123"), "123")
expect_identical(wide("0"), "0")
expect_identical(wide("000"), "0")
## A string far beyond 64 bits is passed through; the range check
## belongs to the receiving C++ type.
big <- paste(rep("9", 60), collapse = "")
expect_identical(wide(big), big)

expect_error(wide(2^53 + 2), "above 2\\^53")
expect_error(wide(-1), "non-negative whole number")
expect_error(wide(1.5), "non-negative whole number")
expect_error(wide(NA_real_), "non-negative whole number")
expect_error(wide(NA_character_), "non-negative whole number")
expect_error(wide(c(1, 2)), "non-negative whole number")
expect_error(wide("12a"), "non-negative whole number")
expect_error(wide("-5"), "non-negative whole number")
expect_error(wide("1e6"), "non-negative whole number")
expect_error(wide(""), "non-negative whole number")
expect_error(wide(TRUE), "non-negative whole number")
expect_error(wide(NULL), "non-negative whole number")
## The error names the caller's argument.
f <- function(modulus) wide(modulus)
expect_error(f(-1), "modulus")

## ── Integer scaling factor: exact above 53 bits ─────────────────
cc <- fhe_context("BGV", plaintext_modulus = 65537, multiplicative_depth = 1)
kp <- key_gen(cc)
pt <- make_packed_plaintext(cc, 1:4)
ct <- encrypt(kp@public, pt, cc = cc)

sf <- get_scaling_factor_int(ct)
expect_true(is.character(sf) && length(sf) == 1L)
expect_true(grepl("^[0-9]+$", sf))
expect_true(is.character(get_scaling_factor_int(pt)))

## 2^60 + 1 is not a double: the low bit must survive the round trip.
v <- "1152921504606846977"
set_scaling_factor_int(ct, v)
expect_identical(get_scaling_factor_int(ct), v)
set_scaling_factor_int(pt, v)
expect_identical(get_scaling_factor_int(pt), v)

## The largest 64-bit value is accepted; one more is refused, as is
## anything that is not a non-negative whole number.
u64max <- "18446744073709551615"
set_scaling_factor_int(ct, u64max)
expect_identical(get_scaling_factor_int(ct), u64max)
expect_error(set_scaling_factor_int(ct, "18446744073709551616"), "too large")
expect_error(set_scaling_factor_int(ct, -1), "non-negative whole number")
expect_error(set_scaling_factor_int(ct, 2^60), "above 2\\^53")

## Numbers are still accepted where they are exact.
set_scaling_factor_int(ct, 7)
expect_identical(get_scaling_factor_int(ct), "7")
set_scaling_factor_int(pt, 7L)
expect_identical(get_scaling_factor_int(pt), "7")

## ── Plaintext modulus: a number up to 2^53, a string above ──────
p_small <- BFVParams(plaintext_modulus = 65537)
expect_identical(get_plaintext_modulus(p_small), 65537)

## Above 2^31: as.integer() used to turn this into NA.
p_mid <- BFVParams(plaintext_modulus = 4294967297)
expect_identical(get_plaintext_modulus(p_mid), 4294967297)
p_str <- BGVParams(plaintext_modulus = "4294967297")
expect_identical(get_plaintext_modulus(p_str), 4294967297)

## Above 2^53 the getter returns the digits.
p_wide <- BFVParams(plaintext_modulus = "1152921504606846977")
expect_identical(get_plaintext_modulus(p_wide), "1152921504606846977")
expect_error(BFVParams(plaintext_modulus = "18446744073709551616"), "too large")
expect_error(BFVParams(plaintext_modulus = 65537.5), "non-negative whole number")
expect_error(BGVParams(plaintext_modulus = -3), "non-negative whole number")

## The context reports the same value the parameters carried.
expect_identical(get_plaintext_modulus(cc), 65537)
