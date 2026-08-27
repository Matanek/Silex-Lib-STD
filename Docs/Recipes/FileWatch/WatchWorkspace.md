# WatchWorkspace

[Retour au catalogue des recettes](../README.md).

```sx
use STD.FileWatch

func describe(event:FileWatch.Event) {
    match event {
        rescan_required => { print("rescan required") }
        change(kind, path) => {
            match kind {
                created => { print("created: " + path) }
                modified => { print("modified: " + path) }
                removed => { print("removed: " + path) }
                renamed => { print("renamed: " + path) }
                metadata => { print("metadata: " + path) }
            }
        }
    }
}

func main() {
    match FileWatch.open(".", FileWatch.Options(recursive:true)) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success(var watcher) => {
            match watcher.next(0) {
                failure(error) => { panic(error.operation + ": " + error.detail) }
                success(event) => { if value = event { describe(value) } }
            }
            watcher.close()
        }
    }
}
```
