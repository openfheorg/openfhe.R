// R-routed std::ostream implementations for lbcrypto::r_cerr() /
// lbcrypto::r_cout(). The declarations live in the OpenFHE fork at
// src/core/include/utils/openfhe_log.h under OPENFHE_R_BUILD. When
// the R package links openfhe.so, the linker resolves those symbols
// here — so the compiled OpenFHE static archives themselves contain
// NO std::cerr / std::cout / std::clog references, satisfying R CMD
// check's "checking compiled code" rule (Writing R Extensions §1.1.3.1
// step 16: compiled code must not write to stdout/stderr instead of
// the R console).
//
// Pattern adapted from the `scip` R package's src/r_streams.cpp.
// cpp11-compatible: we rely only on <ostream>/<streambuf> from libstdc++
// plus R's plain-C REprintf / Rprintf via <R_ext/Print.h>. No Rcpp.

#include <ostream>
#include <streambuf>
#include <cstring>
#include <algorithm>

#include <R_ext/Print.h>

namespace lbcrypto {
namespace {

// Line-buffered streambuf that routes each flushed chunk through an
// Rf_printf-shaped function pointer (REprintf for stderr, Rprintf for
// stdout). We chunk into ~512-byte pieces so xsputn never lives on
// the stack indefinitely for large payloads.
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

RStreamBuf cerr_buf(REprintf);
RStreamBuf cout_buf(Rprintf);
std::ostream cerr_stream(&cerr_buf);
std::ostream cout_stream(&cout_buf);

}  // anonymous namespace

std::ostream& r_cerr() { return cerr_stream; }
std::ostream& r_cout() { return cout_stream; }

}  // namespace lbcrypto
