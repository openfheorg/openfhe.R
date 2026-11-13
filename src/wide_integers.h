// R-SPECIFIC: exact transport of wide OpenFHE integers across the R boundary
//
// An R double holds 53 bits exactly. OpenFHE's NativeInteger holds 64 and
// its BigInteger is unbounded, and tower moduli, roots of unity and the
// integer scaling factor routinely exceed 53 bits. Those values cross the
// boundary as decimal character strings, in both directions; they never
// pass through a double. openfhe-python does the same thing with Python's
// arbitrary-size int (src/include/integer_conversions.h: IntegerToPyInt,
// PyIntToInteger), so an R string and a Python int denote the same value.
//
// Going out:  wide_to_r(value)            -> std::string of decimal digits
// Coming in:  wide_from_r<Integer>(s, a)  -> Integer, with the checks below
//             uint64_from_r(s, a)         -> uint64_t
//
// The R wrapper normalizes its argument with wide_integer() (R/utils.R)
// before the call, so `s` is normally digits only. The checks are repeated
// here because the registered C++ entry points are reachable without the
// wrapper.
//
// Checks on the way in, matching PyIntToInteger:
//   * digits only. OpenFHE integers are unsigned, and some of OpenFHE's
//     string parsers hang on a leading '-'.
//   * NativeInteger: range-checked against the native width before
//     construction, because NativeInteger's parser does not detect every
//     overflow.
//   * BigInteger: the dynamic backend has no fixed width; the fixed backend
//     throws from its constructor, reported here as the same overflow error.
#pragma once

#include <cpp11.hpp>
#include <cstdint>
#include <limits>
#include <string>
#include <type_traits>

namespace openfhe_r {

template <typename Integer, typename = void>
struct is_native_integer : std::false_type {};

template <typename Integer>
struct is_native_integer<
    Integer,
    std::void_t<typename Integer::Integer, decltype(Integer::IsNativeInt())>>
    : std::bool_constant<Integer::IsNativeInt()> {};

template <typename Integer>
inline std::string wide_to_r(const Integer& value) {
  return value.ToString();
}

// Digits only, leading zeros removed ("0" stays "0").
inline std::string wide_digits(const std::string& s, const char* arg) {
  if (s.empty()) {
    cpp11::stop("`%s` must be a non-negative whole number, got an empty string", arg);
  }
  for (char c : s) {
    if (c < '0' || c > '9') {
      cpp11::stop("`%s` must be a non-negative whole number in decimal digits, got '%s'",
                  arg, s.c_str());
    }
  }
  std::size_t first = s.find_first_not_of('0');
  if (first == std::string::npos) return "0";
  return s.substr(first);
}

// True when the digit string `digits` (no leading zeros) exceeds `max`.
inline bool wide_exceeds(const std::string& digits, const std::string& max) {
  return digits.size() > max.size() ||
         (digits.size() == max.size() && digits > max);
}

template <typename Integer>
inline Integer wide_from_r(const std::string& s, const char* arg) {
  const std::string digits = wide_digits(s, arg);
  if constexpr (is_native_integer<Integer>::value) {
    using NativeType = typename Integer::Integer;
    static const std::string max_value =
        Integer(std::numeric_limits<NativeType>::max()).ToString();
    if (wide_exceeds(digits, max_value)) {
      cpp11::stop("`%s` is too large for a %d-bit OpenFHE integer: %s", arg,
                  static_cast<int>(std::numeric_limits<NativeType>::digits),
                  digits.c_str());
    }
    return Integer(digits);
  } else {
    try {
      return Integer(digits);
    } catch (const std::exception&) {
      cpp11::stop("`%s` is too large for the OpenFHE big-integer type: %s", arg,
                  digits.c_str());
    }
  }
}

// A uint64_t that is small in ordinary use but not by type (the plaintext
// modulus): an R number when a double holds it exactly, otherwise the
// decimal string.
inline SEXP uint64_to_r(uint64_t value) {
  if (value <= (uint64_t{1} << 53)) {
    return cpp11::as_sexp(static_cast<double>(value));
  }
  return cpp11::as_sexp(std::to_string(value));
}

inline uint64_t uint64_from_r(const std::string& s, const char* arg) {
  const std::string digits = wide_digits(s, arg);
  static const std::string max_value =
      std::to_string(std::numeric_limits<uint64_t>::max());
  if (wide_exceeds(digits, max_value)) {
    cpp11::stop("`%s` is too large for a 64-bit unsigned integer: %s", arg,
                digits.c_str());
  }
  return std::stoull(digits);
}

}  // namespace openfhe_r
