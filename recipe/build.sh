#! /usr/bin/bash

# upstream CMakeLists.txt:23 hardcodes x86 tuning flags that aarch64
# gcc rejects
if [ "$(uname -m)" != "x86_64" ]; then
    sed -i 's/-march=nocona //g; s/-mtune=haswell //g' CMakeLists.txt
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
