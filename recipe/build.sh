#! /usr/bin/bash
set -e

# the tarball's macOS AppleDouble resource-fork entries (._QCDLoop-1.98 etc.)
# sit alongside the real QCDLoop-1.98/ dir, so conda-build's single-subdir
# auto-descend doesn't trigger -- cd into it explicitly
cd QCDLoop-1.98/ql
make FC="${FC}" FFLAGS="${FFLAGS} -std=legacy -Wall -ffixed-line-length-none"
cd ..

mv ql/libqcdloop.a "${PREFIX}/lib/"
mkdir -p "${PREFIX}/include/ql"
mv ql/*.mod "${PREFIX}/include/ql/"
