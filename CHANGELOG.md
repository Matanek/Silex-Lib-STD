# Changelog

## [0.23.0] - 2026-11-08

- File reads and writes use bounded native blocks instead of one system call per byte, preserving signatures, EOF, partial reads and errors.

- Writes to closed child stdin return `broken_pipe` without fatal SIGPIPE or a leaked handle. `Child.terminate(force:true)` can stop a blocked subprocess; its writer may remain on a worker while the owner drains events.

- Compute string hashes with fixed arithmetic work per UTF-8 byte, preserving
  the existing portable 64-bit FNV-1a values, including embedded zero bytes.

- `Dictionary.get_keys()` and `get_values()` snapshots preserve shared class
  identities, including `nocopy` resources, while keeping independent list storage.

- Adopts one `Result` declaration: an ordinary call returns the value or
  stops the program on failure; `try call()` keeps the `Result`. Existing calls
  storing results and propagating failures are made explicit. This version
  requires Silex 0.48.0 or newer and the coordinated dependency versions.

- `Threading.Executor` explicitly creates its own runtime before starting workers, following class-field initialization in an explicit constructor.

- Add single-atom negative Regex assertions `(?!atom)` without consuming
  input, plus explicit byte offsets on matches and captures.

- Add `Collections.Dictionary.find(key)`: an owned optional lookup available
  on immutable dictionaries, preserving the existing mutable `get` borrow.
- Add `Text.UTF8.byte_count(text)` to measure UTF-8 bytes without allocating a
  list, including borrowed text and embedded NUL.
