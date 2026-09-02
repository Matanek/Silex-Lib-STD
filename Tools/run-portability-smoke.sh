#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <silex> <target> <temporary-directory>" >&2
  exit 2
fi

silex="$1"
target="$2"
temporary_directory="$3"
script_directory="$(cd "$(dirname "$0")" && pwd)"
repository_root="$(cd "$script_directory/.." && pwd)"
consumer="$repository_root/Fixtures/PortabilityConsumer"

mkdir -p "$temporary_directory"
"$silex" setup
"$silex" link "$repository_root" --workspace "$consumer" --target "$target"
"$silex" packages resolve "$consumer"

for source in \
  System.sx \
  Compression.sx \
  CryptoPrimitives.sx \
  NetworkSockets.sx \
  Threading.sx \
  Subprocess.sx \
  Process.sx
do
  "$silex" test "$repository_root/Tests/$source" --nocache
done

extension=""
case "$target" in
  windows-*) extension=".exe" ;;
esac
executable="$temporary_directory/std-portability$extension"
echo "Compiling the isolated consumer for $target"
"$silex" compile "$consumer/Main.sx" --target "$target" --release --nocache -o "$executable"
echo "Running the isolated consumer for $target"
output="$("$executable")"
if [ "$output" != "$target" ]; then
  echo "expected consumer target '$target', got '$output'" >&2
  exit 1
fi
