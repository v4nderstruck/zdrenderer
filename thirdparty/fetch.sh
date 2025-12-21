#!/bin/bash

set -e

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_ROOT}/source"
TARBALL_DIR="${SCRIPT_ROOT}/tarball"
INSTALL_DIR="${SCRIPT_ROOT}/install"

# ======== Helpers ========

function lazy_curl() {
    local url="$1"
    local outfile="$2"

    if [ -e "$outfile" ]; then
        echo "$outfile exists, skip!"
    else
        curl -L "$url" -o $outfile
    fi
}

function lazy_extract() {
    local tmp="$SOURCE_DIR/temp/"
    local source=$1
    local dest=$2

    if [ -d $dest ]; then
        echo "$dest exists, skip!"
    else
        rm -rf $dest $tmp
        mkdir -p $tmp
        tar -xzf $source -C $tmp
        mv "${tmp}"/*/ $dest
    fi
}

function lazy_cmake_build_install() {
    local source=$1
    local install=$2
    pushd $source
    cmake -S . -B build -DCMAKE_INSTALL_PREFIX=$install
    cmake --build build -j 8
    cmake --install build --prefix $install
    popd

}

# ======== Dependencies ========
SDL3_SRC="https://github.com/libsdl-org/SDL/releases/download/release-3.2.28/SDL3-3.2.28.tar.gz"
VMA_SRC="https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/refs/tags/v3.3.0.tar.gz"

# ======== SDL3 ========
echo "============ SDL 3 ============ "
TARBALL="$TARBALL_DIR/sdl3.tar.gz"
SOURCE="$SOURCE_DIR/sdl3"
lazy_curl $SDL3_SRC $TARBALL
lazy_extract $TARBALL $SOURCE
lazy_cmake_build_install $SOURCE $INSTALL_DIR

# ======== VMA ========
echo "============ VMA ============ "
TARBALL="$TARBALL_DIR/vma.tar.gz"
SOURCE="$SOURCE_DIR/vma"
lazy_curl $VMA_SRC $TARBALL
lazy_extract $TARBALL $SOURCE
lazy_cmake_build_install $SOURCE $INSTALL_DIR
