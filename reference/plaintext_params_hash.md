# Deterministic hash of a plaintext's identifying parameters

Combines the plaintext's encoding type, scaling factor, noise scale
degree, level, and slot count into a deterministic string
representation. Two plaintexts with identical parameters produce
identical strings; any parameter change produces a different string.

## Usage

``` r
plaintext_params_hash(x)
```

## Arguments

- x:

  A `Plaintext`.

## Value

Character scalar.

## Details

Named `plaintext_params_hash` in design.md §10 as the fourth "harness
unblocker" for the Signal 2 differential fixture for
`make_ckks_packed_plaintext`. The fixture calls
`plaintext_params_hash()` on a default and a perturbed plaintext and
expects different strings when the perturbation reaches the C++ call
site.

Not a cryptographic hash — equality comparison is the only guarantee.
The returned string's format is implementation detail and may change
without notice.
