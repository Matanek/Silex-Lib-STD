# CleanNames

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Text

func main() {
    let raw = ["  ADA LOVELACE ", "grace hopper", "ÉMILIE du châtelet"]
    var clean:str[] = []
    for name in raw { clean.append(Text.titlecase(Text.trim(name))) }
    print(Text.join(clean, ", "))
}
```
