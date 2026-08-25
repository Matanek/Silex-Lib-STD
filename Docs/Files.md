# Files and paths

## Read or replace a complete file

`File.read_text(path, maximum_bytes)` validates UTF-8 and rejects oversized
input. `File.read_all` preserves arbitrary bytes. The maximum is a deliberate
resource limit and should reflect the application domain.

`File.write_all` replaces a file with text or bytes and flushes before closing.
[ReadWriteText.sx](../Examples/Files/ReadWriteText.sx) is the shortest complete
round trip. [BinaryFile.sx](../Examples/Files/BinaryFile.sx) preserves exact
bytes instead of interpreting them as UTF-8.

## Stream large or incremental data

`File.open` combines `Access`, `Creation` and `append` in `OpenOptions`. A
returned `File` conforms directly to `IO.Reader` and `IO.Writer`. Close every
owned handle with `File.close(move file)`; using a closed handle is a fallible
error.

`IO.read_exact` fills a buffer or reports `unexpected_end`; see
[ReadBinaryHeader.sx](../Examples/Files/ReadBinaryHeader.sx). `read_to_end`
requires a maximum byte count and is demonstrated by
[ReadBoundedStream.sx](../Examples/Files/ReadBoundedStream.sx). `write_all`
retries short writes but rejects writers that make no progress; see
[WriteCompleteStream.sx](../Examples/Files/WriteCompleteStream.sx). `copy`
combines bounded reading and complete writing in
[CopyStream.sx](../Examples/Files/CopyStream.sx).

Seek positions use `SeekFrom.start`, `current` or `end`. `position`, `length`
and `set_length` compose those operations without exposing file descriptors.
See [RandomAccessFile.sx](../Examples/Files/RandomAccessFile.sx).

## Organize directories

`FileSystem` exposes metadata, symbolic-link metadata, canonicalization,
listing, directory creation, removal, rename, copy and readonly control.
`remove_directory` removes one empty directory; application code must decide
whether recursive deletion is appropriate. `copy_file` requires an explicit
`replace` choice. See
[OrganizeWorkspace.sx](../Examples/Files/OrganizeWorkspace.sx).
[InspectFileMetadata.sx](../Examples/Files/InspectFileMetadata.sx) compares
followed and direct metadata and obtains a canonical path.
[PublishReport.sx](../Examples/Files/PublishReport.sx) exercises the complete
create, copy, rename, protect, list and cleanup lifecycle.

`Path` validates, normalizes, joins and decomposes platform paths. Its
operations are fallible because malformed paths and platform rules are part of
the observable contract. See [InspectPath.sx](../Examples/Files/InspectPath.sx).
That program covers validation, normalization, absolute-path detection,
joining, parent lookup, name, stem and extension.

## Observe workspace changes

`FileWatch.open(path, Options(recursive:...))` owns a native directory watcher.
The watched path is canonicalized and must be a directory. `Watcher.next` waits
up to a non-negative timeout and returns one `created`, `modified`, `removed`,
`renamed` or `metadata` change, or `null` when no event arrives. Event paths are
absolute canonical paths. A non-recursive watcher accepts only the directory
itself and its direct children; a recursive watcher includes descendants.

Native services can coalesce events, emit more than one change for one logical
operation, or represent a rename as separate old/new notifications. Consumers
should treat notifications as invalidations and reread the affected state.
`rescan_required` means the native queue overflowed or otherwise lost detail;
rebuild the complete application snapshot before continuing. `close` is
idempotent, and dropping the owned watcher closes it. See
[WatchWorkspace.sx](../Examples/FileWatch/WatchWorkspace.sx).
