# ParallelTransform

[Back to the recipe catalog](../README.md).

```sx
use STD.Threading

class Values {
    var items:int[]
    func double_range(start:int, end:int) {
        var index = start
        while index < end {
            self.items[index] *= 2
            index++
        }
    }
}

struct DoubleValues:Threading.ParallelJob {
    var values:Values
    func execute(start:int, end:int) { self.values.double_range(start, end) }
}

func main() {
    var values = Values(items:[1, 2, 3, 4, 5, 6, 7, 8])
    var executor = Threading.Executor(worker_count:2)
    var shared = executor
    var done = shared.submit_parallel(8, DoubleValues(values:values))
    done.complete()
    for value in values.items { print(value) }
}
```
