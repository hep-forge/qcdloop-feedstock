#! /usr/bin/bash

mkdir build
cd build

# upstream 2.0.9 declares cmake_minimum_required < 3.5, which CMake 4 rejects
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_POLICY_VERSION_MINIMUM=3.5

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install
