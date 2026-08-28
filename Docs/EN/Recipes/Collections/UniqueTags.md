# UniqueTags

[Back to the recipe catalog](../README.md).

```sx
use STD.Collections.Set

func main() {
    var tags = Set<str>()
    let input = ["network", "terminal", "network", "json"]

    for tag in input {
        if tags.add(tag) { print("New tag: $(tag)") }
    }

    print("Unique tags: $(tags.count())")
}
```
