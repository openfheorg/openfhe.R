// OPENFHE PYTHON SOURCE: src/lib/pke/serialization.cpp (in-memory serialization, EvalKey and EvalKeyMap files, bootstrap keys)
//
// What openfhe-python 1.6.1.0 binds beyond the file-based forms already
// in pke_serialization.cpp:
//
//   Serialize(obj, sertype)                 an object to a string
//   Deserialize*String(data, sertype)       and back
//   SerializeToFile / DeserializeEvalKey / DeserializeEvalKeyMap
//                                           for EvalKey and EvalKeyMap
//   SerializeEval{Mult,Automorphism}KeyString, Deserialize...String
//                                           the key registries, in memory
//   SerializeEval{Mult,Automorphism,Sum}Key(.., cryptoContext)
//                                           the keys of one context
//   SerializeEvalBootstrapKey, DeserializeEvalBootstrapKey (two forms)
//
// In memory, binary data is an R raw vector (Python: bytes) and JSON a
// character string (Python: str).
//
//   kind: 0 CryptoContext, 1 PublicKey, 2 PrivateKey, 3 Ciphertext,
//         4 EvalKey, 5 EvalKeyMap, 6 vector of EvalKey
//   which (key registries): 0 mult, 1 automorphism, 2 sum
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

#include <fstream>
#include <map>
#include <memory>
#include <sstream>
#include <string>
#include <vector>

#include "ciphertext-ser.h"
#include "cryptocontext-ser.h"
#include "key/key-ser.h"

using namespace cpp11;

namespace {

using CC = CryptoContext<DCRTPoly>;
using EvalKeyMapSP = std::shared_ptr<std::map<uint32_t, EvalKey<DCRTPoly>>>;
using EvalKeyVec = std::vector<EvalKey<DCRTPoly>>;

// Call fn with the serialization tag object for the format.
template <typename Fn>
auto with_sertype(bool binary, Fn&& fn) {
  return binary ? fn(SerType::BINARY) : fn(SerType::JSON);
}

// Serialized bytes as an R object: raw for binary, a string for JSON.
SEXP bytes_to_r(const std::string& s, bool binary) {
  if (binary) {
    writable::raws out(static_cast<R_xlen_t>(s.size()));
    std::copy(s.begin(), s.end(), RAW(static_cast<SEXP>(out)));
    return out;
  }
  return cpp11::as_sexp(s);
}

// And back: a raw vector, or a single string.
std::string bytes_from_r(SEXP data) {
  if (TYPEOF(data) == RAWSXP) {
    const Rbyte* p = RAW(data);
    return std::string(reinterpret_cast<const char*>(p),
                       static_cast<size_t>(Rf_xlength(data)));
  }
  if (TYPEOF(data) == STRSXP && Rf_xlength(data) == 1) {
    SEXP ch = STRING_ELT(data, 0);
    return std::string(CHAR(ch), static_cast<size_t>(Rf_xlength(ch)));
  }
  cpp11::stop("`data` must be a raw vector or a single character string");
}

template <typename T>
SEXP to_memory(const T& obj, bool binary) {
  std::ostringstream os(std::ios::out | std::ios::binary);
  with_sertype(binary, [&](const auto& st) {
    Serial::Serialize(obj, os, st);
    return true;
  });
  return bytes_to_r(os.str(), binary);
}

template <typename T>
T from_memory(SEXP data, bool binary) {
  std::istringstream is(bytes_from_r(data), std::ios::in | std::ios::binary);
  T obj;
  with_sertype(binary, [&](const auto& st) {
    Serial::Deserialize(obj, is, st);
    return true;
  });
  return obj;
}

EvalKeyVec eval_key_vector(const list& eks) {
  EvalKeyVec v;
  v.reserve(eks.size());
  for (R_xlen_t i = 0; i < eks.size(); ++i) {
    SEXP xp = eks[i];
    xptr<EvalKey<DCRTPoly>> ek(xp);
    v.push_back(*ek);
  }
  return v;
}

list eval_key_list(const EvalKeyVec& v) {
  writable::list out(static_cast<R_xlen_t>(v.size()));
  for (size_t i = 0; i < v.size(); ++i) {
    out[static_cast<R_xlen_t>(i)] =
        xptr<EvalKey<DCRTPoly>>(new EvalKey<DCRTPoly>(v[i]));
  }
  return out;
}

void need(bool ok, const char* what) {
  if (!ok) cpp11::stop("deserialization produced no %s", what);
}

}  // namespace

// ── Objects, in memory ──────────────────────────────────

[[cpp11::register]]
SEXP SerializeMem__(SEXP xp, int kind, bool binary) {
  return catch_openfhe("Serial::Serialize", [&]() -> SEXP {
    switch (kind) {
      case 0: { xptr<CC> x(xp); return to_memory(*x, binary); }
      case 1: { xptr<PublicKey<DCRTPoly>> x(xp); return to_memory(*x, binary); }
      case 2: { xptr<PrivateKey<DCRTPoly>> x(xp); return to_memory(*x, binary); }
      case 3: { xptr<Ciphertext<DCRTPoly>> x(xp); return to_memory(*x, binary); }
      case 4: { xptr<EvalKey<DCRTPoly>> x(xp); return to_memory(*x, binary); }
      case 5: { xptr<EvalKeyMapSP> x(xp); return to_memory(*x, binary); }
    }
    cpp11::stop("unknown object kind %d", kind);
  });
}

[[cpp11::register]]
SEXP SerializeMem__EvalKeyVector(list eks, bool binary) {
  EvalKeyVec v = eval_key_vector(eks);
  return catch_openfhe("Serial::Serialize(vector<EvalKey>)", [&]() {
    return to_memory(v, binary);
  });
}

[[cpp11::register]]
SEXP DeserializeMem__(SEXP data, int kind, bool binary) {
  return catch_openfhe("Serial::Deserialize", [&]() -> SEXP {
    switch (kind) {
      case 0: {
        // The context form registers the context with the factory.
        std::istringstream is(bytes_from_r(data), std::ios::in | std::ios::binary);
        CC cc;
        with_sertype(binary, [&](const auto& st) {
          Serial::Deserialize<DCRTPoly>(cc, is, st);
          return true;
        });
        need(static_cast<bool>(cc), "CryptoContext");
        return xptr<CC>(new CC(cc));
      }
      case 1: {
        auto x = from_memory<PublicKey<DCRTPoly>>(data, binary);
        need(static_cast<bool>(x), "PublicKey");
        return xptr<PublicKey<DCRTPoly>>(new PublicKey<DCRTPoly>(x));
      }
      case 2: {
        auto x = from_memory<PrivateKey<DCRTPoly>>(data, binary);
        need(static_cast<bool>(x), "PrivateKey");
        return xptr<PrivateKey<DCRTPoly>>(new PrivateKey<DCRTPoly>(x));
      }
      case 3: {
        auto x = from_memory<Ciphertext<DCRTPoly>>(data, binary);
        need(static_cast<bool>(x), "Ciphertext");
        return xptr<Ciphertext<DCRTPoly>>(new Ciphertext<DCRTPoly>(x));
      }
      case 4: {
        auto x = from_memory<EvalKey<DCRTPoly>>(data, binary);
        need(static_cast<bool>(x), "EvalKey");
        return xptr<EvalKey<DCRTPoly>>(new EvalKey<DCRTPoly>(x));
      }
      case 5: {
        auto x = from_memory<EvalKeyMapSP>(data, binary);
        need(static_cast<bool>(x), "EvalKeyMap");
        return xptr<EvalKeyMapSP>(new EvalKeyMapSP(x));
      }
      case 6:
        return eval_key_list(from_memory<EvalKeyVec>(data, binary));
    }
    cpp11::stop("unknown object kind %d", kind);
  });
}

// ── EvalKey and EvalKeyMap, to and from a file ──────────

[[cpp11::register]]
bool SerializeFile__(SEXP xp, int kind, std::string filename, bool binary) {
  return catch_openfhe("Serial::SerializeToFile", [&]() -> bool {
    switch (kind) {
      case 4: {
        xptr<EvalKey<DCRTPoly>> x(xp);
        return with_sertype(binary, [&](const auto& st) {
          return Serial::SerializeToFile(filename, *x, st);
        });
      }
      case 5: {
        xptr<EvalKeyMapSP> x(xp);
        return with_sertype(binary, [&](const auto& st) {
          return Serial::SerializeToFile(filename, *x, st);
        });
      }
    }
    cpp11::stop("unknown object kind %d", kind);
  });
}

[[cpp11::register]]
SEXP DeserializeFile__(std::string filename, int kind, bool binary) {
  return catch_openfhe("Serial::DeserializeFromFile", [&]() -> SEXP {
    switch (kind) {
      case 4: {
        EvalKey<DCRTPoly> x;
        bool ok = with_sertype(binary, [&](const auto& st) {
          return Serial::DeserializeFromFile(filename, x, st);
        });
        if (!ok || !x) cpp11::stop("Failed to deserialize EvalKey from '%s'", filename.c_str());
        return xptr<EvalKey<DCRTPoly>>(new EvalKey<DCRTPoly>(x));
      }
      case 5: {
        EvalKeyMapSP x;
        bool ok = with_sertype(binary, [&](const auto& st) {
          return Serial::DeserializeFromFile(filename, x, st);
        });
        if (!ok || !x) cpp11::stop("Failed to deserialize EvalKeyMap from '%s'", filename.c_str());
        return xptr<EvalKeyMapSP>(new EvalKeyMapSP(x));
      }
    }
    cpp11::stop("unknown object kind %d", kind);
  });
}

// ── Key registries ──────────────────────────────────────

// To a file when `filename` is a string, otherwise to memory. With a
// context, the keys of that context; otherwise those under `key_tag`
// ("" for all).
[[cpp11::register]]
SEXP SerializeEvalKeys__(int which, SEXP filename, bool binary,
                         std::string key_tag, SEXP cc_xp) {
  const bool to_file = !Rf_isNull(filename);
  const bool by_cc = !Rf_isNull(cc_xp);
  return catch_openfhe("CryptoContext::SerializeEval*Key", [&]() -> SEXP {
    std::ostringstream mem(std::ios::out | std::ios::binary);
    std::ofstream file;
    if (to_file) {
      const std::string path = cpp11::as_cpp<std::string>(filename);
      file.open(path, std::ios::out | std::ios::binary);
      if (!file.is_open()) cpp11::stop("cannot open '%s' for writing", path.c_str());
    }
    std::ostream& os = to_file ? static_cast<std::ostream&>(file)
                               : static_cast<std::ostream&>(mem);
    CC cc;
    if (by_cc) {
      xptr<CC> c(cc_xp);
      cc = *c;
    }
    using CI = CryptoContextImpl<DCRTPoly>;
    bool ok = with_sertype(binary, [&](const auto& st) -> bool {
      switch (which) {
        case 0: return by_cc ? CI::SerializeEvalMultKey(os, st, cc)
                             : CI::SerializeEvalMultKey(os, st, key_tag);
        case 1: return by_cc ? CI::SerializeEvalAutomorphismKey(os, st, cc)
                             : CI::SerializeEvalAutomorphismKey(os, st, key_tag);
        case 2: return by_cc ? CI::SerializeEvalSumKey(os, st, cc)
                             : CI::SerializeEvalSumKey(os, st, key_tag);
      }
      cpp11::stop("unknown key registry code %d", which);
    });
    if (to_file) {
      file.close();
      return cpp11::as_sexp(ok);
    }
    if (!ok) cpp11::stop("no keys were serialized");
    return bytes_to_r(mem.str(), binary);
  });
}

[[cpp11::register]]
bool DeserializeEvalKeysMem__(SEXP data, int which, bool binary) {
  return catch_openfhe("CryptoContext::DeserializeEval*Key", [&]() -> bool {
    std::istringstream is(bytes_from_r(data), std::ios::in | std::ios::binary);
    using CI = CryptoContextImpl<DCRTPoly>;
    return with_sertype(binary, [&](const auto& st) -> bool {
      switch (which) {
        case 0: return CI::DeserializeEvalMultKey(is, st);
        case 1: return CI::DeserializeEvalAutomorphismKey(is, st);
        case 2: return CI::DeserializeEvalSumKey(is, st);
      }
      cpp11::stop("unknown key registry code %d", which);
    });
  });
}

// ── Bootstrap keys ──────────────────────────────────────

[[cpp11::register]]
bool SerializeEvalBootstrapKey__(std::string filename, bool binary, SEXP cc_xp,
                                 std::string key_tag, int slots) {
  xptr<CC> cc(cc_xp);
  return catch_openfhe("CryptoContext::SerializeEvalBootstrapKey", [&]() -> bool {
    std::ofstream file(filename, std::ios::out | std::ios::binary);
    if (!file.is_open()) cpp11::stop("cannot open '%s' for writing", filename.c_str());
    bool ok = with_sertype(binary, [&](const auto& st) {
      return CryptoContextImpl<DCRTPoly>::SerializeEvalBootstrapKey(
          file, st, *cc, key_tag, static_cast<uint32_t>(slots));
    });
    file.close();
    return ok;
  });
}

// With a context: the indices bootstrapping needs for `slots`. Without:
// the indices given.
[[cpp11::register]]
bool DeserializeEvalBootstrapKey__(std::string filename, bool binary, SEXP cc_xp,
                                   std::string key_tag, int slots,
                                   integers index_list) {
  return catch_openfhe("CryptoContext::DeserializeEvalBootstrapKey", [&]() -> bool {
    std::ifstream file(filename, std::ios::in | std::ios::binary);
    if (!file.is_open()) cpp11::stop("cannot open '%s' for reading", filename.c_str());
    if (!Rf_isNull(cc_xp)) {
      xptr<CC> cc(cc_xp);
      return with_sertype(binary, [&](const auto& st) {
        return CryptoContextImpl<DCRTPoly>::DeserializeEvalBootstrapKey(
            file, st, *cc, key_tag, static_cast<uint32_t>(slots));
      });
    }
    std::vector<uint32_t> idx;
    idx.reserve(index_list.size());
    for (R_xlen_t i = 0; i < index_list.size(); ++i)
      idx.push_back(static_cast<uint32_t>(index_list[i]));
    return with_sertype(binary, [&](const auto& st) {
      return CryptoContextImpl<DCRTPoly>::DeserializeEvalBootstrapKey(
          file, st, key_tag, idx);
    });
  });
}
