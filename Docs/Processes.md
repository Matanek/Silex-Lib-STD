# Processes and compilation targets

## Inspect the current process

`Process.arguments`, `current_directory` and `executable_path` are fallible
because platform text and filesystem access can fail. `id()` is immediate.
`set_current_directory` changes the process-wide working directory, so prefer
explicit paths in concurrent applications. See
[InspectRuntime.sx](../Examples/Process/InspectRuntime.sx).

## Run a child process

`Subprocess.Command` makes every process choice explicit:

- executable and argument boundaries;
- optional child working directory;
- inherited or empty base environment;
- ordered environment assignments/removals;
- complete standard input bytes;
- maximum combined captured output.

`Subprocess.run` waits for completion and returns captured standard output,
standard error, and either `ExitStatus.exited(code)` or `signaled(signal)`.
Decode captured bytes explicitly when text is expected. Output beyond the
configured maximum returns `limit_exceeded`. See
[CaptureChild.sx](../Examples/Subprocess/CaptureChild.sx).

Environment changes affect only the child. With `inherit_environment:false`,
only explicit assignments are present. Executable paths remain platform
specific; [ScopedEnvironment.sx](../Examples/Subprocess/ScopedEnvironment.sx)
shows an intentional platform match.

## Describe the selected target

`System.platform()` and `System.target()` describe the program's selected
compilation target, not necessarily the compiler host. Use `platform_name` and
`target_name` for stable display strings. See
[DescribeTarget.sx](../Examples/System/DescribeTarget.sx).
