# Public API coverage

This matrix defines what “STD is covered” means for production use:

1. every intended public module has a task-oriented guide;
2. every public operation is called by an executable test or compiled consumer
   example;
3. every structural workflow is completed across its real consumer boundary;
4. interactive and server-waiting paths are compiled, even when automation
   cannot safely drive their environment.

Members inherit the visibility of their type unless they state a narrower
exception. Protocol implementations carried by package-visible types therefore
remain implementation details and are excluded from the consumer surface.
Digest engines under `Crypto.MD5`, `Crypto.SHA1` and `Crypto.SHA256` are
package-visible; consumers use `STD.Crypto`.

| Public surface | Operations covered | Consumer examples | Executable proof |
| --- | --- | --- | --- |
| `Algorithms.Iteration`, `Algorithms.Sort`, `Algorithms.Random`, `Iterator` | iterator construction and exhaustion; any, all, count, find, contains, map, filter; explicit and inferred nested generic entry specialization; sort, choose, shuffle | `AnalyzeValues`, `CountPassingEntries`, `SortLeaderboard`, `ShufflePlaylist` | `Tests/Algorithms.sx`, `Tests/NestedGenericIteration.sx` |
| `Collections.Dictionary`, `Set`, `Queue`, `Stack`, `Hashing` | all constructors; count, capacity, reserve, clear, containment, mutation, lookup, removal and complete iteration; dictionary key/value snapshots; built-in and custom hashing/equality | all programs under `Examples/Collections` | `Tests/Collections.sx` |
| `Console`, `Console.Session` | standard/error output, flush, TTY detection, dimensions, colors, styles, cursor/screen control, line input, Enter wait, blocking and timed key input, bounded draining, alternate screen and restoration | all programs under `Examples/Console` | `Tests/Console.sx`; interactive examples compile at the consumer boundary |
| `Crypto` | secure random bytes; MD5, SHA-1 and SHA-256 for text and bytes; hexadecimal and byte digests | `ContentFingerprint`, `HashFile` | `Tests/Crypto.sx` |
| `Error`, `Result` | structured kind, operation, subject and detail; success/failure propagation and matching | fallible examples in every system-facing domain | all fallible module tests; `Tests/IO.sx` checks public protocol composition |
| `Path` | validate, normalize, join, parent, name, stem, extension and absolute detection | `InspectPath` | `Tests/Path.sx` |
| `File` | every access, creation and seek mode; open/close, read/write/flush, position, length, resize, complete text and byte IO with limits | all programs under `Examples/Files` | `Tests/File.sx`, `Tests/IO.sx` |
| `IO` | `Reader`, `Writer`, exact read, bounded read-to-end, complete write and bounded copy | `ReadBinaryHeader`, `ReadBoundedStream`, `WriteCompleteStream`, `CopyStream` | `Tests/IO.sx` |
| `FileSystem` | followed/direct metadata, canonicalization, list, single/recursive directory creation, file/directory removal, rename, copy and readonly state | `OrganizeWorkspace`, `InspectFileMetadata`, `PublishReport` | `Tests/FileSystem.sx` |
| `Regex` | structured compilation; cached `Presets` for digits, email, IPv4 and IPv6; intention-based `contains`, `first`, lazy `find`, whole-text `match` and eager `all`; leftmost-first matching; Unicode properties, word boundaries and scalar ranges; greedy/lazy quantifiers; numbered/named/noncapturing groups; case, multiline and dot-all options; split and literal/callback replacement; empty-match progress; large streaming input and compact finite bounds | `ExtractContacts`, `NormalizeLog`, `UsePresets` | `Tests/Regex.sx`, `Benchmarks/Regex.sx` |
| `Text` | normalization and detection, casing, search, trimming, replacement, scalar slicing, split/join and title case | `CleanNames`, `CompareUnicode` | `Tests/Text.sx` |
| `Text.UTF8`, `Text.Grapheme`, `Text.Encoding` | byte/scalar conversion and failures; grapheme boundaries/count/split; every UTF encoding, BOM mode and structured decoding error | `Utf8RoundTrip`, `CountGraphemes`, `DecodeDocument` | `Tests/Text.sx`, `Tests/Grapheme.sx`, `Tests/Encoding.sx` |
| `Math` and its nominal types | every scalar overload and constant; vectors, rectangles, quaternions and matrices including every direct method and graphics convention | `ViewportLayout` | `Tests/Math.sx`; exhaustive contract in `Docs/Math.md` |
| `Network`, `Network.TCP`, `Network.UDP` | IP parse/format, endpoint format, resolve; both TCP connect forms, listen/accept, endpoints, stream IO, half-close and close; UDP open/bind/endpoints/send/receive/close | all programs under `Examples/Network` | `Tests/Network.sx`, `Tests/NetworkSockets.sx` |
| `Process`, `Subprocess`, `System` | arguments, pid, current directory mutation, executable path; command environment/input/output/status and limits; platform, architecture and target naming | all programs under `Examples/Process`, `Examples/Subprocess`, `Examples/System` | `Tests/Process.sx`, `Tests/Subprocess.sx`, `Tests/System.sx` |
| `Randomizer` | system and deterministic seeds; unbounded/ranged integer, unit/ranged float and boolean generation | `RollDice`, `ShufflePlaylist` | `Tests/Randomizer.sx`, `Tests/Algorithms.sx` |
| `Threading` | executor constructors, typed completion, fences, completion observation, single/multiple dependencies, combine, parallel ranges, delayed parallel work and idle wait | all programs under `Examples/Threading` | `Tests/Threading.sx`, `Tests/ThreadingParallelOnly.sx` |
| `Time.Clock`, `Time.Stopwatch` | start/stop/reset/restart, running state and elapsed units; tick/reset/pause/resume, scale and totals | `MeasureOperation`, `ScaledClock` | `Tests/Time.sx` |
| `UUID` | default/configured/static v4 and v7 construction, byte construction, byte extraction and canonical text | `CreateIdentifiers` | `Tests/UUID.sx` |

Run the complete verification from the workspace root:

```sh
./silex-dev test-std
```

This runs the STD test suite and compiles every consumer example. Network
loopback execution may require a sandbox that permits local sockets; the
example catalogue states which programs require a terminal, listener or name
resolution.
