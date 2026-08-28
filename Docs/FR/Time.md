# Temps

`LocalTime.now()` lit l’heure civile du fuseau système sur macOS, Linux et
Windows. Ses champs conviennent aux affichages utilisateur, pas aux durées.

`Stopwatch` mesure un temps monotone. `start` et `stop` sont idempotents,
`reset` efface et arrête, `restart` efface et démarre. Les valeurs restent
lisibles pendant et après la mesure.

`Clock` convertit le monotone en temps d’application. Le premier `tick()`
initialise et rend zéro. Les suivants rendent le pas mis à l’échelle et
accumulent le total. Une clock en pause rend zéro. Une échelle négative fait
volontairement reculer le temps et doit être validée par les applications qui
ne le permettent pas.

Voir [ReadLocalTime](Recipes/Time/ReadLocalTime.md),
[MeasureOperation](Recipes/Time/MeasureOperation.md) et
[ScaledClock](Recipes/Time/ScaledClock.md).
