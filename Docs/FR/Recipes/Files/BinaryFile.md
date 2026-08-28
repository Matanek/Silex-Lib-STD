# BinaryFile

[Retour au catalogue des recettes](../README.md).

```sx
use STD.File

func main() {
    let header:uint8[8] = [83, 73, 76, 69, 88, 0, 1, 0]
    match File.write_all("sample.silex-data", @header[0:header.count()]) {
        failure(error) => { panic(error.detail) }
        success => {}
    }
    match File.read_all("sample.silex-data", 1024) {
        failure(error) => { panic(error.detail) }
        success(bytes) => {
            print("Binary size: $(bytes.count())")
            print("Version: $(bytes[6]).$(bytes[7])")
        }
    }
}
```
