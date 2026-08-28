# Concurrence CPU

`STD.Threading.Executor` possède un pool persistant. Les jobs sont des valeurs
typées, les handles possèdent leur résultat et les fences expriment la
dépendance sans occuper un worker en attente.

```sx
use STD.Threading

struct BuildIndex:Threading.Job {
    var count:int

    func execute() {
        self.count++
    }
}

var executor = Threading.Executor()
var handle = executor.submit(BuildIndex(count:41))
let completed = handle.complete()
assert(completed.count == 42)
```

`complete()` attend et consomme le résultat typé. Une fence peut être partagée
comme dépendance sans consommer ce résultat :

```sx
var load = executor.submit(LoadAssets(...))
var prepare = executor.submit(PrepareScene(...), after:load.fence())

prepare.fence().complete()
let loaded = load.complete()
let prepared = prepare.complete()
```

`combine` joint plusieurs branches et produit une fence collective :

```sx
var ready = executor.combine([
    geometry.fence(),
    textures.fence(),
    shaders.fence()
])
var upload = executor.submit(Upload(...), after:ready)
```

Le travail homogène se découpe en plages disjointes par un `ParallelJob` :

```sx
class Pixels {
    public var values:uint8[]
}

struct Invert:Threading.ParallelJob {
    var pixels:Pixels

    func execute(start:int, end:int) {
        var index = start
        while index < end {
            self.pixels.values[index] = 255 - self.pixels.values[index]
            index++
        }
    }
}

var done = executor.submit_parallel(
    pixels.values.count(),
    Invert(pixels:pixels)
)
done.complete()
```

Les plages ne doivent pas muter les mêmes éléments. L’executor reste propriétaire
de ses workers jusqu’à fermeture ou destruction et termine proprement les jobs
acceptés. `wait_idle` attend l’absence de travail sans remplacer les fences de
dépendance.

Voir les [recettes Threading](Recipes/Threading/).
