# STD native providers

STD owns reusable native primitives so application and domain packages can use
portable Silex APIs without handling Interop themselves.

`CryptoPrimitives` exposes a private C ABI backed by the Zig 0.16 standard
library. Its public Silex surface lives under `STD.Crypto.X25519`,
`STD.Crypto.HKDF` and `STD.Crypto.ChaCha20Poly1305`.

`TerminalSession` owns the system-specific PTY/ConPTY transport behind
`STD.Subprocess.spawn_terminal`. Its C ABI and native handles remain private.

The checked-in archives are built with Zig 0.16.0. The portability additions
for Intel macOS and ARM64 Linux are reproduced from the package root with:

```text
Tools/build-portability-archives.sh macos-x64
Tools/build-portability-archives.sh linux-arm64
```

The script builds `Compression`, `CryptoPrimitives`, `NetworkRuntime`, and
`TerminalSession` as relocatable x86_64 Mach-O or AArch64 ELF members. It uses
stable member names and strips C debug metadata so archive checksums do not
depend on a checkout or cache path. An optional second argument redirects the
target directory for a non-destructive comparison:

```text
Tools/build-portability-archives.sh macos-x64 /tmp/std-boundary/macos-x64
```

Verify them from the package root with:

```text
shasum -a 256 -c Boundary/Compression.SHA256SUMS.txt
shasum -a 256 -c Boundary/CryptoPrimitives.SHA256SUMS.txt
shasum -a 256 -c Boundary/NetworkRuntime.SHA256SUMS.txt
shasum -a 256 -c Boundary/TerminalSession.SHA256SUMS.txt
```

After rebuilding an archive, regenerate its checksums, execute
the native STD smoke set, and compile/link the package for all six targets.
Because rebuilt native artifacts change product inputs, every native
portability job must be green before release.
