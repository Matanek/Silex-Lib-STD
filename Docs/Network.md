# Networking

## Addresses and name resolution

`Network.parse_ip` accepts IPv4 and IPv6 text without performing DNS.
`format_ip` produces canonical text and `format_endpoint` includes the port,
IPv6 brackets and a scope id when present.

`resolve(host, port, options)` performs platform name resolution and returns
all matching endpoints. Choose `Family.any`, `ipv4` or `ipv6`, and state whether
the endpoint will carry `stream` or `datagram` traffic. Numeric hosts are
resolved locally. See [ResolveService.sx](../Examples/Network/ResolveService.sx).

## TCP streams

`TCP.connect` accepts one endpoint or resolves a host. `ConnectOptions` separates
connection behavior from the resulting stream's read and write timeouts. A
`null` timeout waits according to the system default; negative timeouts are
invalid. The bootstrap backend does not yet implement non-null connect
timeouts and returns `unsupported` rather than silently ignoring them.

A `TCP.Stream` conforms to `IO.Reader` and `IO.Writer`. It exposes local and
peer endpoints plus independent read/write shutdown. Transfer ownership to
`TCP.close(move stream)` when finished. See
[TcpHealthCheck.sx](../Examples/Network/TcpHealthCheck.sx).

Servers bind with `TCP.listen(endpoint, backlog)`, inspect their selected local
endpoint, and call `accept`. An accepted value carries both the owned stream
and the peer endpoint. Close the listener and every accepted stream explicitly.
See [TcpEchoServer.sx](../Examples/Network/TcpEchoServer.sx).

## UDP datagrams

`UDP.open` creates an unbound socket for a concrete address family;
`UDP.bind` owns a local endpoint. `send_to` preserves datagram boundaries.
`receive_from` reports the sender, received byte count and whether the supplied
buffer truncated the datagram. See
[UdpAnnouncement.sx](../Examples/Network/UdpAnnouncement.sx) and
[UdpReceiver.sx](../Examples/Network/UdpReceiver.sx).

Socket operations are fallible and use `STD.Error`. Name resolution, address
families and port availability depend on the selected runtime platform.
