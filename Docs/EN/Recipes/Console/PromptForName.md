# PromptForName

[Back to the recipe catalog](../README.md).

```sx
use STD.Console

func main() {
    Console.write("Your name: ")
    if name = Console.read_line() {
        Console.write_line("Hello, $(name)")
    } else {
        Console.write_error_line("No input was available")
    }
}
```
