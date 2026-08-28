# Collections

Les collections associatives et ordonnées partagent un modèle de parcours
explicite. Les itérateurs sont des snapshots consommateurs : les avancer ne
modifie pas la collection source.

## Dictionnaire

```sx
use STD.Collections.Dictionary

var scores = Dictionary<str, int>()
scores.set("Ada", 12)
scores.set("Linus", 9)

if scores.contains("Ada") {
    print(scores.get("Ada"))
}

if previous = scores.set("Ada", 14) {
    print("ancien score : $(previous)")
}
```

`set` rend l’ancienne valeur lorsqu’elle existait. `get`, `remove`,
`contains`, `reserve`, `clear`, `count` et `capacity` couvrent le cycle de vie.
L’itérateur expose des entrées clé/valeur :

```sx
var entries = scores.iterator()
while entry = entries.next() {
    print("$(entry.key): $(entry.value)")
}
```

Les snapshots séparés restent disponibles :

```sx
let names = scores.get_keys()
let points = scores.get_values()

for name in names { print(name) }
for point in points { print(point) }
```

Les clés intégrées utilisent leurs règles de hash/égalité. Un domaine peut
fournir des callbacks cohérents : deux clés égales doivent toujours partager
le même hash.

## Set, Queue et Stack

`Set` déduplique et `add` indique si la valeur était nouvelle.

```sx
use STD.Collections.Set

var tags = Set<str>()
if tags.add("network") {
    print("nouveau tag")
}
tags.add("network")

var values = tags.iterator()
while tag = values.next() { print(tag) }
```

`Queue` est FIFO :

```sx
use STD.Collections.Queue

var pending = Queue<str>()
pending.add("compile")
pending.add("test")

while task = pending.take() {
    print(task)
}
```

`Stack` est LIFO :

```sx
use STD.Collections.Stack

var history = Stack<str>()
history.add("open")
history.add("save")

while action = history.take() {
    print(action)
}
```

## Algorithmes d’itération

Les tableaux rendus par `get_values` peuvent entrer dans un `Iterator`, puis
être consommés par `Algorithms.Iteration`.

```sx
use STD.Algorithms.Iteration
use STD.Iterator

func passing(score:@int) bool {
    return score >= 10
}

let values = scores.get_values()
let count = Iteration.count_where<int>(
    Iterator.iterate<int>(values),
    passing
)
print(count)
```

Un itérateur de dictionnaire peut aussi être spécialisé directement sur son
type d’entrée imbriqué :

```sx
use STD.Collections.Dictionary.Entry

func passing(entry:@Entry<str, int>) bool {
    return entry.value >= 10
}

let count = Iteration.count_where<Entry<str, int>>(
    scores.iterator(),
    passing
)
```

Les recettes [Collections](Recipes/Collections/) couvrent mutation, règles de
clé, ordre FIFO/LIFO, déduplication, analyse et tri.
