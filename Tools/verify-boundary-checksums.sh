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
    sed 's/\r$//' "$manifest" | sha256sum -c -
  else
    sed 's/\r$//' "$manifest" | shasum -a 256 -c -
  fi
done
