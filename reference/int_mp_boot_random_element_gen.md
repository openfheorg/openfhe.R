# Generate a common random element for multi-party bootstrap

Generates a common random polynomial used by all parties in a
multi-party interactive bootstrap round. Two overloads:

## Usage

``` r
int_mp_boot_random_element_gen(cc, source)
```

## Arguments

- cc:

  A `CryptoContext`. Only used by the `PublicKey` overload; the
  `Ciphertext` overload ignores it and uses the source's internal cc.

- source:

  Either a `PublicKey` or a `Ciphertext`.

## Value

A `Ciphertext` holding the common random element.

## Details

- When `source` is a `PublicKey` (the lead party's public key), routes
  to the `(publicKey)` C++ overload.

- When `source` is a `Ciphertext`, routes to the `(ciphertext)` overload
  which derives the cc and parameters from the ciphertext directly —
  convenient when a ciphertext is already in scope.
