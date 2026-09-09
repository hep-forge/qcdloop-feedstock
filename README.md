# qcdloop-feedstock

[![hep-forge](https://img.shields.io/badge/package-hep--forge%2Fqcdloop-orange.svg)](https://anaconda.org/hep-forge/qcdloop)
[![Build & Upload](https://github.com/hep-forge/qcdloop-feedstock/actions/workflows/autoupload.yml/badge.svg)](https://github.com/hep-forge/qcdloop-feedstock/actions/workflows/autoupload.yml)
[![Anaconda Version](https://anaconda.org/hep-forge/qcdloop/badges/version.svg)](https://anaconda.org/hep-forge/qcdloop)
[![Anaconda Platforms](https://anaconda.org/hep-forge/qcdloop/badges/platforms.svg)](https://anaconda.org/hep-forge/qcdloop)

Feedstock for [qcdloop](https://github.com/scarrazza/qcdloop) — part of [hep-forge](https://anaconda.org/hep-forge).
Builds in one matrix workflow and uploads to the
[hep-forge](https://anaconda.org/hep-forge) Anaconda channel.

Object-oriented one-loop scalar Feynman integrals framework

## Architectures

| Architecture | Latest published | Recipe support |
|--------------|------------------|----------------|
| linux-amd64 (`linux-64`) | ✅ `2.0.9` | ✅ |
| linux-arm64 (`linux-aarch64`) | ❌ not published yet | ✅ since the aarch64 shim (below) |

_As of the last feedstock render; the badges above are live._

### aarch64

aarch64 was skipped until recently. `src/qcdloop/types.h` hard-includes
`<quadmath.h>` for its extended-precision `qdouble` type, and conda-forge's
aarch64 GCC does not ship libquadmath.

That turned out not to need a rewrite. GCC builds libquadmath only where
`__float128` is a distinct type — x86, whose `long double` is the 80-bit x87
format. On aarch64 `long double` **is** IEEE 754 binary128 (16 bytes, 113-bit
mantissa), the identical format `__float128` provides, so the quad arithmetic
is already in libm under the `long double` names. Only GCC's `*q` spelling was
missing, and `recipe/quadmath-shim.h` supplies it. It is a naming shim, not an
emulation — precision is unchanged.

`recipe/patches/aarch64-portability.patch` covers the rest, and is inert on
x86:

* guards the two declarations qcdloop makes on `qdouble` that would otherwise
  collide with the existing `long double` ones, now that `__float128` is an
  alias rather than a distinct type
* makes `-march=nocona -mtune=haswell` conditional on x86 — a second, separate
  aarch64 blocker — and stops `CMakeLists.txt` overwriting `CMAKE_CXX_FLAGS`,
  which had been discarding flags passed in by conda-build

**Open item:** the aarch64 quad path has not yet been shown numerically
identical to real libquadmath. The shipped example tests take `double` inputs,
so they only constrain results to ~1e-16 rather than the ~1e-34 binary128
allows. Building both architectures in CI and diffing the example output would
close this.


## Install

```bash
conda install -c hep-forge -c conda-forge qcdloop
```

## Maintainers

* [@meiyasan](https://github.com/meiyasan/)

