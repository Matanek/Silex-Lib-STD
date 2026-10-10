# OrganizeWorkspace

[Back to the recipe catalog](../README.md).

```sx
use STD.File
use STD.FileSystem
use STD.Error

func kind_name(kind:FileSystem.Kind) str {
    return match kind {
        file => "file"
        directory => "directory"
        symbolic_link => "symbolic link"
        other => "other"
    }
}

func prepare_workspace() Result<void, Error> {
    let root = "silex-example-workspace"
    let reports = root + "/reports"
    try FileSystem.create_directories(reports) else error { return Result<void,Error>.failure(error) }
    try File.write_all(reports + "/latest.txt", "all checks passed\n") else error { return Result<void,Error>.failure(error) }

    let entries = try FileSystem.list(reports) else error { return Result<void,Error>.failure(error) }
    for entry in entries {
        print("$(entry.name): $(kind_name(entry.kind))")
    }
    return Result<void, Error>.success()
}

func main() {
    match (try prepare_workspace()) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
