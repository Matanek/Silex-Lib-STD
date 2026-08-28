# Utiliser STD

STD est organisé par intention de développement. Choisissez le guide adapté,
puis partez d’une [recette complète](Recipes/README.md). Les tests portent le
contrat exécutable ; les recettes illustrent l’usage sans former un second
catalogue de validation.

| Intention | Modules | Guide |
| --- | --- | --- |
| Construire une application terminal | `Console`, `Console.Session` | [Console](Console.md) |
| Stocker, parcourir et transformer des valeurs | `Collections.*`, `Iterator`, `Algorithms.*` | [Collections](Collections.md), [Algorithmes](Algorithms.md) |
| Rechercher du texte structuré | `Regex` | [Expressions régulières](Regex.md) |
| Manipuler chemins, fichiers et dossiers | `Path`, `File`, `FileSystem`, `FileWatch`, `IO` | [Fichiers](Files.md) |
| Normaliser, segmenter et encoder Unicode | `Text.*` | [Texte](Text.md) |
| Décompresser sous une limite | `Compression` | [Compression](Compression.md) |
| Résoudre et communiquer sur le réseau | `Network.*` | [Réseau](Network.md) |
| Inspecter ou lancer des processus | `Process`, `Subprocess`, `System` | [Processus et cibles](Processes.md) |
| Ordonnancer du travail CPU | `Threading` | [Concurrence](Threading.md) |
| Mesurer et mettre le temps à l’échelle | `Time.*` | [Temps](Time.md) |
| Calculer des scalaires et valeurs graphiques | `Math` | [Mathématiques](Math.md) |
| Produire du hasard ou réordonner | `Randomizer`, `Algorithms.Random` | [Hasard](Randomness.md) |
| Hacher, dériver, chiffrer ou identifier | `Crypto.*`, `UUID` | [Cryptographie et identifiants](Crypto-and-identifiers.md) |
| Gérer les opérations faillibles | `Error`, `Result` | [Erreurs](Errors.md) |

La [matrice de couverture](Coverage.md) relie chaque module public intentionnel
à sa preuve exécutable. Les sources restent la référence exhaustive des
déclarations ; ces guides fixent propriété, erreurs, limites, ordre et
comportement de plateforme.
