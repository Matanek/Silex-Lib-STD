# Networking

## Addresses and name resolution

`Network.parse_ip` accepts IPv4 and IPv6 text without performing DNS.
`format_ip` produces canonical text and `format_endpoint` includes the port,
IPv6 brackets and a scope id when present.

`resolve(host, port, options)` performs platform name resolution and returns
all matching endpoints. Choose `Family.any`, `ipv4` or `ipv6`, and state whether
the endpoint will carry `stream` or `datagram` traffic. Numeric hosts are
resolved locally. See [ResolveService.sx](Recipes/Network/ResolveService.md).

## TCP streams

`TCP.connect` accepts one endpoint or resolves a host. `ConnectOptions` separates
connection behavior from the resulting stream's read and write timeouts. A
`null` timeout waits according to the system default; negative timeouts are
invalid. Non-null connect timeouts are enforced by a small nonblocking socket
boundary on macOS ARM64, Linux x86-64, Windows x86-64 and Windows ARM64. The
unbounded path remains the direct system call and pays no polling overhead.

A `TCP.Stream` conforms to `IO.Reader` and `IO.Writer`. It exposes local and
peer endpoints plus independent read/write shutdown. Transfer ownership to
`TCP.close(move stream)` when finished. See
[TcpHealthCheck.sx](Recipes/Network/TcpHealthCheck.md).

Servers bind with `TCP.listen(endpoint, backlog)`, inspect their selected local
endpoint, and call `accept`. An accepted value carries both the owned stream
and the peer endpoint. Close the listener and every accepted stream explicitly.
See [TcpEchoServer.sx](Recipes/Network/TcpEchoServer.md).

## UDP datagrams

`UDP.open` creates an unbound socket for a concrete address family;
`UDP.bind` owns a local endpoint. `send_to` preserves datagram boundaries.
`receive_from` reports the sender, received byte count and whether the supplied
buffer truncated the datagram. See
[UdpAnnouncement.sx](Recipes/Network/UdpAnnouncement.md) and
[UdpReceiver.sx](Recipes/Network/UdpReceiver.md).

## TLS streams

`TLS.connect(host, port)` opens TCP and returns a certificate-verifying
`TLS.Stream` conforming to `IO.Reader` and `IO.Writer`. `TLS.ConnectOptions`
separates connect, read and write timeouts. The macOS provider
requires TLS 1.2 or newer and validates both the certificate chain and requested
host name against the system trust store. Close it explicitly with
`TLS.close(stream)`. See [TlsFetch.sx](Recipes/Network/TlsFetch.md).

Security-sensitive clients may resolve and validate a concrete endpoint before
calling `TLS.connect_endpoint(endpoint, host, options)`. The connection uses
that exact endpoint while `host` remains the certificate-verification and TLS
server-name identity. This avoids a second DNS resolution after an address
policy has approved the destination.

`TLS.open(transport, host)` instead takes ownership of an already-connected
`TCP.Stream` and performs the same certificate- and hostname-verifying
handshake. It supports protocols such as an HTTPS proxy tunnel without exposing
provider internals or permitting a cleartext fallback.

The current Linux and Windows fragments report `unsupported_platform` until
their certificate-verifying providers are implemented. They never disable
verification or replace an encrypted connection with cleartext. Applications
can inspect this capability with `TLS.available()`; see
[TlsAvailability.sx](Recipes/Network/TlsAvailability.md).

Socket operations are fallible and use `STD.Error`; TLS connection and trust
failures use `TLS.Error`. Name resolution, address families, certificate stores
and port availability depend on the selected runtime platform.
