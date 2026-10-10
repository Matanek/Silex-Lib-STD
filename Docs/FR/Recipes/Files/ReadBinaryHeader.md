# ReadBinaryHeader

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Error
use STD.File
use STD.File.File as OpenFile
use STD.IO

func inspect_header() Result<void, Error> {
    let path = "image-header.bin"
    let sample:uint8[4] = [83, 88, 1, 0]
    try File.write_all(path, @sample[0:sample.count()]) else error { return Result<void,Error>.failure(error) }

    let options = File.OpenOptions(
        access:File.Access.read(),
        creation:File.Creation.open_existing(),
        append:false
    )
    var input:OpenFile = try File.open(path, options) else error { return Result<void,Error>.failure(error) }
    var header:uint8[2] = [0, 0]
    try IO.read_exact<OpenFile>(input, &header[0:header.count()]) else error { return Result<void,Error>.failure(error) }
    try File.close(move input) else error { return Result<void,Error>.failure(error) }
    print("Signature: $(header[0]), $(header[1])")
    return Result<void, Error>.success()
}

func main() {
    match (try inspect_header()) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
