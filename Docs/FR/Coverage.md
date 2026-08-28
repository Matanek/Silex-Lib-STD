# Couverture de l’API publique

STD est couvert lorsque chaque module public intentionnel possède un guide,
chaque opération publique est appelée par un test ou consommateur compilé,
chaque parcours structurel franchit sa vraie frontière et les chemins
interactifs sont au moins compilés lorsque l’automatisation ne peut les piloter.

Les membres héritent la visibilité de leur type. Les implémentations de
protocoles portées par des types package-visible restent privées ; les
consommateurs utilisent par exemple `STD.Crypto`, pas ses moteurs de digest.

La matrice anglaise miroir détaille, pour chaque surface, opérations,
consommateurs et tests. Elle couvre algorithmes, collections, console,
compression, cryptographie, erreurs, fichiers, IO, filesystem, file watch,
regex, texte, math, réseau, processus, hasard, threading, temps et UUID. Tout
ajout public doit compléter ce triplet guide–consommateur–preuve.

Depuis la racine du workspace :

```sh
./silex-dev test-std
```

La commande exécute la suite STD et compile tous les consommateurs. Les tests
loopback peuvent demander un environnement qui autorise les sockets locales ;
le catalogue des recettes indique les prérequis externes.
