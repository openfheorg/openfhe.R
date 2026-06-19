// R-SPECIFIC: minimal header for OpenFHE + cpp11
//
// Uses cpp11::external_pointer<T> directly. No custom helpers needed.
// For shared_ptr types: external_pointer<shared_ptr<T>> stores
// a heap-allocated shared_ptr. The default deleter calls delete on it,
// which decrements the refcount.
#pragma once

#include <cpp11.hpp>
#include <cpp11/external_pointer.hpp>
#include <memory>

#include "openfhe.h"

using namespace lbcrypto;
