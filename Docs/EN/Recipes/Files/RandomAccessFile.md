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
    var file = try File.open("random-access.bin", options)
    let original:uint8[4] = [1, 2, 3, 4]
    let replacement:uint8[1] = [9]
    let first_write = try file.write(@original[0:4])
    let position = try file.seek(1, File.SeekFrom.start())
    let second_write = try file.write(@replacement[0:1])
    print("Position: $(try file.position())")
    try file.set_length(3)
    print("Length: $(try file.length())")
    return File.close(move file)
}

func main() {
    match edit_header() {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
