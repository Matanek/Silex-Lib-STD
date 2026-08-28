# InspectPath

[Back to the recipe catalog](../README.md).

```sx
use STD.Path
use STD.Error

func inspect(path:str) Result<void, Error> {
    try Path.validate(path)
    let normalized = try Path.normalize(path)
    print("Normalized: $(normalized)")
    print("Absolute: $(try Path.is_absolute(normalized))")
    if parent = try Path.parent(normalized) { print("Parent: $(parent)") }
    if name = try Path.name(normalized) { print("Name: $(name)") }
    if stem = try Path.stem(normalized) { print("Stem: $(stem)") }
    if extension = try Path.extension(normalized) { print("Extension: $(extension)") }
    print("Sibling: $(try Path.join(normalized, "../archive.json"))")
    return Result<void, Error>.success()
}

func main() {
    match inspect("reports/../reports/latest.json") {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
