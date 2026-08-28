# Mathématiques

`STD.Math` utilise un repère cartésien droit : droite `+X`, haut `+Y`, arrière
`+Z` et direction visible avant `-Z`.

```sx
use STD.Math

let surface_normal = Math.Vec3.right().cross(Math.Vec3.up())
assert(surface_normal == Math.Vec3.back())
```

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
