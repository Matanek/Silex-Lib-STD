# Silex standard library

This repository contains the default standard library installed with Silex.
It is versioned independently from the language and toolchain while keeping the
reserved `STD` module root:

```sx
use STD.Console
```

The repository root is the `STD` package root. `Package.json` declares the
package, `Module/` contains its portable Silex API and `Platform/` supplies the
system boundary selected by the compiler. Platform implementations remain
internal to STD; applications import capabilities such as `STD.File` or
`STD.Network.TCP`, never an operating-system module.

Within every `Module/` root, STD writes the complete logical module path in the
`.sx` filename. Dots make the source tree mirror `use` declarations directly:

```text
Module/Console.Session.sx                 -> use STD.Console.Session
Module/Network.TCP.sx                     -> use STD.Network.TCP
Platform/MacOS/Module/Network.TCP.sx
```

Portable sources and their selected platform or target implementations use the
same logical module name. For example, `Module/Randomizer.sx` and
`Platform/MacOS/Module/Randomizer.sx` compose `STD.Randomizer`; portable code
reaches the specialized helper explicitly as `Platform.system_seed()`.
`Platform` and `Target` require no import and map to the homonymous active
fragment.

The structural package directories (`Module`, `Platform`, platform names,
`Target`, target names, `Tests`, and `Tools`) remain hierarchical. This dotted
source layout is a convention of STD only; other Silex packages may represent
module segments with directories.

The current bootstrap composes `macos-arm64`, `linux-x64`, `windows-x64` and
`windows-arm64`. The macOS implementation is exercised natively; the other
targets are composition-checked until matching CI runners are available.

Programs can observe their selected compilation platform and architecture
without interop:

```sx
use STD.System

match System.platform() {
    macos => { print("macOS") }
    linux => { print("Linux") }
    windows => { print("Windows") }
}

let selected = System.target()
print(System.target_name(selected))
```

`System.platform()` describes the selected target, not the machine running the
compiler. Cross-compiling with `--target windows-x64` therefore produces
`windows` and `x64` in the resulting program.

Text files use UTF-8 without a byte-order mark or newline conversion. The text
helpers keep encoding details out of ordinary file operations:

```sx
use STD.File

try File.write_all(path, "Silex file IO\n")
let content = try File.read_text(path, 1024)
```

`File.read_all` and the byte-view overload of `File.write_all` remain available
for binary data.

Cryptographic hashes and system entropy are available through `STD.Crypto`:

```sx
use STD.Crypto

let checksum = Crypto.sha256("Silex")
let binary_digest:uint8[16] = Crypto.md5_bytes("Silex")
let token:uint8[] = Crypto.random_bytes(32)
```

`md5`, `sha1`, and `sha256` accept either a `str` or a borrowed byte view and
return lowercase hexadecimal text without a prefix. Their `_bytes`
counterparts return fixed-size binary digests. A string is hashed as its exact
UTF-8 byte sequence. MD5 and SHA-1 remain useful for compatible formats and
non-adversarial fingerprints, but their collision resistance is not suitable
when an attacker controls the input. None of these hashes is a
password-storage function.

`Crypto.random_bytes` reads system entropy directly. It never derives secrets
from the deterministic `STD.Randomizer` sequence.

UUID values use the same entropy source for their random portion:

```sx
use STD.UUID

let identifier = UUID()
print(identifier.to_str())
```

`UUID()` constructs a version 4 value by default.
`UUID(UUID.Version.v4())` and `UUID(UUID.Version.v7())` support a dynamic
version choice, while `UUID.v4()` and `UUID.v7()` are concise explicit
factories. Choose version 4 when the creation time must not be encoded. Version
7 embeds the current Unix timestamp in milliseconds before its random portion,
making identifiers time-sortable.
`UUID(bytes:uint8[16])` reconstructs an exact binary value, `to_bytes()`
returns a copy, and `to_str()` renders canonical lowercase text. UUID values
are identifiers, not authentication tokens.

Fallible filesystem, network, process and I/O capabilities share the
`STD.Error` contract. Its categories remain scoped under the error type:

```sx
use STD.Error

func retryable(kind:Error.Kind) bool {
    return match kind {
        interrupted => true
        would_block => true
        timed_out => true
        else => false
    }
}
```

`Tests/` groups each capability in one focused program. The workspace helper
rebuilds the compiler and runs every test natively without reusing compilation
cache entries:

```sh
./silex-dev test-std
```

The Silex sources are the primary API reference. Usage guides belong under
`Docs/` and explain developer intentions rather than duplicating every public
declaration.
