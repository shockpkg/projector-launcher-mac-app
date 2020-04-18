#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

build='build'
archs=(
	'ppc'
	'ppc64'
	'ppc970'
	'i386'
	'x86_64'
)
sdk='/Developer/SDKs/MacOSX10.5.sdk'

rm -rf "${build}"
mkdir -p "${build}"

for arch in "${archs[@]}"; do
	out="${build}/main.${arch}"
	gcc \
		-arch "${arch}" \
		-isysroot "${sdk}" \
		-framework Foundation \
		-I"${sdk}/usr/include" \
		-o "${out}" \
		'src/main.m'
	strip -Sx "${out}"
done
