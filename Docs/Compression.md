# Compression

`STD.Compression` exposes bounded decompression for raw deflate, gzip and zlib
streams. The caller chooses the container explicitly and always controls the
largest accepted output:

```sx
use STD.Compression

let decoded = try Compression.decompress(
    compressed,
    Compression.Format.gzip,
    8 * 1024 * 1024
)
```

The default limit is 16 MiB. Output storage grows geometrically up to that
limit, avoiding one allocation per decoded chunk. Empty or malformed streams
and invalid checksums return `STD.Error.Kind.invalid_data`; an output that would
cross the bound returns `limit_exceeded`. No partial result is exposed.

The implementation uses the same public API and bundled boundary on macOS
ARM64, Linux x86-64, Windows x86-64 and Windows ARM64. Compression is currently
decompression-only: accepting an explicit `Format` keeps it suitable for HTTP
content coding, archives and other binary protocols without guessing from
untrusted bytes.
