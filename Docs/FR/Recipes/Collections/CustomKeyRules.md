# CustomKeyRules

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Collections.Dictionary

func absolute_hash(value:@int) uint {
    if value < 0 { return (-value) as uint }
    return value as uint
}

func same_magnitude(left:@int, right:@int) bool {
    return absolute_hash(left) == absolute_hash(right)
}

func main() {
    var labels = Dictionary<int, str>(absolute_hash, same_magnitude)
    labels.set(-7, "seven")
    print("Lookup +7: $(labels.get(7))")
}
```
