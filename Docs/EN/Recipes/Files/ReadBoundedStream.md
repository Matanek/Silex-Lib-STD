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
    try File.write_all(path, @payload[0:payload.count()])

    let options = File.OpenOptions(
        access:File.Access.read(),
        creation:File.Creation.open_existing(),
        append:false
    )
    var input:OpenFile = try File.open(path, options)
    let bytes = try IO.read_to_end<OpenFile>(input, 1024)
    try File.close(move input)
    print("Read $(bytes.count()) bounded bytes")
    return Result<void, Error>.success()
}

func main() {
    match read_payload() {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
