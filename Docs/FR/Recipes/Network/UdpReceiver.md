# UdpReceiver

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Error
use STD.Network
use STD.Network.UDP
use STD.Text.UTF8

func receive_once() Result<void, Error> {
    let address = try Network.parse_ip("127.0.0.1") else error { return Result<void,Error>.failure(error) }
    let endpoint = Network.Endpoint(address:address, port:9000, scope_id:0)
    let options = UDP.Options(read_timeout_milliseconds:null, write_timeout_milliseconds:null)
    var socket = try UDP.bind(endpoint, options) else error { return Result<void,Error>.failure(error) }
    var buffer:uint8[256]
    var view = &buffer[0:buffer.count()]
    let received = try UDP.receive_from(socket, view) else error { return Result<void,Error>.failure(error) }
    if received.truncated { panic("Datagram exceeded the receive buffer") }
    match (try UTF8.decode(@view[0:received.count])) {
        failure(error) => { panic("Datagram was not UTF-8") }
        success(text) => { print("$(Network.format_endpoint(received.sender)): $(text)") }
    }
    return (try UDP.close(move socket))
}

func main() {
    match (try receive_once()) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }
}
```
