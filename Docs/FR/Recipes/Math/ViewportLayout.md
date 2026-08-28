# ViewportLayout

[Retour au catalogue des recettes](../README.md).

```sx
use STD.Math

func main() {
    let window = Math.Rect(Math.Vec2(), Math.Vec2(1280.0, 720.0))
    let panel = Math.Rect(40.0, 40.0, 320.0, 180.0)
    let pointer = Math.Vec2(120.0, 90.0)
    print("Window center: $(window.center().x), $(window.center().y)")
    print("Pointer is over panel: $(panel.contains(pointer))")
    print("Fade at 75%: $(Math.smooth_step(0.0, 1.0, 0.75))")
}
```
