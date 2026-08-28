# Processus et cibles de compilation

`Process.arguments`, `current_directory` et `executable_path` sont faillibles.
`set_current_directory` modifie le processus entier : préférez des chemins
explicites dans une application concurrente.

`Subprocess.Command` fixe exécutable, arguments, dossier, environnement,
entrée standard et limite de capture. `run` attend et rend stdout, stderr et
un statut `exited` ou `signaled`. Le texte capturé reste des octets à décoder.

`spawn` ouvre un enfant interactif avec pipes séparés. Les écritures peuvent
être partielles, `next_event` attend un chunk ou la sortie et l’événement final
n’arrive qu’après drainage des deux flux. Détruire un enfant actif le termine
et le reap.

`spawn_terminal` utilise PTY sur macOS/Linux et ConPTY sur Windows. Les sorties
partagent le flux terminal et peuvent contenir ANSI/VT. L’API expose taille,
écriture, resize et événements sans handle natif.

`System.platform()` et `target()` décrivent la cible sélectionnée, pas
nécessairement l’hôte du compilateur. Voir les
[recettes processus](Recipes/Process/) et [subprocess](Recipes/Subprocess/).
