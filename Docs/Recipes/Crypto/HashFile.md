# HashFile

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Crypto
use STD.File

func main() {
    match File.read_all("../Files/sample.silex-data", 16 * 1024 * 1024) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success(bytes) => {
            let view = @bytes[0:bytes.count()]
            print("SHA-256: $(Crypto.sha256(view))")
        }
    }
}
```
