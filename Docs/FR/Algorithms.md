# Itérateurs et algorithmes

`Iterator<T>` est une séquence finie et consommatrice. `next()` avance et rend
`T?` ; `remaining()` et `is_empty()` décrivent le suffixe restant. Tableaux et
slices entrent dans ce modèle avec `Iterator.iterate`.

`Algorithms.Iteration` consomme l’itérateur reçu : `any`, `all`, `count_where`,
`find`, `contains`, `map` et `filter`. Créez un nouvel itérateur pour répéter un
parcours. Les collections rendent des snapshots, donc leur parcours ne les
modifie pas.

`Algorithms.Sort.sort` trie une slice mutable en place avec un ordre strict.
`Algorithms.Random.choose` exige une slice non vide et `shuffle` la réordonne
en place. Les méthodes d’extension de `Randomizer` exposent les mêmes intentions.

Voir [AnalyzeValues](Recipes/Collections/AnalyzeValues.md) et
[SortLeaderboard](Recipes/Collections/SortLeaderboard.md).
