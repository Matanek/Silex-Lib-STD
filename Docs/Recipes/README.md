# Recettes STD

Chaque page répond à une question pratique et conserve son programme sous la
forme d’un extrait documentaire complet. Les recettes interactives et réseau
indiquent toujours l’environnement nécessaire, mais ne constituent plus un
catalogue d’exécutables appartenant au package.

- [DictionaryScores.sx](Collections/DictionaryScores.md) — associate names and
  scores, update a value and traverse key-value entries.
- [CustomKeyRules.sx](Collections/CustomKeyRules.md) — define matching hash and
  equality rules for domain-specific keys.
- [UniqueTags.sx](Collections/UniqueTags.md) — deduplicate incoming values.
- [TaskQueue.sx](Collections/TaskQueue.md) — process work in FIFO order.
- [UndoHistory.sx](Collections/UndoHistory.md) — consume history in LIFO order.
- [AnalyzeValues.sx](Collections/AnalyzeValues.md) — count and transform values
  with iterator algorithms.
- [CountPassingEntries.sx](Collections/CountPassingEntries.md) — apply a generic
  iterator algorithm directly to typed dictionary entries.
- [SortLeaderboard.sx](Collections/SortLeaderboard.md) — order domain values in
  a mutable collection.

## Console applications

- [StyledStatus.sx](Console/StyledStatus.md) — write styled status output and
  adapt to redirected output.
- [PromptForName.sx](Console/PromptForName.md) — read one UTF-8 input line.
  Interactive input is required.
- [SessionKeyViewer.sx](Console/SessionKeyViewer.md) — build a full-screen key
  event loop with reliable terminal restoration. An interactive terminal is
  required.
- [SessionKeyBatch.sx](Console/SessionKeyBatch.md) — poll and drain a bounded
  batch of key events. An interactive terminal is required.
- [WaitForConfirmation.sx](Console/WaitForConfirmation.md) — pause a command
  until Enter is pressed. Interactive input is required.

## Text

- [ExtractContacts.sx](Regex/ExtractContacts.md) — compile a regular expression,
  iterate lazily over contacts and read named captures.
- [NormalizeLog.sx](Regex/NormalizeLog.md) — replace matches with a callback and
  split structured text.
- [UsePresets.sx](Regex/UsePresets.md) — recognize digits, email addresses and
  IP addresses with cached built-in expressions.
- [CleanNames.sx](Text/CleanNames.md) — trim, title-case and join human text.
- [CountGraphemes.sx](Text/CountGraphemes.md) — count user-visible Unicode
  characters.
- [Utf8RoundTrip.sx](Text/Utf8RoundTrip.md) — cross the explicit UTF-8 byte
  boundary.
- [CompareUnicode.sx](Text/CompareUnicode.md) — normalize and case-fold text
  into stable search keys.
- [DecodeDocument.sx](Text/DecodeDocument.md) — detect a BOM and decode an
  explicitly encoded Unicode document.

## Files and paths

- [ReadWriteText.sx](Files/ReadWriteText.md) — write and read a complete UTF-8
  file.
- [BinaryFile.sx](Files/BinaryFile.md) — preserve an exact binary header.
- [RandomAccessFile.sx](Files/RandomAccessFile.md) — seek and replace bytes in
  an open file.
- [CopyStream.sx](Files/CopyStream.md) — stream a bounded copy through
  `IO.Reader` and `IO.Writer`.
- [ReadBinaryHeader.sx](Files/ReadBinaryHeader.md) — fill an exact-size header
  buffer from a stream.
- [ReadBoundedStream.sx](Files/ReadBoundedStream.md) — consume a stream to its
  end under an explicit byte limit.
- [WriteCompleteStream.sx](Files/WriteCompleteStream.md) — write an entire
  packet even when a writer completes it in several operations.
- [OrganizeWorkspace.sx](Files/OrganizeWorkspace.md) — create directories,
  write a report and list metadata.
- [InspectFileMetadata.sx](Files/InspectFileMetadata.md) — compare metadata
  modes and canonicalize a file path.
- [PublishReport.sx](Files/PublishReport.md) — create, copy, rename, protect,
  list and clean a publication tree.
- [InspectPath.sx](Files/InspectPath.md) — normalize and decompose a path.
- [WatchWorkspace.sx](FileWatch/WatchWorkspace.md) — consume native recursive
  workspace invalidations with a bounded wait.

The file examples create relative files or directories in their working
directory. Run them from a disposable directory when the generated artifacts
are not wanted in the project.

## Processes and the selected target

- [InspectRuntime.sx](Process/InspectRuntime.md) — inspect arguments, process id
  and working directory.
- [CaptureChild.sx](Subprocess/CaptureChild.md) — run the current executable as
  a child and decode captured output.
- [ScopedEnvironment.sx](Subprocess/ScopedEnvironment.md) — replace a child
  environment without changing the parent.
- [StreamChild.sx](Subprocess/StreamChild.md) — exchange standard-input and
  streamed output with a running child before collecting its exit status.
- [HostTerminal.sx](Subprocess/HostTerminal.md) — host a child through the
  portable PTY/ConPTY terminal transport.
- [DescribeTarget.sx](System/DescribeTarget.md) — distinguish the selected
  compilation target from the build machine.

## Networking

- [ResolveService.sx](Network/ResolveService.md) — resolve a host and format its
  endpoints. Platform name resolution is required.
- [TcpHealthCheck.sx](Network/TcpHealthCheck.md) — connect to a local TCP
  service. A listener on `127.0.0.1:8080` is required for success.
- [TcpEchoServer.sx](Network/TcpEchoServer.md) — accept and echo one bounded TCP
  payload. It listens on `127.0.0.1:8080`.
- [UdpAnnouncement.sx](Network/UdpAnnouncement.md) — send one UDP datagram to
  `127.0.0.1:9000`.
- [UdpReceiver.sx](Network/UdpReceiver.md) — bind, receive and decode one
  bounded UDP datagram on `127.0.0.1:9000`.
- [TlsAvailability.sx](Network/TlsAvailability.md) — inspect whether the selected
  target provides certificate-verifying TLS.
- [TlsFetch.sx](Network/TlsFetch.md) — negotiate TLS 1.2 or newer, verify
  `example.com` and read encrypted response data. External network access is
  required.

## Concurrency and time

- [ComputeResult.sx](Threading/ComputeResult.md) — submit a typed CPU job and
  consume its result.
- [DependentTasks.sx](Threading/DependentTasks.md) — order two phases with a
  fence without blocking a worker.
- [ParallelTransform.sx](Threading/ParallelTransform.md) — transform disjoint
  indexed ranges in parallel.
- [FanOutAndJoin.sx](Threading/FanOutAndJoin.md) — submit independent branches
  and join their fences.
- [MeasureOperation.sx](Time/MeasureOperation.md) — measure elapsed monotonic
  time.
- [ScaledClock.sx](Time/ScaledClock.md) — drive a pausable, scaled simulation
  clock.

## Math, randomness and identifiers

- [ViewportLayout.sx](Math/ViewportLayout.md) — calculate a viewport, hit-test a
  panel and apply a smooth transition.
- [ShufflePlaylist.sx](Random/ShufflePlaylist.md) — shuffle a mutable sequence
  with system-seeded randomness.
- [RollDice.sx](Random/RollDice.md) — generate bounded integers and unit floats.
- [ContentFingerprint.sx](Crypto/ContentFingerprint.md) — hash content and
  request cryptographic random bytes.
- [HashFile.sx](Crypto/HashFile.md) — hash a complete binary file under an
  explicit size limit. Run `BinaryFile.sx` first to create its sample input.
- [AuthenticatedMessage.sx](Crypto/AuthenticatedMessage.md) — derive a shared
  X25519 key and authenticate one encrypted message.
- [CreateIdentifiers.sx](UUID/CreateIdentifiers.md) — choose between opaque v4
  and time-sortable v7 identifiers.
