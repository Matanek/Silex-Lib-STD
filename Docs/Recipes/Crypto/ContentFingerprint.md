# ContentFingerprint

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Crypto

func main() {
    let content = "Silex standard library"
    print("SHA-256: $(Crypto.sha256(content))")
    let token = Crypto.random_bytes(24)
    print("Random token bytes: $(token.count())")
}
```
