# Console applications

## Write ordinary command output

`Console.write_line` writes to standard output. `write_error_line` writes to
standard error, which keeps diagnostics separate when output is redirected.
The forms without `_line` add no newline. Console writes currently cross the
system boundary immediately; `flush()` exists for a stable calling convention
and performs no additional work.

Use [StyledStatus.sx](Recipes/Console/StyledStatus.md) for color, emphasis
and terminal dimensions. Always call `reset_style()` after styled output.
`get_dimensions()` returns `null` when dimensions are unavailable, including
ordinary redirected output. Cursor coordinates passed to `move_cursor` are
zero-origin.

## Read one line

`read_line()` returns one UTF-8 line without its newline, or `null` when input
ends before any byte is read. Invalid UTF-8 is a programming-ending input
error. [PromptForName.sx](Recipes/Console/PromptForName.md) shows the
complete optional-input path.
[WaitForConfirmation.sx](Recipes/Console/WaitForConfirmation.md) covers the
separate `wait_for_enter()` confirmation pattern.

## Own an interactive terminal session

`Console.Session` changes terminal input mode so key presses can be consumed
without waiting for a line. Construction requires an interactive terminal and
panics otherwise. A session owns the previous terminal state until `close()` or
drop; both restore styles, cursor visibility and the original input mode.

`read_key()` waits indefinitely. `poll_key(timeout_milliseconds)` returns
`null` after a non-negative timeout. `poll_keys(maximum_count, timeout)` waits
for the first event and then drains immediately available events into a queue.

`enter_alternate_screen()` provides a disposable full-screen surface; pair it
with `leave_alternate_screen()` or simply close the session. Use
[SessionKeyViewer.sx](Recipes/Console/SessionKeyViewer.md) as the minimal
event-loop application.
[SessionKeyBatch.sx](Recipes/Console/SessionKeyBatch.md) demonstrates timed
polling and bounded event draining without an indefinitely blocking read.

Key events distinguish characters, navigation, editing, function keys and
unknown terminal sequences. Modifier booleans report Shift, Control and Alt.
Applications should retain an `unknown` branch because terminal protocols are
extensible.
