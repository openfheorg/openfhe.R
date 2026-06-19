# Lead party's partial decryption

In threshold decryption, the lead party calls this first. Accepts either
a single `Ciphertext` or a list of `Ciphertext` objects:

## Usage

``` r
multiparty_decrypt_lead(cc, sk, ct)
```

## Arguments

- cc:

  A CryptoContext

- sk:

  This party's PrivateKey

- ct:

  A Ciphertext or a list of Ciphertexts

## Value

A partially decrypted Ciphertext or list of Ciphertexts, mirroring the
input shape.

## Details

- single `Ciphertext`: returns a single partially decrypted
  `Ciphertext`, matching the original single-ciphertext signature.

- list of `Ciphertext`: returns a list of partially decrypted
  `Ciphertext` objects of the same length, routed through the C++
  `MultipartyDecryptLead(vector<Ciphertext>, PrivateKey)` overload
  (cryptocontext.h line 3115). Useful when a protocol round needs to
  partially decrypt a batch in one trip.
