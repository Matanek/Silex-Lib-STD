# NativeCheckpoint

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Threading

struct Increment:Threading.Job {
    var value:int
    func execute() { self.value++ }
}

class ParallelState {
    var values:int[]

    func fill(start:int, end:int, factor:int) {
        var index = start
        while index < end {
            self.values[index] = index * factor + 1
            index++
        }
    }

    func signature() int {
        var result = 0
        for value in self.values { result += value }
        return result
    }
}

struct Fill:Threading.ParallelJob {
    var state:ParallelState
    var factor:int
    func execute(start:int, end:int) { self.state.fill(start, end, self.factor) }
}

func exercise_workers(worker_count:int) {
    var executor = Threading.Executor(worker_count:worker_count)
    print("SILEX_THREADING_CHECKPOINT executor-ready workers=$(worker_count)")
    var handle = executor.submit(Increment(value:41))
    print("SILEX_THREADING_CHECKPOINT job-submitted workers=$(worker_count)")
    if handle.complete().value != 42 {
        panic("native threading checkpoint returned an invalid result")
    }
    var values:int[] = []
    for index in 0...4_096 { values.append(0) }
    var state = ParallelState(values:values)
    var signature = 0
    for frame in 1...6 {
        var completed = executor.submit_parallel(4_096, Fill(state:state, factor:frame))
        completed.complete()
        signature = state.signature()
        let expected = 4_096 + (4_095 * 4_096 / 2) * frame
        if signature != expected {
            panic("native threading checkpoint produced a nondeterministic parallel result")
        }
    }
    print("SILEX_THREADING_CHECKPOINT job-completed workers=$(worker_count) signature=$(signature)")
}

func main() {
    print("SILEX_THREADING_CHECKPOINT process-ready")
    exercise_workers(1)
    exercise_workers(2)
    exercise_workers(4)
    print("SILEX_THREADING_CHECKPOINT executors-stopped")
}
```
