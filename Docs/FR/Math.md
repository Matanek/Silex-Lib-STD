# Mathématiques

`STD.Math` utilise un repère cartésien droit : droite `+X`, haut `+Y`, arrière
`+Z` et direction visible avant `-Z`.

```sx
use STD.Math

let surface_normal = Math.Vec3.right().cross(Math.Vec3.up())
assert(surface_normal == Math.Vec3.back())
```

## Calculer avec les opérateurs

`Vec2`, `Vec3` et `Vec4` acceptent l'addition, la soustraction, la négation,
le produit et la division composante par composante. Un scalaire employé avec
`+`, `-`, `*` ou `/` est diffusé sur chaque composante, dans les deux
orientations.

```sx
var velocity = Math.Vec2(1.0, 5.0) * 10
velocity += Math.Vec2(3.0, 7.0)
let leftward = Math.Vec2.left() * 5
```

Préférez le vecteur à gauche pour `+`, `-` et `/` lorsque les deux écritures
sont possibles. La multiplication scalaire est canonique dans les deux sens.
Les formes comme `2 / vector` restent disponibles lorsque l'ordre fait partie
du calcul composante par composante.

`Mat3` et `Mat4` acceptent `+`, `-`, la négation, la mise à l'échelle par `*`
ou `/`, le produit matrice-matrice et le produit matrice-vecteur. `Quat`
accepte `+`, `-`, la négation, le produit de quaternions et la mise à l'échelle.
Les affectations composées réemploient automatiquement les opérations dont le
résultat conserve le type de gauche.

La diffusion scalaire complète des vecteurs ne s'étend pas aux matrices ni aux
quaternions. Pour eux, seule la multiplication scalaire accepte les deux
orientations ; la division garde la valeur composée à gauche. Les formes
ambiguës comme `scalar / matrix`, `matrix + scalar` et `vector * matrix` ne sont
pas définies.

Les méthodes nommées comme `add`, `multiply` et `rotate` restent disponibles.
`Quat * Vec3` n'est volontairement pas défini : utilisez `rotation.rotate(vector)`
pour rendre l'intention explicite.

## Matrices et transformations

`Mat3` et `Mat4` stockent leurs colonnes dans `x`, `y`, `z` et `w`. Les
opérations utilisent des vecteurs colonnes.

```sx
let translation = Math.Mat4.translation(Math.Vec3(10.0, 0.0, 0.0))
let point = Math.Vec4(Math.Vec3(1.0, 2.0, 3.0), 1.0)
let direction = Math.Vec4(Math.Vec3(1.0, 2.0, 3.0), 0.0)

let moved_point = translation.multiply(point)
let unchanged_direction = translation.multiply(direction)
```

Un point utilise `w = 1`, une direction `w = 0`. Dans
`left.multiply(right)`, la droite s’applique en premier.

```sx
let scaling = Math.Mat4.scaling(Math.Vec3(2.0, 2.0, 2.0))
let model = translation.multiply(scaling)
let transformed = model.multiply(point)
```

`Mat4.transform` suit le même contrat et les rotations positives sont droites.
`look_at` construit une vue dont l’axe visible est Z négatif. Les projections
perspective et orthographique mappent near/far vers `[-1, 1]`.

`Rect` est semi-ouvert : le minimum appartient au rectangle, le maximum non.
Deux rectangles qui se touchent seulement sur leur bord maximal ne se
recouvrent pas. Une largeur ou hauteur non positive rend le rectangle vide.
