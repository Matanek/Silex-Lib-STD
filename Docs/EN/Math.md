# Math

`STD.Math` uses a right-handed Cartesian coordinate system. `right` is `+X`,
`up` is `+Y`, `back` is `+Z`, and the visible `front` direction is `-Z`:

```sx
use STD.Math

let surface_normal = Math.Vec3.right().cross(Math.Vec3.up())
assert(surface_normal == Math.Vec3.back())
```

## Matrices and transformations

`Mat3` and `Mat4` store columns in their `x`, `y`, `z` and `w` fields. A
`row(index)` call gathers one row from those columns; an index outside the
matrix is a programming error and panics. Matrix operations use column vectors:

```sx
let translation = Math.Mat4.translation(Math.Vec3(10.0, 0.0, 0.0))
let point = Math.Vec4(Math.Vec3(1.0, 2.0, 3.0), 1.0)
let direction = Math.Vec4(Math.Vec3(1.0, 2.0, 3.0), 0.0)

let moved_point = translation.multiply(point)
let unchanged_direction = translation.multiply(direction)
```

A point uses `w = 1`; a direction uses `w = 0` and is therefore unaffected by
translation. In `left.multiply(right)`, `right` is applied first. The following
scales a point before translating it:

```sx
let scaling = Math.Mat4.scaling(Math.Vec3(2.0, 2.0, 2.0))
let model = translation.multiply(scaling)
let transformed = model.multiply(point)
```

`Mat4.transform(translation, rotation, scaling)` follows the same column-vector
contract. Positive rotations are right-handed.

## View and projection

`Mat4.look_at(eye, target, up)` builds a right-handed view whose visible axis
is negative Z. `Mat4.perspective` takes a vertical field of view in radians.
Both `perspective` and `orthographic` map view-space near and far planes to the
normalized depth interval `[-1, 1]`. A future alternative depth convention
must use a distinct public name or option.

## Rectangles

`Rect` is semi-open: its minimum belongs to the rectangle and its maximum does
not. `contains` and `intersects` follow that rule, so two rectangles that only
touch at a maximum edge do not overlap. A non-positive width or height makes a
rectangle empty.

`Rect.scaled(scale)` scales both position and size from the coordinate-system
origin. It does not scale around the rectangle center.
