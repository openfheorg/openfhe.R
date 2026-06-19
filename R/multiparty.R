## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Multiparty/Threshold FHE)
##
## argument-completion pass on the
## existing multiparty surface. multiparty_key_gen gains the
## `make_sparse` and `fresh` bools per cryptocontext.h line 3102.
## multi_add_pub_keys / multi_add_eval_keys / multi_add_eval_mult_keys
## gain the `key_tag` tail argument per cryptocontext.h lines
## 3314 / 3244 / 3331. New multi_key_switch_gen wrapper exposes
## the existing cpp11 binding to R.

#' Generate a key pair for a secondary party in threshold FHE
#'
#' The lead party uses [key_gen()] to generate the initial keypair.
#' Subsequent parties call this with the lead's public key.
#'
#' @param cc A CryptoContext (must have MULTIPARTY feature enabled)
#' @param lead_pk The lead party's PublicKey
#' @param make_sparse Logical; if `TRUE`, produce an LWE-sparse
#'   secret. Default `FALSE` to match the C++ header default.
#'   RLWE-only semantics; BFV/BGV/CKKS accept both values.
#' @param fresh Logical; if `TRUE`, sample a fresh secret rather
#'   than deriving one from the existing key material. Default
#'   `FALSE`.
#' @return A KeyPair for this party
#' @export
multiparty_key_gen <- function(cc, lead_pk,
                               make_sparse = FALSE, fresh = FALSE) {
  kp_list <- MultipartyKeyGen(get_ptr(cc), get_ptr(lead_pk),
                              as.logical(make_sparse),
                              as.logical(fresh))
  KeyPair(
    public = PublicKey(ptr = kp_list$public),
    secret = PrivateKey(ptr = kp_list$secret)
  )
}

#' Combine public keys from multiple parties
#'
#' @param cc A CryptoContext
#' @param pk1,pk2 PublicKey objects to combine
#' @param key_tag Character; optional tag to associate with the
#'   combined key. Default `""` (empty tag) to match the C++
#'   header default. Round-trips through [get_key_tag()].
#' @return A combined PublicKey
#' @export
multi_add_pub_keys <- function(cc, pk1, pk2, key_tag = "") {
  PublicKey(ptr = MultiAddPubKeys(get_ptr(cc), get_ptr(pk1), get_ptr(pk2),
                                  as.character(key_tag)))
}

#' Combine evaluation keys from multiple parties
#'
#' Combines two partial key-switching eval keys into a joint
#' eval key. See [multi_add_eval_mult_keys()] for the eval-mult
#' variant — the two functions consume keys produced by different
#' generators and are not interchangeable.
#'
#' @param cc A CryptoContext
#' @param ek1,ek2 EvalKey objects to combine
#' @param key_tag Character; optional tag to associate with the
#'   combined key. Default `""`.
#' @return A combined EvalKey
#' @export
multi_add_eval_keys <- function(cc, ek1, ek2, key_tag = "") {
  EvalKey(ptr = MultiAddEvalKeys(get_ptr(cc), get_ptr(ek1), get_ptr(ek2),
                                 as.character(key_tag)))
}

#' Combine partial eval-mult keys from multiple parties
#'
#' The eval-mult flavor of [multi_add_eval_keys()]. Consumes
#' keys produced by a multi-party eval-mult key generator rather
#' than by [multi_key_switch_gen()]. Where the R generator is
#' not yet exposed, the wrapper still lets downstream code
#' exercise the add-keys flow against keys constructed through
#' the underlying cpp11 binding.
#'
#' @param cc A CryptoContext
#' @param ek1,ek2 EvalKey objects (eval-mult partials) to combine
#' @param key_tag Character; optional tag to associate with the
#'   combined key. Default `""`.
#' @return A combined EvalKey
#' @export
multi_add_eval_mult_keys <- function(cc, ek1, ek2, key_tag = "") {
  EvalKey(ptr = MultiAddEvalMultKeys(get_ptr(cc),
                                     get_ptr(ek1), get_ptr(ek2),
                                     as.character(key_tag)))
}

#' Multi-party key-switch eval-key generation
#'
#' Generates an eval key that switches ciphertexts encrypted
#' under `sk_orig` into a form decryptable by `sk_new`, starting
#' from an existing eval key that carries the key-switch
#' auxiliary information. Used by threshold protocols to route
#' partial decryptions across a re-keyed party set.
#'
#' @param cc A CryptoContext
#' @param sk_orig The original party's PrivateKey
#' @param sk_new The new party's PrivateKey
#' @param eval_key An EvalKey carrying key-switch auxiliary data
#' @return An EvalKey suitable for routing through
#'   [multi_add_eval_keys()] to combine with other parties'
#'   key-switch shares
#' @export
multi_key_switch_gen <- function(cc, sk_orig, sk_new, eval_key) {
  EvalKey(ptr = MultiKeySwitchGen(get_ptr(cc),
                                  get_ptr(sk_orig),
                                  get_ptr(sk_new),
                                  get_ptr(eval_key)))
}

#' Lead party's partial decryption
#'
#' In threshold decryption, the lead party calls this first.
#' Accepts either a single `Ciphertext` or a list of
#' `Ciphertext` objects:
#'
#' - single `Ciphertext`: returns a single partially decrypted
#'   `Ciphertext`, matching the original single-ciphertext signature.
#' - list of `Ciphertext`: returns a list of partially decrypted
#'   `Ciphertext` objects of the same length, routed through the
#'   C++ `MultipartyDecryptLead(vector<Ciphertext>, PrivateKey)`
#'   overload (cryptocontext.h line 3115). Useful when a protocol
#'   round needs to partially decrypt a batch in one trip.
#'
#' @param cc A CryptoContext
#' @param sk This party's PrivateKey
#' @param ct A Ciphertext or a list of Ciphertexts
#' @return A partially decrypted Ciphertext or list of
#'   Ciphertexts, mirroring the input shape.
#' @export
multiparty_decrypt_lead <- function(cc, sk, ct) {
  if (is.list(ct) && !S7::S7_inherits(ct, Ciphertext)) {
    ct_ptrs <- lapply(ct, get_ptr)
    result_ptrs <- MultipartyDecryptLead__ct_vec(
      get_ptr(cc), get_ptr(sk), ct_ptrs)
    return(lapply(result_ptrs, function(p) Ciphertext(ptr = p)))
  }
  Ciphertext(ptr = MultipartyDecryptLead(get_ptr(cc), get_ptr(sk), get_ptr(ct)))
}

#' Non-lead party's partial decryption
#'
#' Other parties call this after the lead. Accepts either a
#' single `Ciphertext` or a list of `Ciphertext` objects with the
#' same semantics as [multiparty_decrypt_lead()].
#'
#' @param cc A CryptoContext
#' @param sk This party's PrivateKey
#' @param ct A Ciphertext or a list of Ciphertexts
#' @return A partially decrypted Ciphertext or list of
#'   Ciphertexts, mirroring the input shape.
#' @export
multiparty_decrypt_main <- function(cc, sk, ct) {
  if (is.list(ct) && !S7::S7_inherits(ct, Ciphertext)) {
    ct_ptrs <- lapply(ct, get_ptr)
    result_ptrs <- MultipartyDecryptMain__ct_vec(
      get_ptr(cc), get_ptr(sk), ct_ptrs)
    return(lapply(result_ptrs, function(p) Ciphertext(ptr = p)))
  }
  Ciphertext(ptr = MultipartyDecryptMain(get_ptr(cc), get_ptr(sk), get_ptr(ct)))
}

#' Fuse partial decryptions into final plaintext
#'
#' Combines partial decryptions from any number of parties (n >= 2).
#' The lead party's partial decryption (from
#' [multiparty_decrypt_lead()]) must be supplied first; subsequent
#' partials (from [multiparty_decrypt_main()]) follow in any order.
#'
#' @param cc A CryptoContext
#' @param ... Two or more partially decrypted Ciphertext objects.
#'   The first must be from the lead party.
#' @return A Plaintext with the final decrypted result
#' @export
multiparty_decrypt_fusion <- function(cc, ...) {
  partials <- list(...)
  if (length(partials) < 2L) {
    cli::cli_abort(
      "{.fn multiparty_decrypt_fusion} needs at least two partial \\
       decryptions; got {length(partials)}.")
  }
  partial_ptrs <- lapply(partials, get_ptr)
  Plaintext(ptr = MultipartyDecryptFusion(get_ptr(cc), partial_ptrs))
}

#' Threshold decryption convenience: lead + main + fusion in one call
#'
#' Performs a full n-of-n threshold decryption of `ct` given the
#' ordered list of party secret keys. The first key in `sks` is used
#' for [multiparty_decrypt_lead()]; the remaining keys for
#' [multiparty_decrypt_main()]; the resulting partials are then
#' fused with [multiparty_decrypt_fusion()].
#'
#' Use this when you have all secret keys in one place (testing,
#' simulation, single-process demos). In a real distributed
#' deployment each site holds only its own secret key and the
#' partials travel over the network — that flow uses the lead /
#' main / fusion functions directly.
#'
#' @param cc A CryptoContext
#' @param sks A list of PrivateKey objects, lead first
#' @param ct The Ciphertext to decrypt
#' @return A Plaintext
#' @export
threshold_decrypt <- function(cc, sks, ct) {
  if (!is.list(sks) || length(sks) < 2L) {
    cli::cli_abort(
      "{.arg sks} must be a list of at least two PrivateKey objects.")
  }
  partials <- vector("list", length(sks))
  partials[[1L]] <- multiparty_decrypt_lead(cc, sks[[1L]], ct)
  for (i in seq.int(2L, length(sks))) {
    partials[[i]] <- multiparty_decrypt_main(cc, sks[[i]], ct)
  }
  do.call(multiparty_decrypt_fusion, c(list(cc), partials))
}

#' EvalKey class for multi-party key operations
#' @param ptr External pointer (internal use)
#' @export
EvalKey <- new_class("EvalKey",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, EvalKey) <- function(x, ...) {
  cli::cli_text("{.cls EvalKey} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}
