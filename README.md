# Silex standard library

This repository contains the default standard library installed with Silex.
It is versioned independently from the language and toolchain while keeping the
reserved `STD` module root:

```sx
use STD.Console
```

Start with [Docs/README.md](Docs/README.md) to choose a capability, then use the
focused [documentation recipes](Docs/Recipes/README.md) as complete starting
points. Recipes are organized by application intent rather than by platform
implementation details.

The repository root is the `STD` package root. `Package.json` declares the
package, `Module/` contains its portable Silex API and `Platform/` supplies the
system boundary selected by the compiler. Helpers shared only by fragments of
one logical module are module-visible; collaboration between distinct STD
modules is explicitly package-visible. Neither category belongs to the public
API: applications import capabilities such as `STD.File` or `STD.Network.TCP`,
never an operating-system module.

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

`STD.Math` provides IEEE 754 scalar operations in both language precisions and
shared geometric values:

```sx
use STD.Math

let integral = Math.floor(12.75)
let size = Math.Vec2(1280.4, 720.8).round()
let viewport = Math.Rect(Math.Vec2(), size)
```

Scalar functions preserve the concrete type of a `float32` or `float64`
operand. Constants default to `float` and accept an explicit precision when it
matters:

```sx
let ordinary = Math.pi()
let precise:float64 = Math.pi<float64>()
let root:float64 = Math.sqrt(2.0 as float64)
```

`is_nan`, `is_infinite`, `is_finite`, `is_normal` and `sign_bit` expose the
portable classification of special values. Invalid real domains return NaN,
overflow returns signed infinity, representable subnormals are preserved and
signed zeros remain observable. `min` and `max` select the numeric operand when
only one operand is NaN and select respectively negative and positive zero.
`clamp` returns NaN for a NaN bound or an inverted interval.

`epsilon()` remains the historical application tolerance `1e-6`; it is not a
universal domain threshold. `machine_epsilon<T>()` exposes the spacing after
one for advanced numeric code.

`nearly_equal(left, right)` combines a small absolute tolerance with a relative
tolerance scaled to the operands. The three-argument form keeps its historical
absolute-only meaning, while the four-argument form accepts explicit absolute
and relative tolerances. `Vec2`, `Vec3` and `Vec4` apply the same rules to every
component. A domain-specific tolerance remains an application decision and
should not be replaced by `epsilon()` or machine epsilon.

`Vec2.normalized()`, `Vec3.normalized()` and `Vec4.normalized()` are total: an
exactly zero vector stays zero, while every finite non-zero vector is scaled to
unit length without treating a small magnitude as absent. `Quat.normalized()`
uses the same scale-stable calculation and maps only the exactly zero
quaternion to identity. Their value-returning signatures remain suitable for
composable graphics code.

`floor`, `ceil`, `round` and `trunc` preserve their operand precision. The same
component-wise operations are available on `Vec2`, `Vec3` and `Vec4`.

The scalar vocabulary also includes `sign`, `copy_sign`, `fraction`,
`round_even`, `modulo`, `remainder`, `cbrt` and scale-stable `hypot`.
`round` moves halfway cases away from zero, whereas `round_even` chooses the
even integer. `remainder` uses a quotient truncated toward zero and keeps the
dividend sign; `modulo` uses a quotient rounded toward negative infinity and
keeps the modulus sign. A zero divisor returns NaN. The constants `e`,
`sqrt_two` and `ln_two` follow the same default/explicit precision model as
`pi`.

Exponentials (`exp`, `exp2`), logarithms (`log`, `log2`, `log10`), real `pow`,
trigonometry and inverse trigonometry, and the six direct/inverse hyperbolic
functions live directly under `STD.Math`. Angles use radians; `radians` and
`degrees` make degree conversion explicit. `log` is natural logarithm,
`log(0)` is negative infinity, and negative inputs return NaN. A negative base
to a finite non-integral power also returns NaN. `atan2(y, x)` preserves
quadrants, signed zeros and infinities. `acosh` accepts values from one upward;
`atanh` accepts `[-1, 1]`, returning signed infinity at its endpoints.

`lerp` and its shader-vocabulary alias `mix` extrapolate when `amount` leaves
`[0, 1]`; `lerp_clamped` states the bounded intention explicitly.
`inverse_lerp` returns an unbounded position, and `remap` carries that position
to another interval without hidden clamping. Degenerate source intervals return
NaN. `step` implements an inclusive threshold, while `smooth_step` clamps its
position before applying the cubic transition. Reversed smooth-step edges form
a descending transition.
`Rect` stores `x`, `y`, `w` and `h`, exposes position, size, bounds and center,
and supports containment, intersection, translation and scaling.
The complete right-handed coordinate, column-vector, projection-depth and
semi-open rectangle contract is documented in [Docs/Math.md](Docs/Math.md).

Associative and ordered collections expose one consistent traversal model:

```sx
use STD.Collections.Dictionary

var scores = Dictionary<str, int>()
scores.set("Ada", 12)
scores.set("Linus", 9)

var entries = scores.iterator()
while entry = entries.next() {
    print("$(entry.key): $(entry.value)")
}
```

`Dictionary`, `Set`, `Queue` and `Stack`, their traversal order, snapshot
operations and iteration algorithms are documented in
[Docs/Collections.md](Docs/Collections.md). Focused walkthroughs live under
[Docs/Recipes/Collections](Docs/Recipes/Collections/).

CPU jobs use the persistent executor exposed by `STD.Threading`:

```sx
use STD.Threading

var executor = Threading.Executor(worker_count:1)
var handle = executor.submit(MyJob())
let completed = handle.complete()
```

Les phases se composent avec des fences sans occuper un worker pour attendre :

```sx
var prepare = executor.submit(PrepareJob(), after:handle.fence())
prepare.fence().complete()
```

Un traitement homogène se soumet comme un lot de plages indexées, avec une
seule fence collective :

```sx
var done = executor.submit_parallel(values.count(), Transform(values:values))
done.complete()
```

The typed result, lifetime, synchronization and shutdown guarantees are
documented in [Docs/Threading.md](Docs/Threading.md).

Text files use UTF-8 without a byte-order mark or newline conversion. The text
helpers keep encoding details out of ordinary file operations:

```sx
use STD.File

try File.write_all(path, "Silex file IO\n")
let content = try File.read_text(path, 1024)
```

`File.read_all` and the byte-view overload of `File.write_all` remain available
for binary data.

Common immutable string operations live under `STD.Text`:

```sx
use STD.Text

let clean = Text.trim("  Silex language  ")
if Text.contains(clean, "Silex") {
    print(Text.replace(clean, "language", "program"))
}

let title = Text.titlecase("a practical SILEX application")
let words = Text.split(title, " ")
print(Text.join(words, " · "))
```

`trim`, `trim_start`, and `trim_end` recognize Unicode whitespace.
`contains`, `starts_with`, `ends_with`, and `replace` compare exact Unicode
scalar sequences and remain case-sensitive. `replace` processes every
non-overlapping occurrence from left to right; an empty search leaves the text
unchanged. `index_of` returns `int?` and measures its result in Unicode scalar
positions, consistently with the language's `str.count()`.
`slice` uses the same scalar indexes and an invalid range is a programming
error. `split` preserves empty parts; an empty separator keeps the original
text as one part. `join` accepts an empty collection and returns an empty
string.

`titlecase` is Unicode-aware and locale-independent. It uppercases the first
cased character of each word and lowercases the remaining cased characters.
Case-ignorable characters such as combining marks and apostrophes remain in
the current word; other uncased characters start a new word.

Bounded decompression lives under `STD.Compression` for raw deflate, gzip and
zlib streams. The output limit is mandatory in the execution contract and
prevents malformed or highly compressible input from growing without bound.
See [Docs/Compression.md](Docs/Compression.md).

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
`UUID(UUID.Version.v4)` and `UUID(UUID.Version.v7)` support a dynamic
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

`Tests/` groups each capability in one focused executable proof. The workspace
helper rebuilds the compiler and runs every test natively without reusing
compilation cache entries:

```sh
./silex-dev test-std
```

The Silex sources are the primary API reference. Usage guides belong under
`Docs/` and explain developer intentions rather than duplicating every public
declaration.

## License

Silex STD is licensed under the Apache License 2.0 with LLVM Exceptions
(`Apache-2.0 WITH LLVM-exception`). See [LICENSE](LICENSE) and [NOTICE](NOTICE).

Applications using STD may be distributed under the license of their authors'
choice. Unicode-derived data remains subject to the terms listed in
[Licenses/README.md](Licenses/README.md).
