# Fichiers et chemins

`File.read_text(path, maximum_bytes)` valide UTF-8 et la limite. `read_all`
préserve les octets. `write_all` remplace et flush avant fermeture. La limite
doit refléter le domaine de l’application.

Pour les flux, `File.open` combine accès, création et append. Le handle
implémente `IO.Reader` et `IO.Writer` et se ferme avec `File.close(move file)`.
`IO.read_exact` exige un buffer complet, `read_to_end` impose une limite,
`write_all` répète les écritures courtes et `copy` effectue une copie bornée.
Les positions utilisent `SeekFrom.start`, `current` ou `end`.

`FileSystem` fournit métadonnées suivies ou directes, canonicalisation, liste,
création et suppression de dossiers, renommage, copie et readonly. La
suppression récursive reste une décision explicite de l’application.
`Path` valide, normalise, joint et décompose selon les règles de plateforme.

`FileWatch` possède un watcher natif récursif ou direct. `next` attend sous un
délai et rend création, modification, suppression, renommage, métadonnée ou
`null`. Les notifications sont des invalidations à relire ; `rescan_required`
impose de reconstruire le snapshot complet.

Les recettes correspondantes sont regroupées sous [Files](Recipes/Files/) et
[FileWatch](Recipes/FileWatch/WatchWorkspace.md).
