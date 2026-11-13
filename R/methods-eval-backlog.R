## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (evaluation methods bound at OpenFHE 1.6.1)
##
## R wrappers for src/pke_eval_backlog.cpp: operations on vectors of
## ciphertexts, inner products and row/column sums, EvalAtIndex, proxy
## re-encryption, string plaintexts, and the remaining in-place and
## unchecked forms.

## A list of Ciphertext objects as a list of external pointers.
.ct_ptrs <- function(ciphertexts, arg = "ciphertexts",
                     call = rlang::caller_env()) {
  ok <- is.list(ciphertexts) && length(ciphertexts) > 0L &&
    all(vapply(ciphertexts, function(ct) S7::S7_inherits(ct, Ciphertext),
               logical(1)))
  if (!ok) {
    cli_abort("{.arg {arg}} must be a non-empty list of {.cls Ciphertext} objects.",
              call = call)
  }
  lapply(ciphertexts, get_ptr)
}

## Constants of a weighted sum: one per ciphertext, integer, double or
## complex, passed through with their own type.
.wsum_constants <- function(constants, n, call = rlang::caller_env()) {
  ok <- (is.numeric(constants) || is.complex(constants)) &&
    !is.object(constants) && !anyNA(constants)
  if (!ok) {
    cli_abort("{.arg constants} must be an integer, double or complex vector with no missing values.",
              call = call)
  }
  if (length(constants) != n) {
    cli_abort("{.arg constants} has {length(constants)} element{?s}; there {?is/are} {n} ciphertext{?s}.",
              call = call)
  }
  constants
}

# ── Vectors of ciphertexts ──────────────────────────────

#' Add or multiply a list of ciphertexts
#'
#' `eval_add_many()` returns the sum of a list of ciphertexts and
#' `eval_mult_many()` their product, each computed as a binary tree,
#' which keeps the multiplicative depth of the product at
#' `ceiling(log2(n))`. `eval_mult_many()` relinearizes after every
#' multiplication and needs the relinearization key.
#'
#' `eval_add_many_in_place()` computes the same sum but uses the given
#' ciphertexts for its intermediate results: after the call they hold
#' partial sums, and the first one holds the total.
#'
#' @param ciphertexts A non-empty list of `Ciphertext` objects.
#' @return A `Ciphertext`.
#' @examples
#' cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2,
#'                   features = Feature$ADVANCEDSHE)
#' kp <- key_gen(cc, eval_mult = TRUE)
#' cts <- lapply(1:4, function(i)
#'   encrypt(kp@public, make_packed_plaintext(cc, c(i, 2L * i)), cc = cc))
#' total <- decrypt(eval_add_many(cts), kp@secret, cc = cc)
#' get_packed_value(set_length(total, 2L))
#' @export
eval_add_many <- function(ciphertexts) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalAddMany__(.ct_ptrs(ciphertexts)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalAddMany__(.ct_ptrs(ciphertexts)))
}

#' @rdname eval_add_many
#' @export
eval_add_many_in_place <- function(ciphertexts) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalAddManyInPlace__(.ct_ptrs(ciphertexts)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalAddManyInPlace__(.ct_ptrs(ciphertexts)))
}

#' @rdname eval_add_many
#' @export
eval_mult_many <- function(ciphertexts) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalMultMany__(.ct_ptrs(ciphertexts)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalMultMany__(.ct_ptrs(ciphertexts)))
}

#' Merge the first slots of several ciphertexts into one
#'
#' Returns a ciphertext whose slot `i` holds the first slot of the
#' `i`-th input. The other slots of each input must be zero. Needs
#' the rotation keys for indices `-1, ..., -(n - 1)`, where `n` is
#' the number of ciphertexts (see [eval_at_index_key_gen()]).
#'
#' @param ciphertexts A non-empty list of `Ciphertext` objects.
#' @return A `Ciphertext`.
#' @export
eval_merge <- function(ciphertexts) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalMerge__(.ct_ptrs(ciphertexts)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalMerge__(.ct_ptrs(ciphertexts)))
}

#' Weighted sum of ciphertexts (CKKS)
#'
#' Computes `constants[1] * ciphertexts[[1]] + ... +
#' constants[n] * ciphertexts[[n]]`.
#'
#' `eval_linear_wsum_mutable()` may adjust the given ciphertexts (their
#' level and scale) while it works, which saves copies. It takes the
#' constants first, as the C++ function of that name does.
#'
#' @param ciphertexts A non-empty list of `Ciphertext` objects.
#' @param constants One constant per ciphertext: an integer, double or
#'   complex vector. Each type is evaluated with its own arithmetic.
#' @return A `Ciphertext`.
#' @export
eval_linear_wsum <- function(ciphertexts, constants) {
  ptrs <- .ct_ptrs(ciphertexts)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalLinearWSum__(ptrs, .wsum_constants(constants, length(ptrs))))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalLinearWSum__(ptrs, .wsum_constants(constants, length(ptrs))))
}

#' @rdname eval_linear_wsum
#' @export
eval_linear_wsum_mutable <- function(constants, ciphertexts) {
  ptrs <- .ct_ptrs(ciphertexts)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalLinearWSumMutable__(
  ##   .wsum_constants(constants, length(ptrs)), ptrs))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalLinearWSumMutable__(
    .wsum_constants(constants, length(ptrs)), ptrs))
}

# ── Sums and inner products ─────────────────────────────

#' Inner product of two encrypted vectors
#'
#' Multiplies the two operands slot by slot and sums the first
#' `batch_size` slots; the result is in the first slot. Needs the
#' relinearization key and the summation keys
#' ([eval_sum_key_gen()]).
#'
#' @param ct1 A `Ciphertext`.
#' @param ct2 A `Ciphertext` or a `Plaintext`.
#' @param batch_size Integer; the number of slots to sum.
#' @return A `Ciphertext`.
#' @export
eval_inner_product <- function(ct1, ct2, batch_size) {
  if (S7::S7_inherits(ct2, Ciphertext)) {
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## Ciphertext(ptr = EvalInnerProduct__ct_ct(get_ptr(ct1), get_ptr(ct2),
    ##                                          as.integer(batch_size)))
    ## <<< S7-FAST-NEW
    .fast_new(Ciphertext, EvalInnerProduct__ct_ct(get_ptr(ct1), get_ptr(ct2),
                                                  as.integer(batch_size)))
  } else if (S7::S7_inherits(ct2, Plaintext)) {
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## Ciphertext(ptr = EvalInnerProduct__ct_pt(get_ptr(ct1), get_ptr(ct2),
    ##                                          as.integer(batch_size)))
    ## <<< S7-FAST-NEW
    .fast_new(Ciphertext, EvalInnerProduct__ct_pt(get_ptr(ct1), get_ptr(ct2),
                                                  as.integer(batch_size)))
  } else {
    cli_abort("{.arg ct2} must be a {.cls Ciphertext} or a {.cls Plaintext}.")
  }
}

#' Sum the rows or the columns of an encrypted matrix
#'
#' A matrix is packed into the slots row by row. `eval_sum_rows()`
#' adds its rows together and `eval_sum_cols()` its columns. Each
#' takes the keys made by the matching key generator, which returns
#' them as an `EvalKeyMap`.
#'
#' @param ct A `Ciphertext` holding the matrix.
#' @param num_rows,num_cols Integer; the number of rows, or columns,
#'   of the matrix.
#' @param eval_sum_key_map An `EvalKeyMap` from
#'   `eval_sum_rows_key_gen()` or `eval_sum_cols_key_gen()`.
#' @param subring_dim Integer; the subring dimension, `0L` (default)
#'   for the full ring.
#' @param cc A `CryptoContext`.
#' @param sk A `PrivateKey`.
#' @param public_key A `PublicKey`, or `NULL` (default) for the form
#'   that takes no public key.
#' @param row_size Integer; the length of a row, `0L` (default) for
#'   the value the library derives.
#' @return `eval_sum_rows()` and `eval_sum_cols()` return a
#'   `Ciphertext`; the key generators return an `EvalKeyMap`.
#' @export
eval_sum_rows <- function(ct, num_rows, eval_sum_key_map, subring_dim = 0L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalSumRows__(get_ptr(ct), as.integer(num_rows),
  ##                                get_ptr(eval_sum_key_map),
  ##                                as.integer(subring_dim)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalSumRows__(get_ptr(ct), as.integer(num_rows),
                                      get_ptr(eval_sum_key_map),
                                      as.integer(subring_dim)))
}

#' @rdname eval_sum_rows
#' @export
eval_sum_cols <- function(ct, num_cols, eval_sum_key_map) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalSumCols__(get_ptr(ct), as.integer(num_cols),
  ##                                get_ptr(eval_sum_key_map)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalSumCols__(get_ptr(ct), as.integer(num_cols),
                                      get_ptr(eval_sum_key_map)))
}

#' @rdname eval_sum_rows
#' @export
eval_sum_rows_key_gen <- function(cc, sk, public_key = NULL, row_size = 0L,
                                  subring_dim = 0L) {
  pk_xp <- if (is.null(public_key)) NULL else get_ptr(public_key)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## EvalKeyMap(ptr = EvalSumRowsKeyGen__(get_ptr(cc), get_ptr(sk), pk_xp,
  ##                                      as.integer(row_size),
  ##                                      as.integer(subring_dim)))
  ## <<< S7-FAST-NEW
  .fast_new(EvalKeyMap, EvalSumRowsKeyGen__(get_ptr(cc), get_ptr(sk), pk_xp,
                                            as.integer(row_size),
                                            as.integer(subring_dim)))
}

#' @rdname eval_sum_rows
#' @export
eval_sum_cols_key_gen <- function(cc, sk) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## EvalKeyMap(ptr = EvalSumColsKeyGen__(get_ptr(cc), get_ptr(sk)))
  ## <<< S7-FAST-NEW
  .fast_new(EvalKeyMap, EvalSumColsKeyGen__(get_ptr(cc), get_ptr(sk)))
}

# ── Rotation ────────────────────────────────────────────

#' Rotate the slots of a ciphertext by an index
#'
#' `eval_at_index(ct, i)` moves slot `i + k` to slot `k`: a positive
#' index rotates to the left, a negative one to the right. Needs the
#' key for that index ([eval_at_index_key_gen()]). [eval_rotate()]
#' calls the C++ function `EvalRotate`, which does the same thing.
#'
#' @param ct A `Ciphertext`.
#' @param index Integer; the rotation index.
#' @return A `Ciphertext`.
#' @export
eval_at_index <- function(ct, index) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalAtIndex__(get_ptr(ct), as.integer(index)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalAtIndex__(get_ptr(ct), as.integer(index)))
}

# ── Proxy re-encryption ─────────────────────────────────

#' Proxy re-encryption
#'
#' `re_key_gen()` makes a re-encryption key from one party's secret
#' key and another party's public key. With it, `re_encrypt()` turns a
#' ciphertext under the first party's key into one the second party
#' can decrypt, without decrypting it. The context needs
#' `Feature$PRE`.
#'
#' @param cc A `CryptoContext`.
#' @param old_private_key The `PrivateKey` the ciphertexts are
#'   currently encrypted under.
#' @param new_public_key The `PublicKey` of the party who is to
#'   decrypt.
#' @param ct A `Ciphertext`.
#' @param eval_key The `EvalKey` from `re_key_gen()`.
#' @param public_key The `PublicKey` of the party the ciphertext is
#'   currently encrypted for, or `NULL` (default). It is used to
#'   re-randomize the result in the security modes that require it.
#' @return `re_key_gen()` returns an `EvalKey`; `re_encrypt()` a
#'   `Ciphertext`.
#' @export
re_key_gen <- function(cc, old_private_key, new_public_key) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## EvalKey(ptr = ReKeyGen__(get_ptr(cc), get_ptr(old_private_key),
  ##                          get_ptr(new_public_key)))
  ## <<< S7-FAST-NEW
  .fast_new(EvalKey, ReKeyGen__(get_ptr(cc), get_ptr(old_private_key),
                                get_ptr(new_public_key)))
}

#' @rdname re_key_gen
#' @export
re_encrypt <- function(ct, eval_key, public_key = NULL) {
  pk_xp <- if (is.null(public_key)) NULL else get_ptr(public_key)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = ReEncrypt__(get_ptr(ct), get_ptr(eval_key), pk_xp))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, ReEncrypt__(get_ptr(ct), get_ptr(eval_key), pk_xp))
}

# ── Plaintext ───────────────────────────────────────────

#' Encode a character string as a plaintext
#'
#' Each character becomes one coefficient, so the plaintext modulus
#' must be large enough for the character codes; the OpenFHE examples
#' use 256. Read the string back with [get_string_value()].
#'
#' @param cc A `CryptoContext` (BFV or BGV).
#' @param str A single character string.
#' @return A `Plaintext`.
#' @export
make_string_plaintext <- function(cc, str) {
  if (!is.character(str) || length(str) != 1L || is.na(str)) {
    cli_abort("{.arg str} must be a single character string.")
  }
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Plaintext(ptr = MakeStringPlaintext__(get_ptr(cc), str))
  ## <<< S7-FAST-NEW
  .fast_new(Plaintext, MakeStringPlaintext__(get_ptr(cc), str))
}

# ── In place ────────────────────────────────────────────

#' Square, rescale or relinearize a ciphertext in place
#'
#' The in-place forms of [eval_square()], [rescale()] and
#' [relinearize()]: the result replaces the contents of the
#' ciphertext.
#'
#' @param ct A `Ciphertext` (modified in place).
#' @return `ct`, invisibly.
#' @export
eval_square_in_place <- function(ct) {
  EvalUnaryInPlace__(get_ptr(ct), 0L)
  invisible(ct)
}

#' @rdname eval_square_in_place
#' @export
rescale_in_place <- function(ct) {
  EvalUnaryInPlace__(get_ptr(ct), 1L)
  invisible(ct)
}

#' @rdname eval_square_in_place
#' @export
relinearize_in_place <- function(ct) {
  EvalUnaryInPlace__(get_ptr(ct), 2L)
  invisible(ct)
}

#' Mutable arithmetic on two ciphertexts, in place
#'
#' The result of `ct1 + ct2`, `ct1 - ct2` or `ct1 * ct2` replaces the
#' contents of `ct1`. As in the other mutable forms
#' ([eval_add_mutable()]), the library may also adjust `ct2`.
#'
#' @param ct1 A `Ciphertext`; receives the result.
#' @param ct2 A `Ciphertext`; may be modified.
#' @return `ct1`, invisibly.
#' @export
eval_add_mutable_in_place <- function(ct1, ct2) {
  EvalMutableInPlace__(.ARITH_ADD, get_ptr(ct1), get_ptr(ct2))
  invisible(ct1)
}

#' @rdname eval_add_mutable_in_place
#' @export
eval_sub_mutable_in_place <- function(ct1, ct2) {
  EvalMutableInPlace__(.ARITH_SUB, get_ptr(ct1), get_ptr(ct2))
  invisible(ct1)
}

#' @rdname eval_add_mutable_in_place
#' @export
eval_mult_mutable_in_place <- function(ct1, ct2) {
  EvalMutableInPlace__(.ARITH_MULT, get_ptr(ct1), get_ptr(ct2))
  invisible(ct1)
}

# ── Unchecked forms ─────────────────────────────────────

#' Arithmetic without the library's operand checks
#'
#' These call the C++ functions of the same names, which skip the
#' checks OpenFHE normally makes on its operands (same context, same
#' key, compatible levels) and do not adjust levels or scales. They
#' are for code that has already established those conditions; with
#' operands that do not meet them the result is not meaningful. Use
#' [eval_add_in_place()], [eval_mult()] and [eval_mult_no_relin()]
#' otherwise.
#'
#' `eval_add_in_place_no_check()` adds `ct2` into `ct1`.
#' `eval_mult_no_check()` multiplies every element of a ciphertext by
#' an integer scalar. `eval_mult_no_relin_no_check()` returns the
#' tensor product of the elements of two ciphertexts, without
#' relinearizing. That is their product in CKKS for two ciphertexts
#' at the same level and scale. It is not the BFV product, which
#' includes a scaling step this function does not perform.
#'
#' @param ct1,ct A `Ciphertext`.
#' @param ct2 A `Ciphertext`.
#' @param scalar A whole number of at most 2^53, or a string of
#'   decimal digits for a larger value.
#' @return `eval_add_in_place_no_check()` returns `ct1`, invisibly;
#'   the other two return a new `Ciphertext`.
#' @export
eval_add_in_place_no_check <- function(ct1, ct2) {
  EvalAddInPlaceNoCheck__(get_ptr(ct1), get_ptr(ct2))
  invisible(ct1)
}

#' @rdname eval_add_in_place_no_check
#' @export
eval_mult_no_check <- function(ct, scalar) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalMultNoCheck__(get_ptr(ct), wide_integer(scalar)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalMultNoCheck__(get_ptr(ct), wide_integer(scalar)))
}

#' @rdname eval_add_in_place_no_check
#' @export
eval_mult_no_relin_no_check <- function(ct1, ct2) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalMultNoRelinNoCheck__(get_ptr(ct1), get_ptr(ct2)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalMultNoRelinNoCheck__(get_ptr(ct1), get_ptr(ct2)))
}

# ── Other ───────────────────────────────────────────────

#' Multiply two ciphertexts and reduce the modulus
#'
#' Multiplies, relinearizes, and then reduces the modulus of the
#' product by one level, in one call. Needs the relinearization key.
#'
#' @param ct1,ct2 `Ciphertext` objects.
#' @return A `Ciphertext`.
#' @export
composed_eval_mult <- function(ct1, ct2) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = ComposedEvalMult__(get_ptr(ct1), get_ptr(ct2)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, ComposedEvalMult__(get_ptr(ct1), get_ptr(ct2)))
}

#' Generate relinearization keys for higher powers of the secret key
#'
#' Generates the keys that relinearize a ciphertext of more than
#' three elements, as [eval_mult_no_relin()] produces when it is
#' applied repeatedly: one key for each power of the secret key up to
#' the `max_relin_sk_deg` of the context. [eval_mult_key_gen()]
#' generates the key for the second power only.
#'
#' @param cc A `CryptoContext`.
#' @param sk A `PrivateKey`.
#' @return `NULL`, invisibly.
#' @export
eval_mult_keys_gen <- function(cc, sk) {
  EvalMultKeysGen__(get_ptr(cc), get_ptr(sk))
  invisible(NULL)
}
