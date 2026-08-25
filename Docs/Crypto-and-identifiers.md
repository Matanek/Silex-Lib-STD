# Cryptographic bytes and identifiers

`Crypto.md5`, `sha1` and `sha256` hash either UTF-8 text or borrowed bytes and
return lowercase hexadecimal. Their `_bytes` counterparts return fixed-size
binary digests. MD5 and SHA-1 are compatibility hashes, not collision-resistant
choices for adversarial input. None of these functions stores passwords safely.

`Crypto.random_bytes(count)` reads system entropy and is appropriate for
application secrets when the surrounding protocol uses raw random bytes
correctly. Negative counts are rejected. See
[ContentFingerprint.sx](../Examples/Crypto/ContentFingerprint.sx).

`Crypto.X25519` creates ephemeral key pairs and derives a shared secret from a
local secret key and a peer public key. `Crypto.HKDF.derive_sha256` turns that
shared secret into purpose-specific key material. `Crypto.ChaCha20Poly1305`
seals and opens bytes with authenticated associated data; `open` reports
`Crypto.ErrorKind.authentication_failed` when the ciphertext, tag, nonce or
associated data does not authenticate.

These are protocol-building primitives, not a complete secure channel. A
protocol must authenticate the peer keys, separate derivation contexts, erase
or rotate secrets according to its threat model and never reuse a 12-byte
ChaCha20-Poly1305 nonce with the same key. Applications that only need a secure
Sync connection should use `Sync.SecureSession` instead of assembling these
operations directly. See
[AuthenticatedMessage.sx](../Examples/Crypto/AuthenticatedMessage.sx) for the
smallest complete exchange.

`UUID.v4()` produces an opaque random identifier. `UUID.v7()` prefixes random
data with a Unix-millisecond timestamp and is useful when creation-order
locality matters. `to_str()` returns canonical lowercase text; `to_bytes()` and
the byte constructor preserve an exact 16-byte representation. UUIDs identify
values but are not authentication tokens. See
[CreateIdentifiers.sx](../Examples/UUID/CreateIdentifiers.sx).
