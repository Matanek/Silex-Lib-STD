# Erreurs de STD

Les API système faillibles rendent `Result<Value, STD.Error>`. Utilisez `try`
pour propager l’erreur ou `match` pour récupérer, réessayer, traduire ou
rapporter.

`Error` contient `kind`, catégorie portable telle que `not_found`,
`permission_denied`, `timed_out`, `invalid_data` ou `limit_exceeded` ;
`operation` ; un `subject` optionnel ; et `detail` lisible. Branchez le
comportement sur `kind` et affichez les autres champs. Ne parsez jamais
`detail`, qui n’est pas un contrat machine.

JSON conserve ses `ParseError` et `BuildError` plus précis, car position source
et grammaire appartiennent à ce domaine.
