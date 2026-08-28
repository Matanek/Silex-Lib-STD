# TcpEchoServer

[Back to the recipe catalog](../README.md).

```sx
use STD.Error
use STD.IO
use STD.Network
use STD.Network.TCP
use STD.Network.TCP.Stream as TcpStream

func serve_once() Result<void, Error> {
    let address = try Network.parse_ip("127.0.0.1")
    let endpoint = Network.Endpoint(address:address, port:8080, scope_id:0)
    var listener = try TCP.listen(endpoint, 16)
    print("Listening on $(Network.format_endpoint(try TCP.local_endpoint(listener)))")
    var accepted = try TCP.accept(
        listener,
        null,
        TCP.StreamOptions(read_timeout_milliseconds:null, write_timeout_milliseconds:null)
    )
    var buffer:uint8[256]
    var view = &buffer[0:buffer.count()]
    let count = try accepted.stream.read(view)
    try IO.write_all<TcpStream>(accepted.stream, @view[0:count])
    try TCP.close(accepted.stream)
    return TCP.close(move listener)
}

func main() {
    match serve_once() {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
