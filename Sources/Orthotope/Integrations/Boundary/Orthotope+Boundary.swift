#if Boundary
@_exported public import Boundary
@_exported public import Point
@_exported public import Affine
@_exported public import Displacement
@_exported public import Coordinate
@_exported public import Translation
@_exported public import Segment
@_exported public import Tagged
@_exported public import Vector

extension Orthotope where N == 2, Scalar: SignedNumeric {

    public func corner<Failure: Swift::Error>(
        _ corner: Boundary.Corner,
        using affine: Affine<Point<2, Scalar>, Displacement<2, Scalar>, Failure>
    ) throws(Failure) -> Point<2, Scalar> {
        let x = halfExtents[0].value
        let y = halfExtents[1].value
        let offset = Displacement(dx: corner.isLeft ? -x : x, dy: corner.isTop ? y : -y)
        return try affine.translated(center, by: offset)
    }
}
#endif
