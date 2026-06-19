// R-SPECIFIC: cpp11 <-> OpenFHE exception bridge
//
// design.md §5 pins this helper. Every binding that can throw wraps its
// C++ call site in catch_openfhe(op, [&]() { ... }); an OPENFHE_THROW (or
// any std::exception) is converted to a cpp11::stop condition carrying
// the operation name and the C++ what() string. The R-wrapper layer is
// responsible for catching that condition and re-emitting through
// cli::cli_abort (cpp11 cannot call cli directly without a layering
// violation — see design.md §5 "Layering" paragraph).
//
// cpp11::stop is [[noreturn]], so the compiler treats the catch arms as
// terminating paths; the try-block's return path is the only one that
// produces a value.
#pragma once

#include <cpp11.hpp>
#include <exception>

template <typename F>
auto catch_openfhe(const char* op, F&& fn) -> decltype(fn()) {
    try {
        return fn();
    } catch (const std::exception& e) {
        cpp11::stop("OpenFHE error in %s: %s", op, e.what());
    } catch (...) {
        cpp11::stop("Unknown OpenFHE error in %s", op);
    }
}
