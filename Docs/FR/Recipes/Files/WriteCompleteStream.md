# WriteCompleteStream

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Error
use STD.File
use STD.File.File as OpenFile
use STD.IO

func write_packet() Result<void, Error> {
    let options = File.OpenOptions(
        access:File.Access.write(),
        creation:File.Creation.create_or_truncate(),
        append:false
    )
    var output:OpenFile = try File.open("complete-packet.bin", options) else error { return Result<void,Error>.failure(error) }
    let packet:uint8[6] = [83, 73, 76, 69, 88, 10]
    try IO.write_all<OpenFile>(output, @packet[0:packet.count()]) else error { return Result<void,Error>.failure(error) }
    try output.flush() else error { return Result<void,Error>.failure(error) }
    try File.close(move output) else error { return Result<void,Error>.failure(error) }
    return Result<void, Error>.success()
}

func main() {
    match (try write_packet()) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => { print("Packet written completely") }
    }
}
```
