# CreateIdentifiers

[Back to the recipe catalog](../README.md).

```sx
use STD.UUID

func main() {
    print("Opaque identifier: $(UUID.v4().to_str())")
    print("Time-sortable identifier: $(UUID.v7().to_str())")
}
```
