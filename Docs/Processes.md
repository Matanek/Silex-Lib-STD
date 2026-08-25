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

## Drive an interactive child

`Subprocess.spawn` starts a `Child` with separate standard-input,
standard-output and standard-error pipes. `write_standard_input` is a blocking
pipe write and may accept fewer bytes than requested; retry the unwritten tail
when complete delivery matters, then call `close_standard_input` to publish
end-of-input. `next_event(timeout_milliseconds)` returns one output chunk, an
exit status, or `null` when the non-negative timeout expires. Output remains
bytes until the application explicitly decodes it.

The exit event is emitted only after both output pipes have reached their end,
so every preceding output chunk can be consumed before completion. Dropping a
still-running `Child` terminates and reaps it; call `terminate` when that choice
should be visible in application control flow. On POSIX targets, a failure in
the child after `fork`, such as an executable rejected by `exec`, is reported
as exit code 127; Windows can reject the initial `spawn` directly. See
[StreamChild.sx](../Examples/Subprocess/StreamChild.sx).

## Describe the selected target

`System.platform()` and `System.target()` describe the program's selected
compilation target, not necessarily the compiler host. Use `platform_name` and
`target_name` for stable display strings. See
[DescribeTarget.sx](../Examples/System/DescribeTarget.sx).
