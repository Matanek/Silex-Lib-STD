# ScaledClock

[Back to the recipe catalog](../README.md).

```sx
use STD.Time.Clock

func main() {
    var clock = Clock()
    clock.tick()
    clock.set_time_scale(0.5)
    let simulation_step = clock.tick()
    print("Simulation step: $(simulation_step)")
    clock.pause()
    print("Paused step: $(clock.tick())")
    clock.resume()
}
```
