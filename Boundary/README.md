# STD native providers

STD owns reusable native primitives so application and domain packages can use
portable Silex APIs without handling Interop themselves.

`CryptoPrimitives` exposes a private C ABI backed by the Zig 0.16 standard
library. Its public Silex surface lives under `STD.Crypto.X25519`,
`STD.Crypto.HKDF` and `STD.Crypto.ChaCha20Poly1305`.

`TerminalSession` owns the system-specific PTY/ConPTY transport behind
`STD.Subprocess.spawn_terminal`. Its C ABI and native handles remain private.

Build the checked-in archives from the package root:

```text
zig build-lib Boundary/Source/CryptoPrimitives.zig -O ReleaseSmall -target aarch64-macos -femit-bin=Boundary/macos-arm64/libCryptoPrimitives.a
zig build-lib Boundary/Source/CryptoPrimitives.zig -O ReleaseSmall -target x86_64-linux -femit-bin=Boundary/linux-x64/libCryptoPrimitives.a
zig build-lib Boundary/Source/CryptoPrimitives.zig -O ReleaseSmall -target x86_64-windows -femit-bin=Boundary/windows-x64/CryptoPrimitives.lib
zig build-lib Boundary/Source/CryptoPrimitives.zig -O ReleaseSmall -target aarch64-windows -femit-bin=Boundary/windows-arm64/CryptoPrimitives.lib
```

Build the terminal transport with the same compiler:

```text
zig build-lib Boundary/Source/TerminalSession.zig -O ReleaseSmall -target aarch64-macos -femit-bin=Boundary/macos-arm64/libTerminalSession.a
zig build-lib Boundary/Source/TerminalSession.zig -O ReleaseSmall -target x86_64-linux -femit-bin=Boundary/linux-x64/libTerminalSession.a
zig build-lib Boundary/Source/TerminalSession.zig -O ReleaseSmall -target x86_64-windows -femit-bin=Boundary/windows-x64/TerminalSession.lib
zig build-lib Boundary/Source/TerminalSession.zig -O ReleaseSmall -target aarch64-windows -femit-bin=Boundary/windows-arm64/TerminalSession.lib
```

Verify them from the package root with:

```text
shasum -a 256 -c Boundary/CryptoPrimitives.SHA256SUMS.txt
shasum -a 256 -c Boundary/TerminalSession.SHA256SUMS.txt
```

After rebuilding an archive, regenerate its checksums, execute
`Tests/CryptoPrimitives.sx` on macOS and compile/link that test for every
distributed target. Because rebuilt native artifacts change product inputs,
the targeted Linux and Windows workflow must also be green before release.
