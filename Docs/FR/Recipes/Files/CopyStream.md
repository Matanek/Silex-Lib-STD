# CopyStream

[Retour au catalogue des recettes](../README.md).

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
    var input = try File.open(source, read_options)
    var output = try File.open(destination, write_options)
    let count = try IO.copy(input, output, 16 * 1024 * 1024)
    try output.flush()
    try File.close(move input)
    try File.close(move output)
    return Result<int, Error>.success(count)
}

func main() {
    match copy_file("silex-note.txt", "silex-note-copy.txt") {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success(count) => { print("Copied $(count) bytes") }
    }
}
```
