## OPENFHE PYTHON SOURCE: NONE (no Python binding for these)
##
## openfhe-python v1.5.1.0 does not bind ShareKeys or
## RecoverSharedKey.
##
## SecretShareMap S7 class +
## share_keys() / recover_shared_key() wrappers for the abort-
## recovery flow documented in OpenFHE's
## `UnitTestMultipartyAborts`. The wire format matches the
## EvalKeyMap pattern — an external_pointer holding a heap-
## allocated shared_ptr, here to an
## unordered_map<uint32_t, DCRTPoly>.

#' Map of secret-key shares for threshold-FHE abort recovery
#'
#' Opaque S7 wrapper around a
#' `shared_ptr<std::unordered_map<uint32_t, DCRTPoly>>`. Produced
#' by [share_keys()] — each call returns one party's contribution
#' to the distributed shares of their own secret key. Consumed
#' by [recover_shared_key()], which reconstructs the original
#' secret from `threshold` or more shares when a party drops out.
#'
#' The map is keyed by party index (1-based uint32). Users do
#' not index into it directly; it is a transport format for the
#' secret-sharing protocol.
#'
#' @param ptr External pointer (internal use).
#' @export
SecretShareMap <- new_class("SecretShareMap",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, SecretShareMap) <- function(x, ...) {
  cli::cli_text("{.cls SecretShareMap} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

#' Distribute a secret key into shares
#'
#' Produces the set of shares that party `index` would
#' distribute to the other parties under the chosen
#' `sharing_scheme`. The returned `SecretShareMap` is opaque;
#' in a real deployment the shares would be serialized and
#' routed over the network to each receiving party, and the
#' receiving parties would store them for use in an abort
#' recovery.
#'
#' Two sharing schemes are supported:
#'
#' - `"additive"` — N-1 threshold; every party must contribute
#'   their share to reconstruct. Robust against corruption of
#'   any single party's storage but not against any party
#'   dropping out.
#' - `"shamir"` — `floor(N/2) + 1` threshold; the secret can be
#'   reconstructed from any majority subset of the distributed
#'   shares. Robust against up to `floor((N-1)/2)` parties
#'   dropping out.
#'
#' @param cc A `CryptoContext` with the `MULTIPARTY` feature.
#' @param sk The `PrivateKey` to share.
#' @param n_parties Integer; total number of parties.
#' @param threshold Integer; minimum number of shares needed to
#'   reconstruct. For `"additive"` this must be `n_parties - 1`;
#'   for `"shamir"` it is typically `floor(n_parties/2) + 1`.
#' @param index Integer; the 1-based index of the party owning
#'   `sk` (the "my share index").
#' @param sharing_scheme Character; either `"additive"` (default)
#'   or `"shamir"`.
#' @return A `SecretShareMap` suitable for passing to
#'   [recover_shared_key()].
#' @seealso [recover_shared_key()]
#' @export
share_keys <- function(cc, sk, n_parties, threshold, index,
                       sharing_scheme = "additive") {
  SecretShareMap(ptr = CryptoContext__ShareKeys(
    get_ptr(cc), get_ptr(sk),
    as.integer(n_parties),
    as.integer(threshold),
    as.integer(index),
    as.character(sharing_scheme)))
}

#' Recover a secret key from distributed shares
#'
#' Inverse of [share_keys()]. Given a `SecretShareMap` holding
#' at least `threshold` shares, reconstructs a `PrivateKey`
#' equivalent to the original secret at the point of sharing.
#' The reconstructed key participates in distributed decryption
#' identically to the original, so a dropped-out party's share
#' of a threshold decryption can still be completed by the
#' remaining parties.
#'
#' Under the hood, the C++ API takes a mutable `PrivateKey`
#' reference that must be pre-allocated as an empty
#' `PrivateKeyImpl` bound to `cc`. The R wrapper constructs that
#' empty placeholder internally so R users do not have to know
#' about the in-place-fill convention.
#'
#' @param cc A `CryptoContext`. Used to construct the empty
#'   placeholder key that the scheme routine fills in.
#' @param share_map A `SecretShareMap` from [share_keys()].
#' @param n_parties Integer; must match the value used at
#'   [share_keys()] time.
#' @param threshold Integer; must match the value used at
#'   [share_keys()] time.
#' @param sharing_scheme Character; must match the value used at
#'   [share_keys()] time.
#' @return A `PrivateKey` holding the reconstructed secret.
#' @seealso [share_keys()]
#' @export
recover_shared_key <- function(cc, share_map, n_parties, threshold,
                               sharing_scheme = "additive") {
  PrivateKey(ptr = CryptoContext__RecoverSharedKey(
    get_ptr(cc), get_ptr(share_map),
    as.integer(n_parties),
    as.integer(threshold),
    as.character(sharing_scheme)))
}
