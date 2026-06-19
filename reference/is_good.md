# Is a KeyPair valid?

Returns `TRUE` when both the public and secret keys of a `KeyPair` are
non-null external pointers. The C++ `KeyPair::good()` predicate performs
the same check on the C++ side; because R's `KeyPair` is a pure-R
aggregate that wraps an already-constructed `PublicKey` and
`PrivateKey`, the R-level check is equivalent.

## Usage

``` r
is_good(kp, ...)
```

## Arguments

- kp:

  A `KeyPair`.

- ...:

  Reserved for future method-specific arguments (currently unused).

## Value

`TRUE` or `FALSE`.
