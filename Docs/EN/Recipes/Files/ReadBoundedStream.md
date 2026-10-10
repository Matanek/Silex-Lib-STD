# ReadBoundedStream

[Back to the recipe catalog](../README.md).

```sx
use STD.Error
use STD.File
use STD.File.File as OpenFile
use STD.IO

func read_payload() Result<void, Error> {
    let path = "bounded-payload.bin"
    let payload:uint8[5] = [1, 2, 3, 4, 5]
    try File.write_all(path, @payload[0:payload.count()]) else error { return Result<void,Error>.failure(error) }

    let options = File.OpenOptions(
        access:File.Access.read(),
        creation:File.Creation.open_existing(),
        append:false
    )
    var input:OpenFile = try File.open(path, options) else error { return Result<void,Error>.failure(error) }
    let bytes = try IO.read_to_end<OpenFile>(input, 1024) else error { return Result<void,Error>.failure(error) }
    try File.close(move input) else error { return Result<void,Error>.failure(error) }
    print("Read $(bytes.count()) bounded bytes")
    return Result<void, Error>.success()
}

func main() {
    match (try read_payload()) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
