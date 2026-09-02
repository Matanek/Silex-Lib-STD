#!/usr/bin/env bash

set -euo pipefail

script_directory="$(cd "$(dirname "$0")" && pwd)"
repository_root="$(cd "$script_directory/.." && pwd)"
cd "$repository_root"

for manifest in \
  Boundary/Compression.SHA256SUMS.txt \
  Boundary/CryptoPrimitives.SHA256SUMS.txt \
  Boundary/NetworkRuntime.SHA256SUMS.txt \
  Boundary/TerminalSession.SHA256SUMS.txt
do
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum -c "$manifest"
  else
    shasum -a 256 -c "$manifest"
  fi
done
