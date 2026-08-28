# ReadWriteText

[Retour au catalogue des recettes](../README.md).

```sx
use STD.File

func main() {
    let path = "silex-note.txt"
    match File.write_all(path, "A small reusable Silex note.\n") {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success => {}
    }

    match File.read_text(path, 4096) {
        failure(error) => { panic(error.operation + ": " + error.detail) }
        success(content) => { print(content) }
    }
}
```
