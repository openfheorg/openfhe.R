# openfhe.R: R Interface to the OpenFHE Fully Homomorphic Encryption Library

Provides an R interface to 'OpenFHE', the open-source C++ library for
fully homomorphic encryption (Al Badawi and others, 2022)
<https://eprint.iacr.org/2022/915>, which allows computation directly on
encrypted data without access to the secret key. Supports the
Brakerski-Fan-Vercauteren (BFV, 2012)
<https://eprint.iacr.org/2012/144>, Brakerski-Gentry-Vaikuntanathan
(BGV, 2014) [doi:10.1145/2633600](https://doi.org/10.1145/2633600) , and
Cheon-Kim-Kim-Song (CKKS, 2017) <https://eprint.iacr.org/2016/421>
schemes for arithmetic on encrypted numbers, together with the
Ducas-Micciancio (FHEW, 2015) <https://eprint.iacr.org/2014/816> and
Chillotti-Gama-Georgieva-Izabachene (TFHE, 2020)
<https://eprint.iacr.org/2018/421> schemes for evaluating arbitrary
functions on encrypted bits.

## See also

Useful links:

- <https://bnaras.github.io/openfhe.R/>

- <https://github.com/bnaras/openfhe.R>

- Report bugs at <https://github.com/bnaras/openfhe.R/issues>

## Author

**Maintainer**: Balasubramanian Narasimhan <naras@stanford.edu>
([ORCID](https://orcid.org/0000-0001-5852-7639))

Authors:

- Balasubramanian Narasimhan <naras@stanford.edu>
  ([ORCID](https://orcid.org/0000-0001-5852-7639))

Other contributors:

- Authors of the OpenFHE C++ library \[contributor, copyright holder\]
