# CopyStream

[Back to the recipe catalog](../README.md).

```sx
use STD.File
use STD.Error
use STD.IO

func copy_file(source:str, destination:str) Result<int, Error> {
    let read_options = File.OpenOptions(
        access:File.Access.read(),
        creation:File.Creation.open_existing(),
        append:false
    )
    let write_options = File.OpenOptions(
        access:File.Access.write(),
        creation:File.Creation.create_or_truncate(),
        append:false
    )
    var input = try File.open(source, read_options) else error { return Result<int,Error>.failure(error) }
    var output = try File.open(destination, write_options) else error { return Result<int,Error>.failure(error) }
    let count = try IO.copy(input, output, 16 * 1024 * 1024) else error { return Result<int,Error>.failure(error) }
    try output.flush() else error { return Result<int,Error>.failure(error) }
    try File.close(move input) else error { return Result<int,Error>.failure(error) }
    try File.close(move output) else error { return Result<int,Error>.failure(error) }
    return Result<int, Error>.success(count)
}

func main() {
    match (try copy_file("silex-note.txt", "silex-note-copy.txt")) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success(count) => { print("Copied $(count) bytes") }
    }
}
```
