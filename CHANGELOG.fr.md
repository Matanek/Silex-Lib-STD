# Historique des changements

## [Unreleased]

- Les writes vers un stdin enfant fermé rendent `broken_pipe` sans SIGPIPE fatal ni fuite de handle. `Child.terminate(force:true)` permet d’arrêter un sous-processus bloqué ; le writer peut rester sur un worker pendant que le propriétaire draine les événements.

- Les instantanés `Dictionary.get_keys()` et `get_values()` conservent les
  identités partagées des classes, y compris `nocopy`, sans dupliquer leurs
  ressources. Le stockage des listes reste indépendant du dictionnaire.

- Adopte la déclaration `Result` unique : l’appel ordinaire rend la valeur
  ou arrête le programme sur erreur ; `try appel()` conserve le `Result`. Les
  anciens appels stockant un résultat et propagations deviennent explicites.
  Cette révision requiert la toolchain de développement avec cette sémantique
  de `try` ; sa publication doit coordonner les versions du compilateur et des
  packages.

- `Threading.Executor` déclare explicitement la création de son runtime propre avant de démarrer ses workers, conformément à l’initialisation des champs de classe dans un constructeur explicite.

- Ajouter l’assertion Regex négative sur un seul atome `(?!atom)`, sans
  consommer le texte, et les offsets explicites en octets des matches/captures.

- Ajouter `Collections.Dictionary.find(key)` : lecture optionnelle possédée,
  disponible sur un dictionnaire immuable, sans changer l’emprunt mutable `get`.
- Ajouter `Text.UTF8.byte_count(text)` pour mesurer les octets UTF-8 sans allouer
  une liste, y compris sur un texte emprunté et avec NUL incorporé.
