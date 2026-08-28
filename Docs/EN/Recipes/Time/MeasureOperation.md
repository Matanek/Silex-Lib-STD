# MeasureOperation

[Back to the recipe catalog](../README.md).

```sx
use STD.Time.Stopwatch

func main() {
    var stopwatch = Stopwatch()
    stopwatch.start()
    var total = 0
    for value in 0...100000 { total += value }
    stopwatch.stop()
    print("Total: $(total)")
    print("Elapsed: $(stopwatch.get_elapsed_milliseconds()) ms")
}
```
