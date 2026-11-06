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

Un appel `child.terminate()` demande l’arrêt (SIGTERM sur POSIX) ;
`child.terminate(force:true)` impose l’arrêt (SIGKILL sur POSIX, TerminateProcess
sur Windows). Il faut ensuite drainer les événements pour observer le statut
final ; la terminaison seule ne constitue pas une réussite de traitement.

`write_standard_input` peut bloquer et écrire partiellement. Pour alimenter un
processus lent sans bloquer l’application, un worker unique peut écrire stdin
pendant qu’un seul thread propriétaire appelle `next_event` et `terminate`.
Ces opérations portent sur des champs et handles distincts. Ne pas fermer stdin,
détruire l’enfant ni lancer plusieurs writers pendant une écriture ; attendre la
fence du writer avant `close_standard_input`. `complete()` peut aider l’executor :
collecter seulement après `fence().is_complete()` dans une boucle interactive.
Un pipe fermé rend `Error.Kind.broken_pipe` et ferme son handle ; sur POSIX,
l’écriture protège le thread contre SIGPIPE sans changer la disposition globale,
le masque initial ni un signal déjà en attente. Cette séparation ne rend pas
l’ensemble des méthodes de Child librement concurrent.

`spawn_terminal` utilise PTY sur macOS/Linux et ConPTY sur Windows. Les sorties
partagent le flux terminal et peuvent contenir ANSI/VT. L’API expose taille,
écriture, resize et événements sans handle natif.

`System.platform()` et `target()` décrivent la cible sélectionnée, pas
nécessairement l’hôte du compilateur. `target_name()` renvoie l’un des six noms
stables `macos-arm64`, `macos-x64`, `linux-arm64`, `linux-x64`,
`windows-arm64` ou `windows-x64`, sans exposer le triple du compilateur natif.
Voir les
[recettes processus](Recipes/Process/) et [subprocess](Recipes/Subprocess/).
