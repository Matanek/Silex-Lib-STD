# DictionaryScores

[Back to the recipe catalog](../README.md).

```sx
use STD.Collections.Dictionary

func main() {
    var scores = Dictionary<str, int>()
    scores.set("Ada", 12)
    scores.set("Linus", 9)
    scores.set("Grace", 15)

    if previous = scores.set("Ada", 14) {
        print("Ada improved from $(previous) to $(scores.get("Ada"))")
    }

    var entries = scores.iterator()
    while entry = entries.next() {
        print("$(entry.key): $(entry.value)")
    }
}
```
