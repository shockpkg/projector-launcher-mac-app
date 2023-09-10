#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

build='build'
arch='arm64'
sdk='/Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk'
out="${build}/main.${arch}"
mkdir -p "${build}"
clang \
	-Wl,-no_adhoc_codesign,-no_function_starts \
	-arch "${arch}" \
	-isysroot "${sdk}" \
	-framework Foundation \
	-I"${sdk}/usr/include" \
	-o "${out}" \
	'src/main.m'
strip -Sx "${out}"
