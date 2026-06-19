#!/bin/bash
#
# build_openfhe.sh — Build OpenFHE static libraries from vendored source
#
# Called by configure during R CMD INSTALL.
# Produces: src/openfhelib/ with include/ and lib/ subdirectories.

#
# Detect tools
#
if test -z "${MAKE}"; then MAKE=`which make 2>/dev/null`; fi
if test -z "${MAKE}"; then MAKE=`which /Applications/Xcode.app/Contents/Developer/usr/bin/make 2>/dev/null`; fi

if test -z "${CMAKE_EXE}"; then CMAKE_EXE=`which cmake4 2>/dev/null`; fi
if test -z "${CMAKE_EXE}"; then CMAKE_EXE=`which cmake3 2>/dev/null`; fi
if test -z "${CMAKE_EXE}"; then CMAKE_EXE=`which cmake 2>/dev/null`; fi
if test -z "${CMAKE_EXE}"; then CMAKE_EXE=`which /Applications/CMake.app/Contents/bin/cmake 2>/dev/null`; fi

if test -z "${CMAKE_EXE}"; then
    echo "Could not find 'cmake'!"
    exit 1
fi

: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
    echo "'R_HOME' could not be found!"
    exit 1
fi

#
# Get compiler settings from R.
#
# Per Writing R Extensions §1.2.4, a package that sets CXX_STD = CXX17 (as
# openfhe does) should use the CXX17* configuration variables rather than
# the default CXX* ones when compiling sub-libraries, so the static OpenFHE
# archives are built with the same toolchain and flags the R package layer
# will use.
#
# Per §1.2.1.1, OpenMP linkage is conveyed by SHLIB_OPENMP_CXXFLAGS (R will
# return an empty string on platforms without OpenMP support). We feed that
# flag into the CMake compile/link lines so the static archives match the
# final DLL's OpenMP ABI, instead of hardcoding -lgomp (explicitly forbidden
# in §1.6.4).
#
CFLAGS=`"${R_HOME}/bin/R" CMD config CFLAGS`
LDFLAGS=`"${R_HOME}/bin/R" CMD config LDFLAGS`

CXX17=`"${R_HOME}/bin/R" CMD config CXX17`
CXX17STD=`"${R_HOME}/bin/R" CMD config CXX17STD`
CXX17FLAGS=`"${R_HOME}/bin/R" CMD config CXX17FLAGS`
CXX17PICFLAGS=`"${R_HOME}/bin/R" CMD config CXX17PICFLAGS`

# OpenMP flag. Preferred source is OPENFHE_OMP_CXXFLAGS exported by the
# parent configure script (which ran the full three-strategy detection).
# If this script is run standalone (no configure), fall back to whatever
# R's Makeconf advertises — empty is a valid answer.
#
# Note: some R builds (notably rtools45 on Windows, and macOS CRAN R)
# omit SHLIB_OPENMP_CXXFLAGS from `R CMD config`'s whitelist. Those
# configurations print "ERROR: no information for variable ..." to
# stdout and exit 1. Use exit status, not the captured text, to decide.
if [ -z "${OPENFHE_OMP_CXXFLAGS+x}" ]; then
    if _omp=`"${R_HOME}/bin/R" CMD config SHLIB_OPENMP_CXXFLAGS 2>/dev/null`; then
        OPENFHE_OMP_CXXFLAGS="${_omp}"
    else
        OPENFHE_OMP_CXXFLAGS=""
    fi
fi

export CC=`"${R_HOME}/bin/R" CMD config CC`
export CXX="${CXX17} ${CXX17STD}"
export CFLAGS
# -DOPENFHE_R_BUILD switches OpenFHE's logging path (see
# src/core/include/utils/openfhe_log.h on the r_pkg branch) from
# std::cerr / std::cout to REprintf / Rprintf. Required so the
# compiled static archives contain NO stdout/stderr symbols,
# per R CMD check's "checking compiled code" rule (Writing R
# Extensions §1.1.3.1 step 16).
R_INCLUDE=`"${R_HOME}/bin/R" CMD config --cppflags`
export CXXFLAGS="${CXX17FLAGS} ${CXX17PICFLAGS} ${OPENFHE_OMP_CXXFLAGS} -DOPENFHE_R_BUILD ${R_INCLUDE}"
export LDFLAGS

R_OPENFHE_PKG_HOME=`pwd`
OPENFHE_SRC_DIR=${R_OPENFHE_PKG_HOME}/inst/openfhe
OPENFHE_INSTALL_DIR=${R_OPENFHE_PKG_HOME}/src/openfhelib

echo ""
echo "CMAKE VERSION: '`${CMAKE_EXE} --version | head -n 1`'"
echo "CC:       '${CC}'"
echo "CXX:      '${CXX}'"
echo "CFLAGS:   '${CFLAGS}'"
echo "CXXFLAGS: '${CXXFLAGS}'"
echo "LDFLAGS:  '${LDFLAGS}'"
echo "OPENFHE_OMP_CXXFLAGS:  '${OPENFHE_OMP_CXXFLAGS}'"
echo ""

#
# Detect ccache for faster rebuilds
#
CCACHE_OPTS=""
CCACHE_EXE=`which ccache 2>/dev/null`
if test -n "${CCACHE_EXE}"; then
    CCACHE_OPTS="-DCMAKE_C_COMPILER_LAUNCHER=${CCACHE_EXE} -DCMAKE_CXX_COMPILER_LAUNCHER=${CCACHE_EXE}"
    echo "Found ccache: ${CCACHE_EXE}"
fi

#
# Common CMake options
#
COMMON_CMAKE_OPTS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_POSITION_INDEPENDENT_CODE:bool=ON
    -DBUILD_SHARED:bool=OFF
    -DBUILD_STATIC:bool=ON
    -DBUILD_UNITTESTS:bool=OFF
    -DBUILD_EXAMPLES:bool=OFF
    -DBUILD_BENCHMARKS:bool=OFF
    -DGIT_SUBMOD_AUTO:bool=OFF
    -DCMAKE_INSTALL_PREFIX=${OPENFHE_INSTALL_DIR}
    ${CCACHE_OPTS}
"

# Platform-specific flags
if test "$(uname -s)" = "Darwin"; then
    CMAKE_PLATFORM_OPTS="-DCMAKE_HOST_APPLE:bool=ON"

    # OPENMP_LIB_DIR / OPENMP_INC_DIR are set by the parent configure's
    # unified OpenMP detection (R-first, Homebrew-last, single-source).
    # The r_pkg-branch patch in CMakeLists.txt uses OPENMP_LIBRARIES and
    # OPENMP_INCLUDES to override the default Homebrew/MacPorts guess.
    if test -n "${OPENMP_LIB_DIR}" && test -n "${OPENMP_INC_DIR}"; then
        echo "Using externally specified OpenMP: lib=${OPENMP_LIB_DIR} inc=${OPENMP_INC_DIR}"
        CMAKE_PLATFORM_OPTS="${CMAKE_PLATFORM_OPTS} -DOPENMP_LIBRARIES=${OPENMP_LIB_DIR} -DOPENMP_INCLUDES=${OPENMP_INC_DIR}"
    else
        # No single-source OpenMP available. Turn OpenFHE's OpenMP off
        # rather than let upstream's CMake auto-detection fall back to
        # /opt/homebrew/opt/libomp, which would be a different libomp
        # than the one the R `.so` links (crash class: two libomps in
        # one R process).
        echo "No OpenMP source agreed upon; building OpenFHE with WITH_OPENMP=OFF"
        CMAKE_PLATFORM_OPTS="${CMAKE_PLATFORM_OPTS} -DWITH_OPENMP:bool=OFF"
    fi
else
    CMAKE_PLATFORM_OPTS="-G \"Unix Makefiles\""

    # MinGW-w64 GCC on Windows supports __int128 at real compile time,
    # but CMake's check_type_size("__int128" INT128) fails under
    # rtools45's strict CFLAGS ('-pedantic -Wstrict-prototypes -O2
    # -Wall -std=gnu2x ...') — winbuilder logs "Check size of __int128
    # - failed". Without HAVE_INT128, the 64-bit native backend falls
    # through to MAX_MODULUS_SIZE=57 (basicint.h:l.54), capping CKKS
    # first_mod_size / scaling_mod_size at 57 bits. That breaks every
    # default CKKS context (first_mod_size defaults to 60). Pre-seed
    # the cache variables so check_type_size is skipped and config_core.h
    # gets HAVE_INT128 defined.
    if test -n "${MSYSTEM}" || test "${OS}" = "Windows_NT" \
            || test "$(uname -o 2>/dev/null)" = "Msys" \
            || test "$(uname -s 2>/dev/null)" = "MINGW64_NT" ; then
        CMAKE_PLATFORM_OPTS="${CMAKE_PLATFORM_OPTS} -DHAVE_INT128:BOOL=TRUE -DINT128:INTERNAL=16"
    fi
fi

# ========================================================
# Build OpenFHE (static libraries)
# ========================================================
echo ">>> Building OpenFHE..."
OPENFHE_BUILD_DIR=${OPENFHE_SRC_DIR}/build
mkdir -p ${OPENFHE_BUILD_DIR}
mkdir -p ${OPENFHE_INSTALL_DIR}/lib
mkdir -p ${OPENFHE_INSTALL_DIR}/include
cd ${OPENFHE_BUILD_DIR}

eval ${CMAKE_EXE} .. ${COMMON_CMAKE_OPTS} ${CMAKE_PLATFORM_OPTS} || exit 1

# Normalise line endings on CMake-generated Makefiles when running
# under MSYS/MinGW/rtools on Windows. Without this, R CMD check's
# "checking line endings in Makefiles" step flags them as WARNING
# (Writing R Extensions §1.1.3.1 step 16), which the CI workflow's
# error-on: "warning" setting treats as a build failure. No-op on
# macOS/Linux where ${OSTYPE}/${MSYSTEM} are empty.
if test -n "${MSYSTEM}" || test "${OS}" = "Windows_NT" \
        || test "$(uname -o 2>/dev/null)" = "Msys" \
        || test "$(uname -s 2>/dev/null)" = "MINGW64_NT" ; then
    echo "* Normalising CMake-generated Makefile line endings to LF (Windows build)"
    find ${OPENFHE_BUILD_DIR} -name 'Makefile' -type f \
        -exec sh -c 'for f in "$@"; do tr -d "\r" < "$f" > "$f.lf" && mv "$f.lf" "$f"; done' _ {} + \
        2>/dev/null || true
fi

# Build static library targets
${MAKE} OPENFHEcore_static OPENFHEpke_static OPENFHEbinfhe_static || exit 1

echo ">>> OpenFHE built in ${OPENFHE_BUILD_DIR}"

# ========================================================
# Manual install: copy static libs + headers
# ========================================================

# Static libraries (OpenFHE names them *_static.a)
for lib in libOPENFHEcore_static.a libOPENFHEpke_static.a libOPENFHEbinfhe_static.a; do
    found=$(find ${OPENFHE_BUILD_DIR} -name "$lib" -print -quit 2>/dev/null)
    if test -n "$found"; then
        destname=$(echo "$lib" | sed 's/_static//')
        cp "$found" ${OPENFHE_INSTALL_DIR}/lib/${destname}
    else
        echo "ERROR: $lib not found in build directory!"
        exit 1
    fi
done

# Headers: copy from source tree preserving the openfhe/ prefix structure
# that our R bindings expect (e.g. #include "openfhe.h" resolves via -I.../openfhe/pke)
INCDIR=${OPENFHE_INSTALL_DIR}/include/openfhe

for component in core pke binfhe; do
    src_inc=${OPENFHE_SRC_DIR}/src/${component}/include
    if test -d "${src_inc}"; then
        mkdir -p ${INCDIR}/${component}
        cp -R ${src_inc}/* ${INCDIR}/${component}/
    fi
done

# Cereal headers (header-only serialization library)
# cmake install does: install(DIRECTORY cereal/include/ DESTINATION include/openfhe)
# which copies the *contents* of include/ — giving include/openfhe/cereal/cereal.hpp
cp -R ${OPENFHE_SRC_DIR}/cereal/include/* ${INCDIR}/

# CMake-generated config_core.h
GENERATED_CONFIG=$(find ${OPENFHE_BUILD_DIR} -name "config_core.h" -print -quit 2>/dev/null)
if test -n "${GENERATED_CONFIG}"; then
    cp "${GENERATED_CONFIG}" ${INCDIR}/core/
else
    echo "ERROR: config_core.h not found in build directory!"
    exit 1
fi

echo ">>> OpenFHE installed to ${OPENFHE_INSTALL_DIR}"

cd ${R_OPENFHE_PKG_HOME}
