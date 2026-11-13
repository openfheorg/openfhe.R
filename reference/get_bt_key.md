# The bootstrapping keys of a BinFHE context

`get_bt_key()` returns the keys
[`bin_bt_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_bt_key_gen.md)
generated, as one
[RingGSWBTKey](https://openfheorg.github.io/openfhe.R/reference/RingGSWBTKey.md);
`bin_bt_key_load()` puts such an object into a context, and
`bin_clear_bt_keys()` removes the keys of a context. Together with
[`fhe_serialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_serialize.md)
and
[`fhe_deserialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_deserialize.md)
they move bootstrapping keys between sessions.

## Usage

``` r
get_bt_key(ctx)

get_bt_key_map(ctx)

bin_bt_key_load(ctx, key, internal32 = TRUE)

bin_bt_key_map_load_single_element(ctx, base_g, key)

bin_clear_bt_keys(ctx)

get_switch_key(ctx)

has_internal32_refresh_key(ctx)

has_internal32_switch_key(ctx)
```

## Arguments

- ctx:

  A `BinFHEContext`.

- key:

  A
  [RingGSWBTKey](https://openfheorg.github.io/openfhe.R/reference/RingGSWBTKey.md).

- internal32:

  Logical; if `TRUE` (default) keys whose moduli fit are converted to
  the 32-bit internal form on loading.

- base_g:

  Integer; the gadget base the key is for.

## Value

`get_bt_key()`: a
[RingGSWBTKey](https://openfheorg.github.io/openfhe.R/reference/RingGSWBTKey.md).
`get_bt_key_map()`: a list of them, named by gadget base.
`get_switch_key()`: an
[LWESwitchingKey](https://openfheorg.github.io/openfhe.R/reference/LWESwitchingKey.md),
or `NULL` if the context holds none in the 64-bit form. The `has_`
functions: a logical. The others: `ctx`, invisibly.

## Details

A context for large-precision evaluation keeps one key per gadget base.
`get_bt_key_map()` returns them, and
`bin_bt_key_map_load_single_element()` loads one.

`get_switch_key()` returns the switching key among the bootstrapping
keys, and
[`get_public_key()`](https://openfheorg.github.io/openfhe.R/reference/get_public_key.md)
the public key.

`has_internal32_refresh_key()` and `has_internal32_switch_key()` say
whether the refreshing and the switching key are held in the library's
32-bit internal form.

## Memory

The bootstrapping keys of a context can occupy several gigabytes (about
5.8 GB for `STD128` with `arb_func = TRUE` and `log_q = 12`). R's
garbage collector does not see this memory, so removing a context with
[`rm()`](https://rdrr.io/r/base/rm.html) does not release it until a
collection happens to run.

- Build one context and reuse it. The keys depend only on the parameters
  and the secret key.

- When a context is no longer needed, call `bin_clear_bt_keys()`. The
  keys are released at once.

- To release the rest of the context, remove it and call
  [`gc()`](https://rdrr.io/r/base/gc.html).
