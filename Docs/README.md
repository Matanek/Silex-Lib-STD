# Using STD

STD is organized by developer intention. Start with the guide for the task at
hand, then open its focused [recipes](Recipes/README.md). Executable proofs of
the public contract belong under `Tests/`; recipes illustrate usage without
becoming a second validation catalogue.

The [public API coverage matrix](Coverage.md) records the executable proof for
every intended public module. It distinguishes consumer API from public
protocol contracts implemented by package-visible types.

| Intention | Modules | Guide |
| --- | --- | --- |
| Build a terminal application | `Console`, `Console.Session` | [Console](Console.md) |
| Store, traverse and transform values | `Collections.*`, `Iterator`, `Algorithms.*` | [Collections](Collections.md), [Algorithms](Algorithms.md) |
| Search and capture structured text | `Regex` | [Regular expressions](Regex.md) |
| Work with paths, files and directories | `Path`, `File`, `FileSystem`, `FileWatch`, `IO` | [Files and paths](Files.md) |
| Normalize, segment and encode Unicode text | `Text`, `Text.UTF8`, `Text.Grapheme`, `Text.Encoding` | [Text](Text.md) |
| Decompress bounded deflate payloads | `Compression` | [Compression](Compression.md) |
| Resolve names and exchange network data securely | `Network`, `Network.TCP`, `Network.UDP`, `Network.TLS` | [Network](Network.md) |
| Inspect or launch processes | `Process`, `Subprocess`, `System` | [Processes and targets](Processes.md) |
| Schedule CPU work | `Threading` | [Threading](Threading.md) |
| Measure and scale time | `Time.Clock`, `Time.Stopwatch` | [Time](Time.md) |
| Calculate scalar and graphics values | `Math` | [Math](Math.md) |
| Generate random values or reorder data | `Randomizer`, `Algorithms.Random` | [Randomness](Randomness.md) |
| Hash data, derive keys, encrypt authenticated bytes or create identifiers | `Crypto`, `Crypto.X25519`, `Crypto.HKDF`, `Crypto.ChaCha20Poly1305`, `UUID` | [Crypto and identifiers](Crypto-and-identifiers.md) |
| Handle fallible system operations | `Error`, `Result` | [Errors](Errors.md) |

The API source remains the exhaustive declaration reference. These guides
define the observable usage contracts: ownership, errors, limits, ordering,
platform behavior and the next operation a developer normally performs.
