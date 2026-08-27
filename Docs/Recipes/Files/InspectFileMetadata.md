# InspectFileMetadata

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Error
use STD.File
use STD.FileSystem

func inspect() Result<void, Error> {
    let path = "metadata-sample.txt"
    try File.write_all(path, "Silex")
    let followed = try FileSystem.metadata(path)
    let direct = try FileSystem.symbolic_link_metadata(path)
    let canonical = try FileSystem.canonicalize(path)
    print("Canonical path: $(canonical)")
    print("Size: $(followed.size) bytes")
    print("Readonly: $(direct.readonly)")
    return Result<void, Error>.success()
}

func main() {
    match inspect() {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
