# ResolveService

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Network

func main() {
    let options = Network.ResolveOptions(
        family:Network.Family.any(),
        transport:Network.Transport.stream()
    )
    match Network.resolve("localhost", 8080, options) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success(endpoints) => {
            for endpoint in endpoints { print(Network.format_endpoint(endpoint)) }
        }
    }
}
```
