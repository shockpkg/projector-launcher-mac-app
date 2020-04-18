#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

archs=(
	'ppc'
	'ppc64'
	'ppc970'
	'i386'
	'x86_64'
)

cd 'build'
for arch in "${archs[@]}"; do
	shasum -a 256 "main.${arch}" > "main.${arch}.sha256"
done
