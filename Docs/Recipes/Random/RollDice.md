# RollDice

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Randomizer

func main() {
    var randomizer = Randomizer()
    for roll in 0...5 {
        print("d6: $(randomizer.get_int(1, 7))")
    }
    print("Probability sample: $(randomizer.get_float())")
}
```
