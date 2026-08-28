# StyledStatus

[Back to the recipe catalog](../README.md).

```sx
use STD.Console

func main() {
    if !Console.is_interactive() {
        Console.write_line("Build: ready")
        return
    }
    Console.enable_style(Console.TextStyle.bold())
    Console.write("Build: ")
    Console.set_background(Console.Color.default())
    Console.set_foreground(Console.Color.green())
    Console.write_line("ready")
    Console.reset_style()

    if dimensions = Console.get_dimensions() {
        Console.write_line("Terminal: $(dimensions.columns) × $(dimensions.rows)")
    } else {
        Console.write_line("Output is redirected")
    }
}
```
