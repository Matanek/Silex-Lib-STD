# Historique des changements

## [0.23.0] - 2026-11-08

- Reconnaître les fichiers Windows ordinaires même lorsque leurs attributs archive ou lecture seule remplacent l’attribut NORMAL. Les métadonnées et listes de dossiers conservent le type fichier.

- Corriger la lecture des dossiers et modes de fichiers sur Linux ARM64, ainsi que les bindings inode 64 bits de macOS Intel. Les chemins temporaires Windows sont comparés après normalisation de leurs séparateurs.

- Créer des dossiers temporaires exclusifs et régler le droit d’exécution du propriétaire des fichiers POSIX ; Windows signale explicitement que ce droit n’existe pas.

- Calculer les hashes de chaînes par une quantité fixe de travail arithmétique par octet UTF-8, sans changer les valeurs FNV-1a 64 bits, y compris les octets nuls.

- Les lectures et écritures File utilisent des blocs natifs bornés au lieu d’un appel système par octet, en conservant les signatures, EOF, lectures partielles et erreurs.

- Les writes vers un stdin enfant fermé rendent `broken_pipe` sans SIGPIPE fatal ni fuite de handle. `Child.terminate(force:true)` permet d’arrêter un sous-processus bloqué ; le writer peut rester sur un worker pendant que le propriétaire draine les événements.

- Les instantanés `Dictionary.get_keys()` et `get_values()` conservent les
  identités partagées des classes, y compris `nocopy`, sans dupliquer leurs
  ressources. Le stockage des listes reste indépendant du dictionnaire.

- Adopte la déclaration `Result` unique : l’appel ordinaire rend la valeur
  ou arrête le programme sur erreur ; `try appel()` conserve le `Result`. Les
  anciens appels stockant un résultat et propagations deviennent explicites.
  Cette version requiert Silex 0.48.0 ou supérieur et les versions coordonnées
  de ses dépendances.

- `Threading.Executor` déclare explicitement la création de son runtime propre avant de démarrer ses workers, conformément à l’initialisation des champs de classe dans un constructeur explicite.

- Ajouter l’assertion Regex négative sur un seul atome `(?!atom)`, sans
  consommer le texte, et les offsets explicites en octets des matches/captures.

- Ajouter `Collections.Dictionary.find(key)` : lecture optionnelle possédée,
  disponible sur un dictionnaire immuable, sans changer l’emprunt mutable `get`.
- Ajouter `Text.UTF8.byte_count(text)` pour mesurer les octets UTF-8 sans allouer
  une liste, y compris sur un texte emprunté et avec NUL incorporé.
