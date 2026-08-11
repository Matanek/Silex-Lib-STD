# Time

`Stopwatch` measures elapsed monotonic time. `start` and `stop` are idempotent;
`reset` clears and stops, while `restart` clears and starts. Read seconds or
milliseconds while running or stopped. Monotonic measurements are suitable for
durations, not civil dates. See
[MeasureOperation.sx](../Examples/Time/MeasureOperation.sx).

`Clock` converts monotonic time into application time. The first `tick()`
initializes the clock and returns zero. Later ticks return the scaled elapsed
step and accumulate total time. Paused clocks return a zero step; changing the
scale preserves elapsed time already accumulated at the previous scale.

A negative scale is accepted and intentionally makes application time run
backward. Applications that do not support that behavior should validate their
configuration. See [ScaledClock.sx](../Examples/Time/ScaledClock.sx).
