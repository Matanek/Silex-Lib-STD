# Compression

`STD.Compression` décompresse des flux deflate brut, gzip et zlib sous une
limite explicite choisie par l’appelant.

```sx
use STD.Compression

let decoded = try Compression.decompress(
    compressed,
    Compression.Format.gzip,
    8 * 1024 * 1024
)
```

La limite par défaut est de 16 Mio. Le stockage grandit géométriquement jusqu’à
cette borne. Flux vide ou malformé et checksum invalide rendent
`STD.Error.Kind.invalid_data` ; dépasser la borne rend `limit_exceeded`. Aucun
résultat partiel n’est exposé.

La même API et la frontière distribuée couvrent macOS ARM64, Linux x64,
Windows x64 et Windows ARM64. Le module décompresse seulement et n’essaie
jamais de deviner le format depuis des octets non fiables.
