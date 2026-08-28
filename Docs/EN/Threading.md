# Threading

`STD.Threading` exprime un travail CPU fini avec cinq concepts publics :
`Job`, `ParallelJob`, `Executor`, `JobHandle<T>` et `Fence`.

```sx
use STD.Threading

struct BuildIndex:Threading.Job {
    var count:int

    func execute() {
        self.count++
    }
}

var executor = Threading.Executor()
var handle = executor.submit(BuildIndex(count:41))
let completed = handle.complete()
assert(completed.count == 42)
```

`Executor()` réserve par défaut un worker de moins que le nombre de processeurs
logiques, avec un minimum d'un worker. `Executor(worker_count:1)` permet de
fixer explicitement ce coût. Les workers vivent aussi longtemps que
l'exécuteur ; soumettre un job ne crée pas de thread système.

`submit` transfère le job et l'exécute exactement une fois. `complete` attend
sa publication, peut exécuter un autre job prêt pendant l'attente, puis rend le
job terminé exactement une fois. Le résultat ou l'erreur récupérable appartient
donc aux champs du job. Une seconde consommation est une erreur de programme.

`JobHandle<T>.fence()` produit une vue clonable de la même complétion sans
consommer le résultat. `Fence.is_complete()` observe l'état sans bloquer et
`Fence.complete()` attend seulement sa publication :

```sx
var load = executor.submit(LoadAssets(...))
var prepare = executor.submit(PrepareScene(...), after:load.fence())

prepare.fence().complete()
let loaded = load.complete()
let prepared = prepare.complete()
```

Une dépendance retarde la publication du job dans la file prête ; elle
n'immobilise donc aucun worker. Plusieurs fences peuvent être passées
directement, ou réunies sans créer de job vide :

```sx
var ready = executor.combine([
    geometry.fence(),
    textures.fence(),
    shaders.fence()
])
var upload = executor.submit(Upload(...), after:ready)
```

`combine([])` produit une fence déjà terminée. Un job soumis avec
`after:@Fence[]` devient prêt après la dernière entrée, y compris lorsque
certaines sont déjà terminées. Comme une dépendance ne peut être ajoutée
qu'au moment de la soumission, ce graphe reste acyclique par construction.

La complétion d'une fence publie toutes les écritures de ses prédécesseurs aux
jobs descendants. Une attente lancée par le thread propriétaire ou par un
worker du même exécuteur aide à exécuter les jobs prêts ; un worker ne bloque
donc pas tous ses pairs en attendant un descendant encore exécutable. Une
fence issue d'un autre exécuteur conserve au contraire l'isolation de leurs
files.

Abandonner un `JobHandle` ne bloque pas et n'annule pas son job. La destruction
du dernier `Executor` refuse les nouvelles soumissions, termine les jobs déjà
acceptés, réveille et rejoint ses workers. Un job doit posséder ses valeurs ou
conserver des classes partagées ; il ne peut pas laisser survivre une référence
empruntée à sa portée.

Après avoir atteint son nombre maximal de soumissions simultanément vivantes,
l'exécuteur réutilise les états typés, les entrées de file et les signaux déjà
préparés. Une charge équivalente ou plus faible ne réalise donc plus une
allocation générale par `submit`. Un nouveau type de job ou un nouveau pic de
charge peut encore faire croître ces réserves.

Un emplacement terminé reste protégé tant qu'un handle, ou l'une de ses copies,
peut encore observer son résultat. Une consommation transfère ce résultat une
seule fois ; un handle abandonné libère sa vue sans annuler le travail. Une
génération interne empêche enfin une ancienne vue d'attendre ou de consommer une
soumission ultérieure ayant réutilisé le même emplacement.

L'exécuteur publie les écritures d'un job avant le retour de `complete`. Il ne
sérialise pas deux mutations arbitraires d'une même classe : leurs accès doivent
être disjoints ou explicitement synchronisés. Un `panic` dans un job reste
fatal ; une erreur récupérable se transporte dans ses données, par exemple avec
un `Result`.

La soumission vérifie également que `execute`, les fonctions qu'elle appelle et
la destruction de son état sont exécutables sur un worker. Les calculs locaux,
les appels dont le graphe est prouvé sûr et les sections `mutex` sont admis. Un
effet réservé au thread principal, un appel externe non classifié, une mutation
statique non synchronisée ou un dispatch dynamique dont la cible est inconnue
produit un diagnostic à la soumission.

Un job ne possède pas d'`Executor`, ne soumet pas de nouveau job et ne consomme
pas un `JobHandle`. Il peut en revanche attendre une `Fence` : cette capacité
non typée est précisément la frontière worker-safe de l'attente coopérative.
Plusieurs threads producteurs externes peuvent partager un même exécuteur et
compléter leurs propres handles. Le comptage de références des classes et la
publication des résultats restent sûrs lorsque leur propriété franchit ces
threads.

## Lots indexés

`ParallelJob` décrit le traitement d'une plage semi-ouverte. Une soumission
parallèle couvre chaque indice de `0` inclus à `count` exclu exactement une fois
et retourne directement la fence collective du lot :

```sx
class Pixels {
    public var values:uint8[]
}

struct Invert:Threading.ParallelJob {
    var pixels:Pixels

    func execute(start:int, end:int) {
        var index = start
        while index < end {
            self.pixels.values[index] = 255 - self.pixels.values[index]
            index++
        }
    }
}

var done = executor.submit_parallel(
    pixels.values.count(),
    Invert(pixels:pixels)
)
done.complete()
```

Le nombre et la taille des plages dépendent de la taille du lot et du nombre de
workers. Un petit lot peut rester une seule plage ; un gros lot publie au plus
une plage continue par worker, sans dégénérer en un job par élément. Cette
borne réduit le coût de planification des kernels denses et laisse chaque
worker amortir une publication sur une plage utile. Leur ordre et le worker
qui les traite sont indéterminés. Un résultat dont la valeur dépend de cet
ordre n'est donc pas déterministe.

`submit_parallel(count, job, after:fence)` garde toutes les plages hors de la
file prête jusqu'à la publication de la dépendance. Zéro retourne une fence
déjà terminée sans appeler `execute`. Un compte négatif est une erreur de
programme.

Une collection modifiée par le lot conserve sa structure et sa capacité fixes
jusqu'à la fence. Les écritures indexées sur des plages disjointes modifient
directement les éléments. `append`, `prepend`, `insert`, `clear`, les
extractions et toute opération susceptible de retirer un élément ou de
réallouer la collection sont rejetées dans le graphe d'appel d'un
`ParallelJob`.

Trois usages doivent rester distincts :

- les écritures sont sûres lorsque chaque plage ne touche que ses propres
  indices ;
- les lectures d'une collection partagée fixe sont concurrentes ;
- une réduction vers un même résultat partagé exige une synchronisation
  explicite et n'est pas fournie par cette API.

Le job peut lire et modifier des classes partagées, mais ne mute pas sa propre
valeur pour produire un résultat : contrairement à `JobHandle<T>`, la fence du
lot ne retourne aucun job. Cette surface ne promet ni réduction générique, ni
SIMD ; les plages continues restent simplement compatibles avec une future
vectorisation.

Comme les jobs ordinaires, un lot parallèle réutilise après échauffement son
état de batch, ses entrées de travail et son signal. Une nouvelle allocation de
planification n'est nécessaire que pour un nouveau type de lot ou un pic de
lots simultanément vivants. Le test interne
`Tests/ThreadingPerformance.sx` vérifie ce régime, le résultat déterministe et
la montée en charge à un, deux et quatre workers. L'outil
`Tools/CheckThreadingPerformance.py` peut contrôler des séries répétées sans
transformer le temps en assertion fragile dans le test Silex. Ce test reste
dans STD car il inspecte volontairement les compteurs `package` du pool de
workers.

Les workers, entrées de file et signaux des adaptateurs natifs macOS ARM64,
Linux X64 et Windows X64 restent internes. La surface publique n'expose ni
thread, ni sémaphore, ni verrou, ni priorité, ni affinité.
