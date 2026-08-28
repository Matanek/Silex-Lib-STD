# Expressions régulières

`STD.Regex` compile une expression avec erreurs structurées et fournit des
opérations nommées selon l’intention : `match` pour le texte complet,
`contains`, `first`, `find`, `all`, `split` et remplacement.

```sx
use STD.Regex

let identifier = try Regex.compile("[A-Za-z_][A-Za-z0-9_]*")
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
let pair = try Regex.compile("(?<key>\\w+)=(?<value>\\w+)")
if found = pair.first("language=Silex") {
    if value = found.capture("value") { print(value.text()) }
}
```

Le remplacement accepte texte littéral ou callback. Voir les
[recettes Regex](Recipes/Regex/).
