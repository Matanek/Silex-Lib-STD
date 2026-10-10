# InspectPath

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Path
use STD.Error

func inspect(path:str) Result<void, Error> {
    try Path.validate(path) else error { return Result<void,Error>.failure(error) }
    let normalized = try Path.normalize(path) else error { return Result<void,Error>.failure(error) }
    print("Normalized: $(normalized)")
    print("Absolute: $(try Path.is_absolute(normalized) else error { return Result<void,Error>.failure(error) })")
    if parent = try Path.parent(normalized) else error { return Result<void,Error>.failure(error) } { print("Parent: $(parent)") }
    if name = try Path.name(normalized) else error { return Result<void,Error>.failure(error) } { print("Name: $(name)") }
    if stem = try Path.stem(normalized) else error { return Result<void,Error>.failure(error) } { print("Stem: $(stem)") }
    if extension = try Path.extension(normalized) else error { return Result<void,Error>.failure(error) } { print("Extension: $(extension)") }
    print("Sibling: $(try Path.join(normalized, "../archive.json") else error { return Result<void,Error>.failure(error) })")
    return Result<void, Error>.success()
}

func main() {
    match (try inspect("reports/../reports/latest.json")) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
