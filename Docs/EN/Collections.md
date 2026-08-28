# Collections

STD complète les tableaux et listes du langage avec quatre collections :

- `Dictionary<Key, Value>` associe une valeur à chaque clé unique ;
- `Set<T>` conserve des valeurs uniques ;
- `Queue<T>` restitue d'abord la valeur ajoutée en premier ;
- `Stack<T>` restitue d'abord la valeur ajoutée en dernier.

Chaque collection expose `count()`, `is_empty()`, `contains(...)`,
`reserve(...)`, `clear()` et `iterator()`. Un itérateur est consommable : chaque
appel à `next()` avance et renvoie la prochaine valeur, ou `null` lorsque le
parcours est terminé.

## Associer des clés et des valeurs

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

`set(key, value)` renvoie l'ancienne valeur lorsqu'il remplace une association,
et `null` lorsqu'il ajoute une nouvelle clé. `get(key)` emprunte la valeur
stockée et exige que la clé existe ; utiliser `contains(key)` lorsque son
absence est normale. `remove(key)` renvoie `true` seulement si une association
a été supprimée. `find_key(value)` effectue la recherche inverse et renvoie la
première clé correspondante, ou `null`. Cette recherche parcourt les valeurs ;
un second dictionnaire est préférable lorsque la recherche inverse est une
opération fréquente.

Le constructeur accepte `minimum_capacity` pour éviter des réallocations
prévisibles. Des fonctions de hachage et d'égalité personnalisées sont aussi
acceptées, mais le comportement par défaut convient aux types usuels. Deux clés
considérées égales doivent toujours produire le même hachage.

## Parcourir un dictionnaire

Utiliser `iterator()` lorsqu'une opération porte sur les associations :

```sx
var entries = scores.iterator()
while entry = entries.next() {
    print("$(entry.key): $(entry.value)")
}
```

Chaque élément est un `Entry<Key, Value>` copié. Réassigner ses champs ne
modifie donc pas l'association stockée. Une valeur de type classe conserve son
identité partagée habituelle : modifier l'objet reste observable depuis les
autres références. L'ordre de parcours n'est pas un contrat : il peut changer
après une insertion, une suppression ou une évolution de l'implémentation.

Pour obtenir uniquement les clés ou uniquement les valeurs :

```sx
let names = scores.get_keys()
let points = scores.get_values()

for name in names { print(name) }
for point in points { print(point) }
```

`get_keys()` et `get_values()` renvoient des listes indépendantes de la
collection. Vider ou réordonner ces listes ne modifie pas le dictionnaire. Les
objets de classe qu'elles contiennent conservent toutefois leur identité
partagée. Ces instantanés sont pratiques pour transmettre des valeurs à une API
qui attend une liste. Préférer `iterator()` pour traiter directement les
associations et éviter de perdre le lien entre une clé et sa valeur.

## Valeurs uniques

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

`add(value)` renvoie `true` seulement lors d'une nouvelle insertion.
`remove(value)` renvoie `true` seulement lorsqu'une valeur était présente.
Comme pour `Dictionary`, l'ordre du parcours n'est pas garanti.

## File d'attente

```sx
use STD.Collections.Queue

var pending = Queue<str>()
pending.add("compile")
pending.add("test")

while task = pending.take() {
    print(task)
}
```

`peek()` emprunte la prochaine valeur sans la retirer et exige que la file ne
soit pas vide. `take()` retire la prochaine valeur et renvoie `null` lorsque la
file est vide. `remove(value)` retire la plus ancienne occurrence
correspondante. `iterator()` parcourt les valeurs dans le même ordre que des
appels successifs à `take()`, sans modifier la file.

## Pile

```sx
use STD.Collections.Stack

var history = Stack<str>()
history.add("open")
history.add("save")

while action = history.take() {
    print(action)
}
```

`peek()` emprunte la dernière valeur ajoutée sans la retirer. `take()` la
retire et renvoie `null` lorsque la pile est vide. `remove(value)` retire
l'occurrence correspondante la plus récemment ajoutée. `iterator()` suit ce
même ordre, sans modifier la pile.

## Traiter un itérateur avec un algorithme

`STD.Algorithms.Iteration` fournit `any`, `all`, `count_where`, `find`,
`contains`, `map` et `filter`. Ces fonctions consomment l'itérateur reçu :

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

`map` et `filter` renvoient un nouvel itérateur. Conserver l'itérateur dans une
variable lorsque plusieurs appels à `next()` sont nécessaires ; recréer un
itérateur pour recommencer un parcours depuis le début.

Les algorithmes acceptent directement les types génériques imbriqués. Pour
traiter les associations plutôt qu'un instantané de valeurs :

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

Le compilateur accepte aussi l'inférence avec
`Iteration.count_where(scores.iterator(), passing)`. La forme explicite est
utile lorsque le type d'entrée constitue une information importante pour le
lecteur. Voir
[CountPassingEntries.sx](Recipes/Collections/CountPassingEntries.md).
