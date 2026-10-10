# InspectFileMetadata

[Back to the recipe catalog](../README.md).

```sx
use STD.Error
use STD.File
use STD.FileSystem

func inspect() Result<void, Error> {
    let path = "metadata-sample.txt"
    try File.write_all(path, "Silex") else error { return Result<void,Error>.failure(error) }
    let followed = try FileSystem.metadata(path) else error { return Result<void,Error>.failure(error) }
    let direct = try FileSystem.symbolic_link_metadata(path) else error { return Result<void,Error>.failure(error) }
    let canonical = try FileSystem.canonicalize(path) else error { return Result<void,Error>.failure(error) }
    print("Canonical path: $(canonical)")
    print("Size: $(followed.size) bytes")
    print("Readonly: $(direct.readonly)")
    return Result<void, Error>.success()
}

func main() {
    match (try inspect()) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
