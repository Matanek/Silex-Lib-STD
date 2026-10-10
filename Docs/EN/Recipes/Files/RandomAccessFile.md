# RandomAccessFile

[Back to the recipe catalog](../README.md).

```sx
use STD.Error
use STD.File

func edit_header() Result<void, Error> {
    let options = File.OpenOptions(
        access:File.Access.read_write(),
        creation:File.Creation.create_or_truncate(),
        append:false
    )
    var file = try File.open("random-access.bin", options) else error { return Result<void,Error>.failure(error) }
    let original:uint8[4] = [1, 2, 3, 4]
    let replacement:uint8[1] = [9]
    let first_write = try file.write(@original[0:4]) else error { return Result<void,Error>.failure(error) }
    let position = try file.seek(1, File.SeekFrom.start()) else error { return Result<void,Error>.failure(error) }
    let second_write = try file.write(@replacement[0:1]) else error { return Result<void,Error>.failure(error) }
    print("Position: $(try file.position() else error { return Result<void,Error>.failure(error) })")
    try file.set_length(3) else error { return Result<void,Error>.failure(error) }
    print("Length: $(try file.length() else error { return Result<void,Error>.failure(error) })")
    return (try File.close(move file))
}

func main() {
    match (try edit_header()) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
