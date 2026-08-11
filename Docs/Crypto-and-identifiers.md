# Cryptographic bytes and identifiers

`Crypto.md5`, `sha1` and `sha256` hash either UTF-8 text or borrowed bytes and
return lowercase hexadecimal. Their `_bytes` counterparts return fixed-size
binary digests. MD5 and SHA-1 are compatibility hashes, not collision-resistant
choices for adversarial input. None of these functions stores passwords safely.

`Crypto.random_bytes(count)` reads system entropy and is appropriate for
application secrets when the surrounding protocol uses raw random bytes
correctly. Negative counts are rejected. See
[ContentFingerprint.sx](../Examples/Crypto/ContentFingerprint.sx).

`UUID.v4()` produces an opaque random identifier. `UUID.v7()` prefixes random
data with a Unix-millisecond timestamp and is useful when creation-order
locality matters. `to_str()` returns canonical lowercase text; `to_bytes()` and
the byte constructor preserve an exact 16-byte representation. UUIDs identify
values but are not authentication tokens. See
[CreateIdentifiers.sx](../Examples/UUID/CreateIdentifiers.sx).
