# CountPassingEntries

[Back to the recipe catalog](../README.md).

```sx
use STD.Algorithms.Iteration
use STD.Collections.Dictionary
use STD.Collections.Dictionary.Entry

func passing(entry:@Entry<str, int>) bool {
    return entry.value >= 10
}

func main() {
    var scores = Dictionary<str, int>()
    scores.set("Ada", 12)
    scores.set("Linus", 9)
    scores.set("Grace", 15)

    let count = Iteration.count_where<Entry<str, int>>(
        scores.iterator(),
        passing
    )
    print("Passing entries: $(count)")
}
```
