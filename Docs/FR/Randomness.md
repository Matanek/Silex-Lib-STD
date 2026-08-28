# Hasard

`Randomizer()` initialise une séquence pseudo-aléatoire depuis le système. Une
seed numérique produit une séquence répétable pour tests, simulations et
contenu procédural.

`get_int` et `get_float` utilisent un intervalle semi-ouvert et exigent
`minimum < maximum`. `get_bool()` produit un booléen non biaisé.
`Algorithms.Random.choose` emprunte une valeur d’une slice non vide et
`shuffle` la réordonne en place.

`Randomizer` n’est pas cryptographique. Tokens, clés et sels doivent provenir
de `Crypto.random_bytes`. Voir [RollDice](Recipes/Random/RollDice.md) et
[ShufflePlaylist](Recipes/Random/ShufflePlaylist.md).
