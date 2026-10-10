# PublishReport

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Error
use STD.File
use STD.FileSystem

func publish() Result<void, Error> {
    let root = "silex-publish-example"
    let staging = root + "/staging"
    let releases = root + "/releases/2026"
    try FileSystem.create_directory(root) else error { return Result<void,Error>.failure(error) }
    try FileSystem.create_directory(staging) else error { return Result<void,Error>.failure(error) }
    try FileSystem.create_directories(releases) else error { return Result<void,Error>.failure(error) }

    let draft = staging + "/report.txt"
    let copied = releases + "/report.copy"
    let published = releases + "/report.txt"
    try File.write_all(draft, "release ready\n") else error { return Result<void,Error>.failure(error) }
    try FileSystem.copy_file(draft, copied, false) else error { return Result<void,Error>.failure(error) }
    try FileSystem.rename(copied, published) else error { return Result<void,Error>.failure(error) }
    try FileSystem.set_readonly(published, true) else error { return Result<void,Error>.failure(error) }

    for entry in try FileSystem.list(releases) else error { return Result<void,Error>.failure(error) } {
        print("Published: $(entry.name)")
    }

    try FileSystem.set_readonly(published, false) else error { return Result<void,Error>.failure(error) }
    try FileSystem.remove_file(draft) else error { return Result<void,Error>.failure(error) }
    try FileSystem.remove_file(published) else error { return Result<void,Error>.failure(error) }
    try FileSystem.remove_directory(staging) else error { return Result<void,Error>.failure(error) }
    try FileSystem.remove_directory(releases) else error { return Result<void,Error>.failure(error) }
    try FileSystem.remove_directory(root + "/releases") else error { return Result<void,Error>.failure(error) }
    try FileSystem.remove_directory(root) else error { return Result<void,Error>.failure(error) }
    return Result<void, Error>.success()
}

func main() {
    match (try publish()) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
