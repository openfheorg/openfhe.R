## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (IntBoot* and IntMPBoot* families)
##
## Three method groups:
## KeySwitchDown,
## the IntBoot* single-party interactive bootstrap family, and
## the IntMPBoot* multi-party interactive bootstrap family.

#' Scale a ciphertext down from extended CRT basis to Q
#'
#' Brings a ciphertext that lives in the extended P*Q basis
#' (for example, the output of [eval_fast_rotation_ext()] with
#' hybrid key switching) back to the standard Q basis. Only
#' supported when the scheme is configured with hybrid key
#' switching — other key-switching techniques have no
#' round-trip to extended P*Q and therefore nothing to scale
#' back from.
#'
#' @param ct A `Ciphertext` in the extended P*Q basis.
#' @return A `Ciphertext` in the Q basis.
#' @seealso [eval_fast_rotation_ext()]
#' @export
key_switch_down <- function(ct) {
  Ciphertext(ptr = KeySwitchDown__(get_ptr(ct)))
}

# ── IntBoot* single-party interactive bootstrap ─────────

#' Server-side masked decryption for interactive bootstrap
#'
#' First step of the single-party interactive bootstrap
#' protocol. The server applies its secret key share to produce
#' a "masked" partial decryption that the client can finish
#' off-line. Pairs with [int_boot_encrypt()] /
#' [int_boot_add()] / [int_boot_adjust_scale()] to complete the
#' refresh.
#'
#' @param sk A `PrivateKey` (server's share).
#' @param ct A `Ciphertext` to refresh.
#' @return A `Ciphertext` holding the masked decryption.
#' @seealso [int_boot_encrypt()], [int_boot_add()],
#'   [int_boot_adjust_scale()]
#' @export
int_boot_decrypt <- function(sk, ct) {
  Ciphertext(ptr = IntBootDecrypt__(get_ptr(sk), get_ptr(ct)))
}

#' Client-side re-encryption for interactive bootstrap
#'
#' Encrypts the client's masked decryption result under the
#' public key, raising the ciphertext modulus back to a fresh
#' level.
#'
#' @param pk A `PublicKey`.
#' @param ct A `Ciphertext` from the client (typically the
#'   masked-decryption output processed off-line).
#' @return A refreshed `Ciphertext`.
#' @seealso [int_boot_decrypt()]
#' @export
int_boot_encrypt <- function(pk, ct) {
  Ciphertext(ptr = IntBootEncrypt__(get_ptr(pk), get_ptr(ct)))
}

#' Combine encrypted and unencrypted masked decryptions
#'
#' Final step of the two-party interactive bootstrap protocol.
#' Adds the server's masked decryption to the client's
#' re-encryption to produce the refreshed ciphertext.
#'
#' @param ct1,ct2 `Ciphertext` objects — typically the outputs
#'   of [int_boot_decrypt()] and [int_boot_encrypt()].
#' @return A refreshed `Ciphertext`.
#' @export
int_boot_add <- function(ct1, ct2) {
  Ciphertext(ptr = IntBootAdd__(get_ptr(ct1), get_ptr(ct2)))
}

#' Prepare a ciphertext for interactive bootstrap
#'
#' Adjusts a ciphertext's scale to meet the scheme's
#' requirements before entering the interactive bootstrap
#' protocol. Typically called before [int_boot_decrypt()].
#'
#' @param ct A `Ciphertext`.
#' @return A `Ciphertext` ready for [int_boot_decrypt()].
#' @export
int_boot_adjust_scale <- function(ct) {
  Ciphertext(ptr = IntBootAdjustScale__(get_ptr(ct)))
}

# ── IntMPBoot* multi-party interactive bootstrap ────────

#' Prepare a ciphertext for multi-party interactive bootstrap
#'
#' Multi-party analogue of [int_boot_adjust_scale()]. Adjusts
#' the ciphertext's scale before entering the distributed
#' bootstrap protocol.
#'
#' @param ct A `Ciphertext`.
#' @return A `Ciphertext` ready for the multi-party bootstrap
#'   protocol.
#' @export
int_mp_boot_adjust_scale <- function(ct) {
  Ciphertext(ptr = IntMPBootAdjustScale__(get_ptr(ct)))
}

#' Generate a common random element for multi-party bootstrap
#'
#' Generates a common random polynomial used by all parties in
#' a multi-party interactive bootstrap round. Two overloads:
#'
#' - When `source` is a `PublicKey` (the lead party's public
#'   key), routes to the `(publicKey)` C++ overload.
#' - When `source` is a `Ciphertext`, routes to the
#'   `(ciphertext)` overload which derives the cc and
#'   parameters from the ciphertext directly — convenient when
#'   a ciphertext is already in scope.
#'
#' @param cc A `CryptoContext`. Only used by the `PublicKey`
#'   overload; the `Ciphertext` overload ignores it and uses
#'   the source's internal cc.
#' @param source Either a `PublicKey` or a `Ciphertext`.
#' @return A `Ciphertext` holding the common random element.
#' @export
int_mp_boot_random_element_gen <- function(cc, source) {
  if (S7::S7_inherits(source, PublicKey)) {
    Ciphertext(ptr = IntMPBootRandomElementGen__pk(get_ptr(cc),
                                                   get_ptr(source)))
  } else if (S7::S7_inherits(source, Ciphertext)) {
    Ciphertext(ptr = IntMPBootRandomElementGen__ct(get_ptr(source)))
  } else {
    cli::cli_abort(
      "{.arg source} must be a {.cls PublicKey} or {.cls Ciphertext}.")
  }
}

#' Multi-party masked decryption for interactive bootstrap
#'
#' Each party calls this with their own secret share, the
#' ciphertext being refreshed, and the common random element
#' from [int_mp_boot_random_element_gen()]. Returns a list of
#' two `Ciphertext` objects — the party's masked-decryption
#' "shares pair". Each party's shares pair gets collected and
#' fed into [int_mp_boot_add()].
#'
#' @param sk A `PrivateKey` (this party's share).
#' @param ct A `Ciphertext` to refresh.
#' @param a A `Ciphertext` holding the common random element
#'   from [int_mp_boot_random_element_gen()].
#' @return A list of two `Ciphertext` objects (the party's
#'   shares pair).
#' @export
int_mp_boot_decrypt <- function(sk, ct, a) {
  result_ptrs <- IntMPBootDecrypt__(get_ptr(sk), get_ptr(ct), get_ptr(a))
  lapply(result_ptrs, function(p) Ciphertext(ptr = p))
}

#' Aggregate multi-party shares pairs
#'
#' Combines the shares-pair lists produced by each party's
#' call to [int_mp_boot_decrypt()] into a single aggregated
#' shares pair for use in [int_mp_boot_encrypt()]. The input
#' is a list of per-party shares-pair lists (a list of lists
#' of `Ciphertext`).
#'
#' @param cc A `CryptoContext`.
#' @param shares_pair_list A list where each element is a
#'   list of `Ciphertext` objects from one party's
#'   [int_mp_boot_decrypt()] call.
#' @return A list of `Ciphertext` objects — the aggregated
#'   shares pair.
#' @export
int_mp_boot_add <- function(cc, shares_pair_list) {
  if (!is.list(shares_pair_list)) {
    cli::cli_abort("{.arg shares_pair_list} must be a list of lists of Ciphertexts.")
  }
  ## Marshal each inner list of S7 Ciphertext wrappers to a
  ## list of raw external_pointers (what cpp11 expects).
  inner_ptrs <- lapply(shares_pair_list, function(inner) {
    if (!is.list(inner)) {
      cli::cli_abort("Each element of {.arg shares_pair_list} must be a list of Ciphertexts.")
    }
    lapply(inner, get_ptr)
  })
  result_ptrs <- IntMPBootAdd__(get_ptr(cc), inner_ptrs)
  lapply(result_ptrs, function(p) Ciphertext(ptr = p))
}

#' Final re-encryption for multi-party interactive bootstrap
#'
#' Lead party's final step in the multi-party interactive
#' bootstrap. Takes the aggregated shares pair from
#' [int_mp_boot_add()] plus the common random element and the
#' original ciphertext, produces the refreshed ciphertext at a
#' fresh modulus level.
#'
#' @param pk The lead party's `PublicKey`.
#' @param shares_pair A list of `Ciphertext` objects — the
#'   aggregated shares pair from [int_mp_boot_add()].
#' @param a The common random element `Ciphertext` used in the
#'   per-party [int_mp_boot_decrypt()] calls.
#' @param ct The original `Ciphertext` being refreshed.
#' @return A refreshed `Ciphertext`.
#' @export
int_mp_boot_encrypt <- function(pk, shares_pair, a, ct) {
  if (!is.list(shares_pair)) {
    cli::cli_abort("{.arg shares_pair} must be a list of Ciphertexts.")
  }
  shares_ptrs <- lapply(shares_pair, get_ptr)
  Ciphertext(ptr = IntMPBootEncrypt__(get_ptr(pk), shares_ptrs,
                                      get_ptr(a), get_ptr(ct)))
}
