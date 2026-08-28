# Réseau

`Network.parse_ip` traite IPv4/IPv6 sans DNS. `resolve` effectue la résolution
de plateforme avec famille et type de transport explicites. Les endpoints
formatés conservent brackets IPv6 et scope.

`TCP.connect` accepte endpoint ou hôte. Les options distinguent connexion,
lecture et écriture. Un `TCP.Stream` implémente `IO.Reader` et `IO.Writer`,
expose endpoints et demi-fermeture, puis transfère sa propriété à
`TCP.close(move stream)`. Les serveurs utilisent `listen` et `accept`.

`UDP.open` ouvre une famille et `UDP.bind` possède un endpoint. `send_to`
préserve les datagrammes ; `receive_from` rend expéditeur, taille et indicateur
de troncature.

`TLS.connect` retourne un flux qui vérifie certificat et hostname. Une variante
endpoint conserve l’hôte pour SNI et vérification après validation d’adresse.
`TLS.open` prend possession d’un TCP déjà connecté. Linux et Windows rendent
actuellement `unsupported_platform` tant qu’un fournisseur vérifiant n’est pas
disponible ; aucune rétrogradation en clair n’a lieu. `TLS.available()` expose
la capacité.

Voir les [recettes réseau](Recipes/Network/).
