// R-SPECIFIC: routes OpenFHE's diagnostic output to the R console.
//
// OpenFHE (1.6.0 and later) writes diagnostics through a pluggable sink,
// declared in utils/diagnostic_output.h: OPENFHE_DIAGNOSTIC_ERR and
// OPENFHE_DIAGNOSTIC_OUT expand to calls of
// lbcrypto::internal_diagnostics::OpenFHEErrStream() / OpenFHEOutStream().
// The library's built-in sink writes to std::cerr / std::cout and is the
// only library code that names those streams.
//
// Two build paths:
//
// 1. Vendored (what CRAN builds). inst/build_openfhe.sh configures the
//    static archives with -DWITH_DEFAULT_DIAGNOSTIC_SINK=OFF, so they
//    contain no sink and no std::cerr / std::cout symbol, which R CMD
//    check's "checking compiled code" step requires (Writing R
//    Extensions §1.1.3.1). This file supplies the sink: the accessors
//    and the two setters, over streams that write through REprintf /
//    Rprintf.
//
// 2. OPENFHE_HOME (local development against a shared library built
//    with the default sink). The library already defines the sink, so
//    this file defines nothing of it and instead installs the R streams
//    through the library's setters when the package's shared object is
//    loaded.
//
// The stream buffer follows the `scip` R package's src/r_streams.cpp.
// cpp11-compatible: only <ostream>/<streambuf> plus R's plain-C
// REprintf / Rprintf from <R_ext/Print.h>. No Rcpp.

#include <algorithm>
#include <cstring>
#include <ostream>
#include <streambuf>

#include <R_ext/Print.h>

#include "config_core.h"
#include "utils/diagnostic_output.h"

// configure and configure.win pass -DOPENFHE_R_VENDORED on the vendored
// path. If the vendored archives were nevertheless built with the
// default sink, they carry std::cerr / std::cout and the definitions
// below would be missing; fail the build instead of shipping that.
#if defined(OPENFHE_R_VENDORED) && defined(WITH_DEFAULT_DIAGNOSTIC_SINK)
#error "Vendored OpenFHE was built with WITH_DEFAULT_DIAGNOSTIC_SINK; inst/build_openfhe.sh must pass -DWITH_DEFAULT_DIAGNOSTIC_SINK:bool=OFF"
#endif

namespace lbcrypto {
namespace {

// Streambuf that routes each chunk through an Rf_printf-shaped function
// pointer (REprintf for the error channel, Rprintf for the output
// channel), in pieces of at most 511 bytes.
class RStreamBuf : public std::streambuf {
    void (*m_fn)(const char*, ...);

 protected:
    std::streamsize xsputn(const char* s, std::streamsize n) override {
        const std::streamsize max_chunk = 511;
        std::streamsize written = 0;
        char tmp[512];
        while (written < n) {
            std::streamsize chunk = std::min(n - written, max_chunk);
            std::memcpy(tmp, s + written, static_cast<size_t>(chunk));
            tmp[chunk] = '\0';
            m_fn("%s", tmp);
            written += chunk;
        }
        return n;
    }

    int overflow(int c) override {
        if (c != EOF) {
            char ch = static_cast<char>(c);
            m_fn("%c", ch);
        }
        return c;
    }

 public:
    explicit RStreamBuf(void (*fn)(const char*, ...)) : m_fn(fn) {}
};

RStreamBuf r_err_buf(REprintf);
RStreamBuf r_out_buf(Rprintf);
std::ostream r_err_stream(&r_err_buf);
std::ostream r_out_stream(&r_out_buf);

#ifndef WITH_DEFAULT_DIAGNOSTIC_SINK

std::ostream* g_errStream = &r_err_stream;
std::ostream* g_outStream = &r_out_stream;

#else

// Development path: redirect the library's own sink once, when this
// shared object is loaded. The library is a dependency of this object,
// so its sink is initialized first.
[[maybe_unused]] const bool r_streams_installed = []() noexcept {
    SetOpenFHEErrStream(r_err_stream);
    SetOpenFHEOutStream(r_out_stream);
    return true;
}();

#endif

}  // anonymous namespace

#ifndef WITH_DEFAULT_DIAGNOSTIC_SINK

namespace internal_diagnostics {

std::ostream& OpenFHEErrStream() {
    return *g_errStream;
}

std::ostream& OpenFHEOutStream() {
    return *g_outStream;
}

}  // namespace internal_diagnostics

std::ostream& SetOpenFHEErrStream(std::ostream& os) {
    std::ostream& previous = *g_errStream;
    g_errStream = &os;
    return previous;
}

std::ostream& SetOpenFHEOutStream(std::ostream& os) {
    std::ostream& previous = *g_outStream;
    g_outStream = &os;
    return previous;
}

#endif  // WITH_DEFAULT_DIAGNOSTIC_SINK

}  // namespace lbcrypto
