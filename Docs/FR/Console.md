# Applications console

`Console.write_line` écrit sur la sortie standard et `write_error_line` sur
l’erreur standard. Les formes sans `_line` n’ajoutent pas de saut de ligne.
`get_dimensions()` rend `null` si la taille du terminal est indisponible.

`read_line()` rend une ligne UTF-8 sans son saut, ou `null` si l’entrée se
termine avant tout octet. Une entrée UTF-8 invalide est une erreur fatale de
programme. `wait_for_enter()` couvre la confirmation simple.

`Console.Session` possède le mode interactif précédent jusqu’à `close()` ou sa
destruction, qui restaurent style, curseur et saisie. `read_key()` attend,
`poll_key` impose un délai et `poll_keys` attend un premier événement puis vide
un lot borné. Les événements distinguent caractères, navigation, édition,
fonctions et séquences inconnues avec Shift, Control et Alt.

Les recettes [StyledStatus](Recipes/Console/StyledStatus.md),
[PromptForName](Recipes/Console/PromptForName.md) et
[SessionKeyViewer](Recipes/Console/SessionKeyViewer.md) couvrent ces parcours.
