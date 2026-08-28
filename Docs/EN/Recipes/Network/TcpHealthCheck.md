# TcpHealthCheck

[Back to the recipe catalog](../README.md).

```sx
use STD.Error
use STD.Network
use STD.Network.TCP

func check(host:str, port:uint16) Result<void, Error> {
    let stream_options = TCP.StreamOptions(
        read_timeout_milliseconds:1000,
        write_timeout_milliseconds:1000
    )
    let options = TCP.ConnectOptions(
        connect_timeout_milliseconds:null,
        stream:stream_options
    )
    var stream = try TCP.connect(host, port, options)
    print("Connected to $(Network.format_endpoint(try stream.peer_endpoint()))")
    return TCP.close(move stream)
}

func main() {
    match check("127.0.0.1", 8080) {
        failure(error) => { print("Unavailable: $(error.detail)") }
        success => { print("Service is reachable") }
    }
}
```
