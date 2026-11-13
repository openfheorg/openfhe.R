# Generate BinFHE bootstrapping keys

Generate BinFHE bootstrapping keys

## Usage

``` r
bin_bt_key_gen(
  ctx,
  sk,
  keygen_mode = KeygenMode$SYM_ENCRYPT,
  internal32 = TRUE
)
```

## Arguments

- ctx:

  A BinFHE context

- sk:

  An LWEPrivateKey

- keygen_mode:

  Integer from
  [KeygenMode](https://openfheorg.github.io/openfhe.R/reference/KeygenMode.md);
  controls whether the bootstrapping keys are generated under
  symmetric-key encryption (`KeygenMode$SYM_ENCRYPT`, the default and
  the C++ default per `binfhe-constants.h` line 133) or public-key
  encryption (`KeygenMode$PUB_ENCRYPT`), matching the
  `BTKeyGen(sk, keygenMode, internal32)` method in `binfhecontext.h`.

- internal32:

  Logical. If `TRUE` (the default, and the C++ default), keys whose
  moduli fit are generated directly in the library's 32-bit internal
  form; a key that does not qualify is generated in the 64-bit form. If
  `FALSE`, all keys are generated in the 64-bit form.

## Value

Invisibly, the `ctx` BinFHE context that was passed in. Called for its
side effect: the bootstrapping and key-switching keys are generated and
stored inside the C++ context, after which
[`eval_bin_gate()`](https://openfheorg.github.io/openfhe.R/reference/eval_bin_gate.md)
and the other gate evaluations can be used.
