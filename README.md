# swift-orthotope

Use this package when you need an axis-aligned box in any fixed number of dimensions, stored as a center and non-negative half extents, and want to test points against it or read off its corners without committing to a coordinate frame. Start from `Orthotope<N, Scalar>`; use `Hypercube<N, Scalar>` when every axis has the same half extent. For a round region use the swift-ball package instead, and for a box tied to a geometry frame use the one in swift-geometry.

## Laws

- An orthotope is the closed set of points whose offset from `center` lies within `-halfExtents[i] ... halfExtents[i]` on every axis. `contains` includes the boundary; `containsInterior` excludes it.
- A zero half extent makes a degenerate box, not an empty one: `contains` holds on the flat axis and `containsInterior` holds nowhere.
- With `N == 0`, both `contains` and `containsInterior` are true for every point.
- Membership calls the displacement closure exactly once, as `(center, point)`, and expects the offset from the center to the point. Each component is compared against both signed bounds, so `Int.min` offsets never take an absolute value. A failure thrown by the closure propagates unchanged and no answer is produced.
- `Hypercube` to `Orthotope` copies `halfSide` to every axis. `Orthotope` to `Hypercube` succeeds only when all half extents are exactly equal. With `N == 0` it always succeeds with a zero `halfSide`, so a zero-dimensional cube's `halfSide` does not survive a round trip.
- Encoding writes `center` as its coordinate array. Decoding rejects a wrong number of coordinates or extents and any negative half extent or half side.
- With the Boundary trait, `corner(_:using:)` translates `center` by `±halfExtents` through the given affine: left is negative x and top is positive y. A degenerate box still answers every corner, even when the points coincide. A failure thrown by the affine propagates unchanged.
