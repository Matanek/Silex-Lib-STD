# Historique des changements

## [Unreleased]

- Ajouter l’assertion Regex négative sur un seul atome `(?!atom)`, sans
  consommer le texte, et les offsets explicites en octets des matches/captures.

- Ajouter `Collections.Dictionary.find(key)` : lecture optionnelle possédée,
  disponible sur un dictionnaire immuable, sans changer l’emprunt mutable `get`.
- Ajouter `Text.UTF8.byte_count(text)` pour mesurer les octets UTF-8 sans allouer
  une liste, y compris sur un texte emprunté et avec NUL incorporé.
