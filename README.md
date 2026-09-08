# Orthotope

A coordinate-axis-aligned box represented by a Point center and Size half-extents.
Both use the same static dimension and scalar type. Size enforces finite,
nonnegative half-extents. The coordinate basis is supplied by the calling domain;
this type does not assert that an arbitrary basis is orthonormal. Frame identity
can tag the whole value with Tagged; bare Point/Orthotope do not carry a frame.

```swift
import Orthotope
let box = Orthotope(
    center: Point(x: 10, y: 20),
    halfExtents: try Size(width: 2, height: 3)
)
let inside = box.contains(Point(x: 11, y: 21)) { center, point in
    Vector(x: point.x - center.x, y: point.y - center.y)
}
```

Membership takes explicit center-to-point coordinate displacement. The closure
owns arithmetic overflow and coordinate conversion. Comparisons avoid taking an
absolute value, including at Int.min. Closed membership includes degenerate boxes;
strict coordinate interior excludes zero-width axes. In zero dimensions both
predicates hold vacuously. No metric, tolerance, bounds arithmetic or implicit
basis conversion is installed. Point scalar validity is inherited from the caller.

Point and Size are URL production dependencies; Tagged is used only in tests.
No separate Rectangle/Cuboid package is needed. Coding stores axis-ordered center coordinates and half-extents, delegating count
and extent validation to Vector and Size. It currently requires Codable scalar
storage, following Size. The equal-side specialization is described below. Compiler-negative type-boundary
verification remains open.
Workspace integration, native discovery/build/tests, and negative dimension/frame
compile checks remain pending.

Validation: registered in atoms.xcworkspace. GUI-backed native MCP umbrella
build-for-testing and all focused Ray/Ball/Orthotope tests passed on My Mac,
2026-09-08 21:01 (29 runtime cases total). See consolidation README for result
bundle and remaining phase work. Earlier pending-registration notes are superseded.

## Equal-side specialization

`Hypercube<N, Scalar>` belongs to this module and stores one validated half-side.
Its `.orthotope` view expands that value across all axes; changing the view cannot
break the original equal-side invariant. `Hypercube(box)` recognizes exactly equal
extents without a tolerance. Zero-dimensional conversion chooses a canonical zero
half-side because there are no axes from which to recover one. Equality compares
stored parameters, including the half-side even in zero dimensions.

```swift
let cube = Hypercube(
    center: Point(x: 0, y: 0, z: 0),
    halfSide: try Magnitude(validating: 2)
)
let box = cube.orthotope
```

Squares and cubes are the two- and three-dimensional cases; no extra packages or
parallel coordinate algorithms are introduced. Coding supports independent scalar
encoding and decoding, and decoded side lengths retain Magnitude validation.
