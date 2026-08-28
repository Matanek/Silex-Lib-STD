# Octets cryptographiques et identifiants

`Crypto.md5`, `sha1` et `sha256` hachent texte UTF-8 ou octets et rendent de
l’hexadécimal minuscule. Les variantes `_bytes` rendent des digests binaires.
MD5 et SHA-1 servent à la compatibilité, pas à résister aux collisions choisies.
Aucune de ces fonctions ne stocke correctement un mot de passe.

`Crypto.random_bytes` lit l’entropie système. X25519 construit un secret
partagé, HKDF-SHA256 dérive du matériel propre à un contexte et
ChaCha20-Poly1305 chiffre et authentifie avec données associées. Ce sont des
briques de protocole : authentifiez les clés, séparez les contextes et ne
réutilisez jamais un nonce de 12 octets avec la même clé. Pour une session
complète, préférez `Sync.SecureSession`.

`UUID.v4()` crée un identifiant opaque aléatoire. `UUID.v7()` préfixe le hasard
par le timestamp Unix en millisecondes pour préserver la localité temporelle.
`to_str()` est canonique en minuscules et `to_bytes()` conserve 16 octets.
Un UUID identifie une valeur, mais n’authentifie rien.

Voir les recettes [AuthenticatedMessage](Recipes/Crypto/AuthenticatedMessage.md)
et [CreateIdentifiers](Recipes/UUID/CreateIdentifiers.md).
