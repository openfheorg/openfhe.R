## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalKeyMap + Multi-eval-key family)
##
## EvalKeyMap S7 class + the multi-eval-key
## generator fleet + the get/insert helpers on the cc-internal
## eval-key registry. EvalKeyMap wraps a
## shared_ptr<std::map<uint32_t, EvalKey<DCRTPoly>>> opaquely; the
## R user does not index into the map directly and instead passes
## EvalKeyMap instances through the Multi* flow or the Insert
## helpers to register them on the cc's internal eval-key storage.

#' Map of homomorphic evaluation keys
#'
#' Opaque S7 wrapper around a
#' `shared_ptr<std::map<uint32_t, EvalKey<DCRTPoly>>>`. Produced
#' by the `multi_eval_*_key_gen()` family and by
#' [get_eval_sum_key_map()] / [get_eval_automorphism_key_map()];
#' consumed by [multi_add_eval_sum_keys()],
#' [multi_add_eval_automorphism_keys()], [insert_eval_sum_key()],
#' and [insert_eval_automorphism_key()]. The map is keyed by a
#' rotation/automorphism index and carries one `EvalKey` per
#' index.
#'
#' Users do not construct or index into an `EvalKeyMap`
#' directly — it is a transport format for the multi-party
#' eval-key protocols. In a single-user protocol the same data
#' is tracked inside the `CryptoContext`'s internal key
#' registry (populated by `EvalSumKeyGen()` /
#' `EvalRotateKeyGen()`) and is only exposed as an `EvalKeyMap`
#' when the distributed-party flow needs to exchange it.
#'
#' @param ptr External pointer (internal use).
#' @export
EvalKeyMap <- new_class("EvalKeyMap",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, EvalKeyMap) <- function(x, ...) {
  cli::cli_text("{.cls EvalKeyMap} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

# ── Sum-key generation ─────────────────────────────────

#' Generate sum keys for a secret key
#'
#' Populates the `CryptoContext`'s internal sum-key registry
#' (keyed by the secret key's tag) so that [eval_sum()] and the
#' multi-party sum-key protocol can consume the generated
#' entries. Closes a long-standing gap: the underlying
#' `CryptoContext__EvalSumKeyGen` cpp11 binding has been present
#' since the early phases but had no standalone R wrapper —
#' users had to go through [key_gen()]'s side-effects only.
#' The wrapper lands so that the multi-party sum-key flow
#' (which needs to call this on each party's secret share) has
#' a direct R-level entry point.
#'
#' @param cc A `CryptoContext`.
#' @param sk A `PrivateKey` whose tag will be used to key the
#'   generated sum-key map in the cc's internal registry.
#' @return `NULL`, invisibly.
#' @export
eval_sum_key_gen <- function(cc, sk) {
  CryptoContext__EvalSumKeyGen(get_ptr(cc), get_ptr(sk))
  invisible(NULL)
}

#' Generate relinearization (eval-mult) keys for a secret key
#'
#' Standalone wrapper around the
#' `CryptoContext::EvalMultKeyGen(privateKey)` C++ method.
#' Populates the `CryptoContext`'s internal eval-mult registry
#' (keyed by the secret key's tag) so that ciphertext ×
#' ciphertext multiplication can be relinearized.
#'
#' [key_gen()] folds this into its `eval_mult = TRUE` branch as
#' a convenience for fresh keypairs. The standalone wrapper is
#' the right entry point when the secret key already exists —
#' for example in any threshold or multi-party flow that holds
#' a secret-key share but did not generate it through
#' `key_gen()`.
#'
#' @param cc A `CryptoContext`.
#' @param sk A `PrivateKey` whose tag will be used to key the
#'   generated eval-mult key in the cc's internal registry.
#' @return `NULL`, invisibly.
#' @export
eval_mult_key_gen <- function(cc, sk) {
  CryptoContext__EvalMultKeyGen(get_ptr(cc), get_ptr(sk))
  invisible(NULL)
}

#' Generate rotation keys for a secret key
#'
#' Standalone wrapper around the
#' `CryptoContext::EvalRotateKeyGen(privateKey, indexList)` C++
#' method. Populates the `CryptoContext`'s internal automorphism
#' key registry for the supplied rotation indices so that
#' [eval_rotate()] can consume them.
#'
#' [key_gen()] folds this into its `rotations = ...` argument as
#' a convenience for fresh keypairs. The standalone wrapper is
#' the right entry point when the secret key already exists —
#' for example as the lead-party rotation-key generation step in
#' a multi-party rotation protocol, where subsequent parties
#' contribute via [multi_eval_at_index_key_gen()].
#'
#' @param cc A `CryptoContext`.
#' @param sk A `PrivateKey` whose tag will be used to key the
#'   generated rotation keys in the cc's internal registry.
#' @param index_list Integer vector of rotation indices.
#' @return `NULL`, invisibly.
#' @export
eval_rotate_key_gen <- function(cc, sk, index_list) {
  CryptoContext__EvalRotateKeyGen(get_ptr(cc), get_ptr(sk),
                                  as.integer(index_list))
  invisible(NULL)
}

#' Generate at-index (rotation) keys for a secret key
#'
#' Standalone wrapper around the
#' `CryptoContext::EvalAtIndexKeyGen(privateKey, indexList)` C++
#' method. Functionally identical to [eval_rotate_key_gen()]
#' (the C++ `EvalRotateKeyGen` is a thin inline wrapper around
#' `EvalAtIndexKeyGen`) and both names are provided to mirror the
#' C++ API.
#'
#' @param cc A `CryptoContext`.
#' @param sk A `PrivateKey` whose tag will be used to key the
#'   generated rotation keys in the cc's internal registry.
#' @param index_list Integer vector of rotation indices.
#' @return `NULL`, invisibly.
#' @export
eval_at_index_key_gen <- function(cc, sk, index_list) {
  CryptoContext__EvalAtIndexKeyGen(get_ptr(cc), get_ptr(sk),
                                   as.integer(index_list))
  invisible(NULL)
}

# ── Multi-eval-key generators ───────────────────────────

#' Generate a joint automorphism-key share for multi-party rotation
#'
#' Produces this party's share of the joined automorphism eval
#' key map for the supplied `index_list`. Each other party calls
#' the same method with their own secret share, and the shares
#' are combined via [multi_add_eval_automorphism_keys()] to
#' produce the final joined map.
#'
#' @param cc A `CryptoContext` with the `MULTIPARTY` feature
#'   enabled.
#' @param sk This party's `PrivateKey` share.
#' @param eval_key_map An existing `EvalKeyMap` carrying the
#'   prior-party automorphism key state, obtained via
#'   [get_eval_automorphism_key_map()] after the lead party has
#'   populated the cc registry through `key_gen(cc, rotations = ...)`.
#' @param index_list Integer vector of rotation indices.
#' @param key_tag Character; optional tag to associate with the
#'   produced map. Default `""`.
#' @return An `EvalKeyMap` holding this party's joint share.
#' @export
multi_eval_automorphism_key_gen <- function(cc, sk, eval_key_map,
                                            index_list, key_tag = "") {
  EvalKeyMap(ptr = MultiEvalAutomorphismKeyGen__(
    get_ptr(cc), get_ptr(sk), get_ptr(eval_key_map),
    as.integer(index_list), as.character(key_tag)))
}

#' Generate a joint rotation-at-index key share
#'
#' The `EvalAtIndex` flavor of [multi_eval_automorphism_key_gen()];
#' takes signed rotation indices rather than automorphism indices.
#' Semantically equivalent but lives on a distinct C++ entry
#' point.
#'
#' @param cc A `CryptoContext`.
#' @param sk This party's `PrivateKey` share.
#' @param eval_key_map An existing `EvalKeyMap`.
#' @param index_list Integer vector of signed rotation indices.
#' @param key_tag Character; default `""`.
#' @return An `EvalKeyMap`.
#' @export
multi_eval_at_index_key_gen <- function(cc, sk, eval_key_map,
                                        index_list, key_tag = "") {
  EvalKeyMap(ptr = MultiEvalAtIndexKeyGen__(
    get_ptr(cc), get_ptr(sk), get_ptr(eval_key_map),
    as.integer(index_list), as.character(key_tag)))
}

#' Generate a joint sum-key share for multi-party EvalSum
#'
#' @param cc A `CryptoContext`.
#' @param sk This party's `PrivateKey` share.
#' @param eval_key_map An existing `EvalKeyMap` carrying the
#'   prior-party sum-key state, obtained via
#'   [get_eval_sum_key_map()] after the lead party has populated
#'   the cc registry through `eval_sum_key_gen()`.
#' @param key_tag Character; default `""`.
#' @return An `EvalKeyMap`.
#' @export
multi_eval_sum_key_gen <- function(cc, sk, eval_key_map, key_tag = "") {
  EvalKeyMap(ptr = MultiEvalSumKeyGen__(
    get_ptr(cc), get_ptr(sk), get_ptr(eval_key_map),
    as.character(key_tag)))
}

# ── Multi-eval-key adders ───────────────────────────────

#' Combine two sum-key map shares into a joint sum-key map
#'
#' @param cc A `CryptoContext`.
#' @param eval_key_map1,eval_key_map2 `EvalKeyMap` shares from
#'   two parties.
#' @param key_tag Character; default `""`.
#' @return A combined `EvalKeyMap` suitable for insertion into
#'   the cc registry via [insert_eval_sum_key()].
#' @export
multi_add_eval_sum_keys <- function(cc, eval_key_map1, eval_key_map2,
                                    key_tag = "") {
  EvalKeyMap(ptr = MultiAddEvalSumKeys__(
    get_ptr(cc), get_ptr(eval_key_map1), get_ptr(eval_key_map2),
    as.character(key_tag)))
}

#' Combine two automorphism-key map shares
#'
#' @param cc A `CryptoContext`.
#' @param eval_key_map1,eval_key_map2 `EvalKeyMap` shares from
#'   two parties.
#' @param key_tag Character; default `""`.
#' @return A combined `EvalKeyMap` suitable for insertion into
#'   the cc registry via [insert_eval_automorphism_key()].
#' @export
multi_add_eval_automorphism_keys <- function(cc, eval_key_map1,
                                             eval_key_map2, key_tag = "") {
  EvalKeyMap(ptr = MultiAddEvalAutomorphismKeys__(
    get_ptr(cc), get_ptr(eval_key_map1), get_ptr(eval_key_map2),
    as.character(key_tag)))
}

# ── EvalKeyMap get helpers ──────────────────────────────

#' Retrieve the sum-key map for a given key tag
#'
#' Accessor for the cc-internal static map populated by
#' `eval_sum_key_gen()`. Used by the multi-party sum protocol to
#' pull the lead party's initial eval-sum map so other parties
#' can produce their shares.
#'
#' The underlying C++ call returns a `const std::map&`; the R
#' wrapper copies the map into a fresh `shared_ptr` to give the
#' returned `EvalKeyMap` owning semantics. The returned map is a
#' snapshot: subsequent modifications to the cc registry are not
#' reflected.
#'
#' @param key_tag Character; the key tag used when the map was
#'   originally generated. Typically the `get_key_tag()` of the
#'   secret key that produced it.
#' @return An `EvalKeyMap`.
#' @export
get_eval_sum_key_map <- function(key_tag) {
  EvalKeyMap(ptr = CryptoContext__GetEvalSumKeyMap(as.character(key_tag)))
}

#' Retrieve the automorphism-key map for a given key tag
#'
#' Accessor for the cc-internal static automorphism-key map. The
#' underlying C++ call returns a `shared_ptr` directly (no copy),
#' so the returned `EvalKeyMap` is a live view of the cc
#' registry.
#'
#' @param key_tag Character; the key tag used when the map was
#'   originally generated.
#' @return An `EvalKeyMap`.
#' @export
get_eval_automorphism_key_map <- function(key_tag) {
  EvalKeyMap(ptr = CryptoContext__GetEvalAutomorphismKeyMapPtr(
    as.character(key_tag)))
}

# ── Automorphism surface ───────

#' Compute the automorphism index for a single slot index
#'
#' Maps a CKKS slot index to the corresponding automorphism
#' index in the cyclotomic ring `Z[X]/(X^N + 1)`. The
#' automorphism group of the ring is isomorphic to the
#' multiplicative group `(Z/2N)*`; this function returns the
#' representative of that group that corresponds to rotating
#' the plaintext slots by the given amount.
#'
#' Used as a primitive by [find_automorphism_indices()] and
#' by code that needs to address automorphism keys directly
#' (for example, selectively generating eval keys for a
#' sparse set of rotation amounts).
#'
#' @param cc A `CryptoContext`.
#' @param index Integer; the slot index (positive = left
#'   rotation, negative = right rotation).
#' @return Integer; the automorphism group element
#'   corresponding to that rotation.
#' @seealso [find_automorphism_indices()] for the vector form.
#' @export
find_automorphism_index <- function(cc, index) {
  CryptoContext__FindAutomorphismIndex(get_ptr(cc), as.integer(index))
}

#' Compute the automorphism indices for a list of slot indices
#'
#' Vector form of [find_automorphism_index()]. Takes a vector
#' of slot indices and returns the corresponding automorphism
#' indices in the same order.
#'
#' @param cc A `CryptoContext`.
#' @param indices Integer vector of slot indices.
#' @return Integer vector of automorphism indices.
#' @seealso [find_automorphism_index()]
#' @export
find_automorphism_indices <- function(cc, indices) {
  CryptoContext__FindAutomorphismIndices(get_ptr(cc),
                                         as.integer(indices))
}

#' Generate automorphism evaluation keys for a set of indices
#'
#' Generates the eval-key map needed to apply
#' [eval_automorphism()] at the given set of slot indices.
#' The generated keys are both inserted into the
#' CryptoContext's internal eval-automorphism-key registry
#' (keyed by `sk`'s tag) **and** returned as an `EvalKeyMap`
#' handle that the caller can pass directly to
#' [eval_automorphism()].
#'
#' On the C++ side this is equivalent to calling
#' `EvalAutomorphismKeyGen(sk, indices)` which internally
#' calls `CryptoContextImpl::InsertEvalAutomorphismKey` with
#' the generated map (cryptocontext.h line 2237). The dual
#' return / registry-insert pattern mirrors the equivalent C++
#' entry point.
#'
#' Companion to `eval_rotate_key_gen()` (reached via
#' [key_gen()]'s `rotations` argument): both populate the
#' same cc-internal storage. The automorphism form gives raw
#' access to the automorphism group element (bypassing the
#' rotate-to-automorphism slot mapping that
#' `eval_rotate_key_gen` performs internally).
#'
#' @param cc A `CryptoContext`.
#' @param sk A `PrivateKey`.
#' @param indices Integer vector of automorphism indices
#'   (not slot indices — use [find_automorphism_indices()] to
#'   compute them from slot indices).
#' @return An `EvalKeyMap` with one entry per input index.
#' @seealso [eval_automorphism()],
#'   [find_automorphism_indices()]
#' @export
eval_automorphism_key_gen <- function(cc, sk, indices) {
  EvalKeyMap(ptr = CryptoContext__EvalAutomorphismKeyGen(
    get_ptr(cc), get_ptr(sk), as.integer(indices)))
}

#' Apply an automorphism to a ciphertext
#'
#' Evaluates the automorphism at the given index on `ct`
#' using the eval-key map returned by
#' [eval_automorphism_key_gen()]. The result is a new
#' ciphertext whose decrypted slot vector is a permutation
#' of `ct`'s slot vector (the permutation determined by the
#' automorphism group element).
#'
#' @param ct A `Ciphertext`.
#' @param index Integer; the automorphism index (must match
#'   one of the indices passed to
#'   [eval_automorphism_key_gen()]).
#' @param eval_key_map An `EvalKeyMap` from
#'   [eval_automorphism_key_gen()].
#' @return A transformed `Ciphertext`.
#' @seealso [eval_automorphism_key_gen()],
#'   [eval_rotate()]
#' @export
eval_automorphism <- function(ct, index, eval_key_map) {
  Ciphertext(ptr = EvalAutomorphism__(get_ptr(ct),
                                      as.integer(index),
                                      get_ptr(eval_key_map)))
}

# ── EvalKeyMap read-all getters ──────────

#' Retrieve all registered EvalMult key vectors
#'
#' Reads the entire `CryptoContextImpl` internal EvalMult key
#' map — a named R list keyed by secret-key tag, where each
#' element is itself a list of `EvalKey` objects (the vector
#' of multiplication-eval keys registered under that tag).
#'
#' The returned list is a **snapshot**: each `EvalKey` wraps
#' a fresh `shared_ptr` copy, so retained references survive
#' subsequent [clear_eval_mult_keys()] calls. The underlying
#' keys are still shared with the cc registry — modifications
#' through other paths remain visible.
#'
#' Primary consumer: checkpoint/resume workflows that need to
#' audit which parties have keys registered before serializing
#' the cc.
#'
#' @return A named list keyed by key-tag string. Each element
#'   is a list of `EvalKey` objects.
#' @seealso [get_eval_mult_key_vector()] for per-tag lookup,
#'   [insert_eval_mult_key()] for the write path.
#' @export
get_all_eval_mult_keys <- function() {
  raw <- CryptoContext__GetAllEvalMultKeys()
  lapply(raw, function(vec) {
    lapply(vec, function(p) EvalKey(ptr = p))
  })
}

#' Retrieve the EvalMult key vector for a given key tag
#'
#' Reads the vector of EvalMult keys registered under
#' `key_tag`. Errors (via `catch_openfhe`) if the tag is not
#' present in the registry.
#'
#' @param key_tag Character; the tag to look up (typically
#'   `get_key_tag(sk)` of a generated `PrivateKey`).
#' @return A list of `EvalKey` objects.
#' @seealso [get_all_eval_mult_keys()], [insert_eval_mult_key()]
#' @export
get_eval_mult_key_vector <- function(key_tag) {
  raw <- CryptoContext__GetEvalMultKeyVector(as.character(key_tag))
  lapply(raw, function(p) EvalKey(ptr = p))
}

#' Retrieve all registered EvalAutomorphism key maps
#'
#' Reads the entire `CryptoContextImpl` internal EvalAutomorphism
#' key map — a named R list keyed by secret-key tag, where each
#' element is an `EvalKeyMap` (the rotation/automorphism key map
#' for that party). Used for rotation and EvalAtIndex under the
#' EvalKeyMap wire format.
#'
#' @return A named list keyed by key-tag string. Each element
#'   is an `EvalKeyMap` (opaque wrapper around
#'   `shared_ptr<map<uint32_t, EvalKey<DCRTPoly>>>`).
#' @seealso [get_eval_automorphism_key_map()] for per-tag
#'   lookup, [insert_eval_automorphism_key()] for the write
#'   path.
#' @export
get_all_eval_automorphism_keys <- function() {
  raw <- CryptoContext__GetAllEvalAutomorphismKeys()
  lapply(raw, function(p) EvalKeyMap(ptr = p))
}

#' Retrieve all registered EvalSum key maps
#'
#' Reads the entire `CryptoContextImpl` internal EvalSum key
#' map. Structurally identical to
#' [get_all_eval_automorphism_keys()]: both share backing
#' storage on the C++ side, but the
#' two accessors are exposed separately so callers can match
#' whichever OpenFHE doc they are reading.
#'
#' @return A named list keyed by key-tag string. Each element
#'   is an `EvalKeyMap`.
#' @seealso [get_eval_sum_key_map()], [insert_eval_sum_key()]
#' @export
get_all_eval_sum_keys <- function() {
  raw <- CryptoContext__GetAllEvalSumKeys()
  lapply(raw, function(p) EvalKeyMap(ptr = p))
}

# ── EvalKeyMap insert helpers ───────────────────────────

#' Insert a joined sum-key map into the cc registry
#'
#' After combining multi-party shares via
#' [multi_add_eval_sum_keys()], the joined map has to be
#' inserted back into the cc's internal static registry before
#' `eval_sum()` can consume it. `insert_eval_sum_key()` routes
#' the map through `CryptoContextImpl::InsertEvalSumKey` (which
#' delegates internally to `InsertEvalAutomorphismKey` — the
#' same static storage is shared between the two surfaces).
#'
#' @param eval_key_map An `EvalKeyMap` from
#'   [multi_add_eval_sum_keys()] or constructed through the
#'   distributed key-gen flow.
#' @param key_tag Character; the tag to register the map under.
#'   Default `""`.
#' @return `NULL`, invisibly.
#' @export
insert_eval_sum_key <- function(eval_key_map, key_tag = "") {
  CryptoContext__InsertEvalSumKey(get_ptr(eval_key_map),
                                  as.character(key_tag))
  invisible(NULL)
}

#' Insert a joined automorphism-key map into the cc registry
#'
#' After combining multi-party automorphism-key shares via
#' [multi_add_eval_automorphism_keys()], insert the joined map
#' into the cc-internal registry so that
#' `eval_rotate()` / `eval_fast_rotation()` can consume it.
#'
#' @param eval_key_map An `EvalKeyMap`.
#' @param key_tag Character; default `""`.
#' @return `NULL`, invisibly.
#' @export
insert_eval_automorphism_key <- function(eval_key_map, key_tag = "") {
  CryptoContext__InsertEvalAutomorphismKey(get_ptr(eval_key_map),
                                           as.character(key_tag))
  invisible(NULL)
}
