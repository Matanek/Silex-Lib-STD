# UdpAnnouncement

[Back to the recipe catalog](../README.md).

```sx
use STD.Error
use STD.Network
use STD.Network.UDP
use STD.Text.UTF8

func announce() Result<void, Error> {
    let address = try Network.parse_ip("127.0.0.1") else error { return Result<void,Error>.failure(error) }
    let endpoint = Network.Endpoint(address:address, port:9000, scope_id:0)
    let options = UDP.Options(read_timeout_milliseconds:null, write_timeout_milliseconds:1000)
    var socket = try UDP.open(Network.Family.ipv4(), options) else error { return Result<void,Error>.failure(error) }
    let message = UTF8.bytes("Silex service online")
    try UDP.send_to(socket, @message[0:message.count()], endpoint) else error { return Result<void,Error>.failure(error) }
    return (try UDP.close(move socket))
}

func main() {
    match (try announce()) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => { print("Announcement sent") }
    }
}
```
