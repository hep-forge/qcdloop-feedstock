#! /usr/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# aarch64-portability.patch replaces what used to be an inline sed here.
#
# Upstream CMakeLists.txt:23 hardcodes `-march=nocona -mtune=haswell` (x86-only,
# rejected by aarch64 gcc) AND *overwrites* CMAKE_CXX_FLAGS rather than
# appending, which silently discards flags conda-build passes in. The old sed
# only removed the two tuning flags; the patch makes them conditional on x86
# and fixes the overwrite, so both architectures take the same code path.
#
# The patch also adds `#ifndef QUADMATH_SHIM_FLOAT128_IS_LONG_DOUBLE` guards
# around the two declarations qcdloop makes on its `qdouble` type. That macro
# is defined only by the aarch64 shim below, so on x86 every guard is inert and
# the source is equivalent to upstream. Verified: applying this patch and
# building WITHOUT the shim fails for exactly the original reason (no
# quadmath.h) and nothing else.
# ---------------------------------------------------------------------------
patch -p1 --fuzz=0 < "${RECIPE_DIR}/patches/aarch64-portability.patch"

if [ "$(uname -m)" != "x86_64" ]; then
    # GCC ships libquadmath only where __float128 is a distinct type, i.e. x86,
    # whose long double is the 80-bit x87 format. On aarch64 `long double` IS
    # IEEE 754 binary128 (16 bytes, 113-bit mantissa) -- the same format
    # __float128 provides -- so the arithmetic is already in libm under the
    # long double names. The shim supplies GCC's `*q` spelling on top of it.
    # This is a naming shim, not an emulation: precision is identical.
    mkdir -p "${SRC_DIR}/quadmath-shim"
    cp "${RECIPE_DIR}/quadmath-shim.h" "${SRC_DIR}/quadmath-shim/quadmath.h"
    export CXXFLAGS="${CXXFLAGS:-} -I${SRC_DIR}/quadmath-shim"
    export CFLAGS="${CFLAGS:-} -I${SRC_DIR}/quadmath-shim"
fi

mkdir build
cd build

# upstream 2.0.9 declares cmake_minimum_required < 3.5, which CMake 4 rejects
# ${CMAKE_ARGS} carries conda-build's own -DCMAKE_BUILD_TYPE=Release
# (plus toolchain/strip paths) -- omitting it leaves CMAKE_BUILD_TYPE
# unset (this project's own CMakeLists.txt never defaults it either),
# producing an unoptimized, unstripped debug-info binary.
cmake .. ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_POLICY_VERSION_MINIMUM=3.5

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install
