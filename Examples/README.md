# STD by example

Each program answers one practical question and can be copied as a starting
point. Run a non-interactive example from the workspace root with:

```sh
./Silex/Toolchain/zig-out/bin/silex run Packages/STD/Examples/System/DescribeTarget.sx
```

Interactive and network examples are marked below. They are always compiled by
the example validation, but require the stated environment to run.

Compile the complete catalogue from the workspace root with:

```sh
./silex-dev examples-std
```

## Collections and algorithms

- [DictionaryScores.sx](Collections/DictionaryScores.sx) — associate names and
  scores, update a value and traverse key-value entries.
- [CustomKeyRules.sx](Collections/CustomKeyRules.sx) — define matching hash and
  equality rules for domain-specific keys.
- [UniqueTags.sx](Collections/UniqueTags.sx) — deduplicate incoming values.
- [TaskQueue.sx](Collections/TaskQueue.sx) — process work in FIFO order.
- [UndoHistory.sx](Collections/UndoHistory.sx) — consume history in LIFO order.
- [AnalyzeValues.sx](Collections/AnalyzeValues.sx) — count and transform values
  with iterator algorithms.
- [CountPassingEntries.sx](Collections/CountPassingEntries.sx) — apply a generic
  iterator algorithm directly to typed dictionary entries.
- [SortLeaderboard.sx](Collections/SortLeaderboard.sx) — order domain values in
  a mutable collection.

## Console applications

- [StyledStatus.sx](Console/StyledStatus.sx) — write styled status output and
  adapt to redirected output.
- [PromptForName.sx](Console/PromptForName.sx) — read one UTF-8 input line.
  Interactive input is required.
- [SessionKeyViewer.sx](Console/SessionKeyViewer.sx) — build a full-screen key
  event loop with reliable terminal restoration. An interactive terminal is
  required.
- [SessionKeyBatch.sx](Console/SessionKeyBatch.sx) — poll and drain a bounded
  batch of key events. An interactive terminal is required.
- [WaitForConfirmation.sx](Console/WaitForConfirmation.sx) — pause a command
  until Enter is pressed. Interactive input is required.

## Text

- [ExtractContacts.sx](Regex/ExtractContacts.sx) — compile a regular expression,
  iterate lazily over contacts and read named captures.
- [NormalizeLog.sx](Regex/NormalizeLog.sx) — replace matches with a callback and
  split structured text.
- [UsePresets.sx](Regex/UsePresets.sx) — recognize digits, email addresses and
  IP addresses with cached built-in expressions.
- [CleanNames.sx](Text/CleanNames.sx) — trim, title-case and join human text.
- [CountGraphemes.sx](Text/CountGraphemes.sx) — count user-visible Unicode
  characters.
- [Utf8RoundTrip.sx](Text/Utf8RoundTrip.sx) — cross the explicit UTF-8 byte
  boundary.
- [CompareUnicode.sx](Text/CompareUnicode.sx) — normalize and case-fold text
  into stable search keys.
- [DecodeDocument.sx](Text/DecodeDocument.sx) — detect a BOM and decode an
  explicitly encoded Unicode document.

## Files and paths

- [ReadWriteText.sx](Files/ReadWriteText.sx) — write and read a complete UTF-8
  file.
- [BinaryFile.sx](Files/BinaryFile.sx) — preserve an exact binary header.
- [RandomAccessFile.sx](Files/RandomAccessFile.sx) — seek and replace bytes in
  an open file.
- [CopyStream.sx](Files/CopyStream.sx) — stream a bounded copy through
  `IO.Reader` and `IO.Writer`.
- [ReadBinaryHeader.sx](Files/ReadBinaryHeader.sx) — fill an exact-size header
  buffer from a stream.
- [ReadBoundedStream.sx](Files/ReadBoundedStream.sx) — consume a stream to its
  end under an explicit byte limit.
- [WriteCompleteStream.sx](Files/WriteCompleteStream.sx) — write an entire
  packet even when a writer completes it in several operations.
- [OrganizeWorkspace.sx](Files/OrganizeWorkspace.sx) — create directories,
  write a report and list metadata.
- [InspectFileMetadata.sx](Files/InspectFileMetadata.sx) — compare metadata
  modes and canonicalize a file path.
- [PublishReport.sx](Files/PublishReport.sx) — create, copy, rename, protect,
  list and clean a publication tree.
- [InspectPath.sx](Files/InspectPath.sx) — normalize and decompose a path.
- [WatchWorkspace.sx](FileWatch/WatchWorkspace.sx) — consume native recursive
  workspace invalidations with a bounded wait.

The file examples create relative files or directories in their working
directory. Run them from a disposable directory when the generated artifacts
are not wanted in the project.

## Processes and the selected target

- [InspectRuntime.sx](Process/InspectRuntime.sx) — inspect arguments, process id
  and working directory.
- [CaptureChild.sx](Subprocess/CaptureChild.sx) — run the current executable as
  a child and decode captured output.
- [ScopedEnvironment.sx](Subprocess/ScopedEnvironment.sx) — replace a child
  environment without changing the parent.
- [StreamChild.sx](Subprocess/StreamChild.sx) — exchange standard-input and
  streamed output with a running child before collecting its exit status.
- [DescribeTarget.sx](System/DescribeTarget.sx) — distinguish the selected
  compilation target from the build machine.

## Networking

- [ResolveService.sx](Network/ResolveService.sx) — resolve a host and format its
  endpoints. Platform name resolution is required.
- [TcpHealthCheck.sx](Network/TcpHealthCheck.sx) — connect to a local TCP
  service. A listener on `127.0.0.1:8080` is required for success.
- [TcpEchoServer.sx](Network/TcpEchoServer.sx) — accept and echo one bounded TCP
  payload. It listens on `127.0.0.1:8080`.
- [UdpAnnouncement.sx](Network/UdpAnnouncement.sx) — send one UDP datagram to
  `127.0.0.1:9000`.
- [UdpReceiver.sx](Network/UdpReceiver.sx) — bind, receive and decode one
  bounded UDP datagram on `127.0.0.1:9000`.
- [TlsAvailability.sx](Network/TlsAvailability.sx) — inspect whether the selected
  target provides certificate-verifying TLS.
- [TlsFetch.sx](Network/TlsFetch.sx) — negotiate TLS 1.2 or newer, verify
  `example.com` and read encrypted response data. External network access is
  required.

## Concurrency and time

- [ComputeResult.sx](Threading/ComputeResult.sx) — submit a typed CPU job and
  consume its result.
- [DependentTasks.sx](Threading/DependentTasks.sx) — order two phases with a
  fence without blocking a worker.
- [ParallelTransform.sx](Threading/ParallelTransform.sx) — transform disjoint
  indexed ranges in parallel.
- [FanOutAndJoin.sx](Threading/FanOutAndJoin.sx) — submit independent branches
  and join their fences.
- [MeasureOperation.sx](Time/MeasureOperation.sx) — measure elapsed monotonic
  time.
- [ScaledClock.sx](Time/ScaledClock.sx) — drive a pausable, scaled simulation
  clock.

## Math, randomness and identifiers

- [ViewportLayout.sx](Math/ViewportLayout.sx) — calculate a viewport, hit-test a
  panel and apply a smooth transition.
- [ShufflePlaylist.sx](Random/ShufflePlaylist.sx) — shuffle a mutable sequence
  with system-seeded randomness.
- [RollDice.sx](Random/RollDice.sx) — generate bounded integers and unit floats.
- [ContentFingerprint.sx](Crypto/ContentFingerprint.sx) — hash content and
  request cryptographic random bytes.
- [HashFile.sx](Crypto/HashFile.sx) — hash a complete binary file under an
  explicit size limit. Run `BinaryFile.sx` first to create its sample input.
- [AuthenticatedMessage.sx](Crypto/AuthenticatedMessage.sx) — derive a shared
  X25519 key and authenticate one encrypted message.
- [CreateIdentifiers.sx](UUID/CreateIdentifiers.sx) — choose between opaque v4
  and time-sortable v7 identifiers.
