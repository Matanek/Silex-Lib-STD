#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "usage: $0 <macos-x64|linux-arm64> [output-directory]" >&2
  exit 2
fi

target="$1"
case "$target" in
  macos-x64)
    zig_target="x86_64-macos"
    ;;
  linux-arm64)
    zig_target="aarch64-linux"
    ;;
  *)
    echo "unsupported portability target: $target" >&2
    exit 2
    ;;
esac

script_directory="$(cd "$(dirname "$0")" && pwd)"
repository_root="$(cd "$script_directory/.." && pwd)"
output_directory="${2:-$repository_root/Boundary/$target}"
temporary_directory="$(mktemp -d)"
trap 'rm -rf "$temporary_directory"' EXIT

if [ "$(zig version)" != "0.16.0" ]; then
  echo "Zig 0.16.0 is required to reproduce STD boundary archives" >&2
  exit 1
fi

mkdir -p "$output_directory"

for provider in Compression CryptoPrimitives TerminalSession; do
  zig build-obj "$repository_root/Boundary/Source/$provider.zig" \
    -O ReleaseSmall \
    -target "$zig_target" \
    -femit-bin="$temporary_directory/$provider.o"
  (
    cd "$temporary_directory"
    zig ar rcs "lib$provider.a" "$provider.o"
  )
  mv "$temporary_directory/lib$provider.a" "$output_directory/lib$provider.a"
done

zig cc -target "$zig_target" -O2 -g0 \
  -c "$repository_root/Boundary/Source/NetworkRuntimePosix.c" \
  -o "$temporary_directory/NetworkRuntime.o"
(
  cd "$temporary_directory"
  zig ar rcs libNetworkRuntime.a NetworkRuntime.o
)
mv "$temporary_directory/libNetworkRuntime.a" "$output_directory/libNetworkRuntime.a"
