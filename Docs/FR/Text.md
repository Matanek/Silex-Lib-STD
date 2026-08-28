# Texte Unicode

Un `str` contient du UTF-8 valide. `STD.Text` fournit trim, recherche exacte,
remplacement, slice par scalaires, split, join et title case, de façon immutable
et indépendante de la locale.

`index_of` et `slice` comptent les scalaires Unicode. La recherche est sensible
à la casse ; `case_fold` crée une clé de comparaison stable. NFC, NFD, NFKC et
NFKD sont disponibles, les formes de compatibilité devant rester intentionnelles.

Les graphèmes représentent les caractères visibles et servent au curseur et à
la troncature. `Text.UTF8` franchit explicitement la frontière des octets et
rapporte la position invalide sans remplacement silencieux.

`Text.Encoding` gère UTF-8, UTF-16 et UTF-32 dans les byte orders applicables.
`encode_with_bom`, `detect_bom` et `decode` contrôlent BOM, longueur, séquences
et conflits avec une erreur structurée et un offset.

Voir [CleanNames](Recipes/Text/CleanNames.md),
[CountGraphemes](Recipes/Text/CountGraphemes.md) et
[DecodeDocument](Recipes/Text/DecodeDocument.md).
