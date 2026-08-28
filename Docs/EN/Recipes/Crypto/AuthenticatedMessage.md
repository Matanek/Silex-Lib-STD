# AuthenticatedMessage

[Back to the recipe catalog](../README.md).

```sx
use STD.Crypto.ChaCha20Poly1305
use STD.Crypto.HKDF
use STD.Crypto.X25519
use STD.Crypto

func exchange() Result<void, Crypto.Error> {
    let alice = X25519.generate_key_pair()
    let bob = X25519.generate_key_pair()
    let alice_shared = try X25519.shared_secret(@alice.secret[0:32], @bob.public_key[0:32])
    let bob_shared = try X25519.shared_secret(@bob.secret[0:32], @alice.public_key[0:32])

    let salt:uint8[] = [115, 105, 108, 101, 120]
    let context:uint8[] = [100, 101, 109, 111]
    let alice_key = try HKDF.derive_sha256(
        @alice_shared[0:32],
        @salt[0:salt.count()],
        @context[0:context.count()],
        32
    )
    let bob_key = try HKDF.derive_sha256(
        @bob_shared[0:32],
        @salt[0:salt.count()],
        @context[0:context.count()],
        32
    )

    // A real protocol must never reuse a nonce with the same key.
    let nonce:uint8[12] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
    let associated:uint8[] = [99, 104, 97, 110, 110, 101, 108, 45, 49]
    let message:uint8[] = [104, 101, 108, 108, 111]
    let sealed = try ChaCha20Poly1305.seal(
        @alice_key[0:alice_key.count()],
        @nonce[0:12],
        @associated[0:associated.count()],
        @message[0:message.count()]
    )
    let opened = try ChaCha20Poly1305.open(
        @bob_key[0:bob_key.count()],
        @nonce[0:12],
        @associated[0:associated.count()],
        @sealed[0:sealed.count()]
    )

    assert(opened.count() == message.count())
    print("authenticated $(opened.count()) bytes")
    return Result<void, Crypto.Error>.success()
}

func main() {
    match exchange() {
        success => {}
        failure(error) => { panic(error.operation + ": " + error.detail) }
    }
}
```
