# Generate BinFHE bootstrapping keys

Generate BinFHE bootstrapping keys

## Usage

``` r
bin_bt_key_gen(ctx, sk, keygen_mode = KeygenMode$SYM_ENCRYPT)
```

## Arguments

- ctx:

  A BinFHE context

- sk:

  An LWEPrivateKey

- keygen_mode:

  Integer from
  [KeygenMode](https://bnaras.github.io/openfhe.R/reference/KeygenMode.md);
  controls whether the bootstrapping keys are generated under
  symmetric-key encryption (`KeygenMode$SYM_ENCRYPT`, the default and
  the C++ default per `binfhe-constants.h` line 133) or public-key
  encryption (`KeygenMode$PUB_ENCRYPT`), matching the
  `BTKeyGen(sk, keyGenMode)` overload at `binfhecontext.h` line 273.
