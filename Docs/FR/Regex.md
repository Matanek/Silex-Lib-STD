# Expressions régulières

`STD.Regex` compile une expression avec erreurs structurées et fournit des
opérations nommées selon l’intention : `match` pour le texte complet,
`contains`, `first`, `find`, `all`, `split` et remplacement.

```sx
use STD.Regex

let identifier = Regex.compile("[A-Za-z_][A-Za-z0-9_]*")
if identifier.match("silex_value") { print("valid identifier") }
```

La recherche est leftmost-first. `find` rend un itérateur paresseux :

```sx
for found in expression.find(text) { print(found.text()) }

var cursor = expression.find(text)
while found = cursor.next() { print(found.text()) }
```

Le moteur gère classes Unicode, limites de mots, quantificateurs greedy/lazy,
groupes numérotés, nommés ou non capturants, options case/multiline/dot-all et
progression sûre après une correspondance vide. Les bornes finies restent
compactes pour les grands textes.

Les presets compilés et mis en cache couvrent chiffres Unicode, email, IPv4 et
IPv6 :

```sx
let email = Regex.Presets.email()
if email.contains(message) { print("an email address is present") }

if Regex.Presets.ipv4().match("192.168.1.20") { print("valid IPv4") }
if Regex.Presets.ipv6().match("2001:db8::38") { print("valid IPv6") }
if Regex.Presets.digit().match("７") { print("one Unicode digit") }
```

Les captures gardent leur texte et leur position :

```sx
let pair = Regex.compile("(?<key>\\w+)=(?<value>\\w+)")
if found = pair.first("language=Silex") {
    if value = found.capture("value") { print(value.text()) }
}
```

Le remplacement accepte texte littéral ou callback. Voir les
[recettes Regex](Recipes/Regex/).

## Assertions négatives et unités des positions

`(?!atom)` réussit si le scalaire suivant ne correspond pas à l’atome, sans
consommer le texte. L’atome peut être un caractère littéral, `.` ou une classe
comme `\S`, `[a-z]` ou `\p{L}`. En fin de texte, l’assertion réussit. Les options
de casse et de dot-all s’appliquent aussi dans l’assertion. Une séquence, un
quantificateur ou un groupe capturant dans cette assertion rend
`unsupported_construct` ; les assertions positives, lookbehind et références
arrière restent non supportées. Cette forme bornée garde le coût prévisible du
moteur ; le profil GPT-2 `\s+(?!\S)` peut ainsi conserver les blancs exactement.

`Match.start/end` et `Capture.start/end` comptent les scalaires Unicode.
`byte_start/byte_end` donnent des intervalles `[start, end)` en octets UTF-8,
sur le texte source du match. Par exemple, `é+` dans `🙂éé!` couvre les scalaires
`[1, 3)` et les octets `[4, 8)`. Ces bornes sont lisibles depuis un consommateur
extérieur, sans exposer les tables du moteur.
