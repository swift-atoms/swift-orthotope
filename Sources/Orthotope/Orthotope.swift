@_exported public import Point
@_exported public import Size

/// A coordinate-axis-aligned box with validated half-extents.
/// Center and extents share one dimension and scalar type. No basis is inferred.
public struct Orthotope<let N: Int, Scalar: Magnitude::Scalar> {
    public var center: Point<N, Scalar>
    public var halfExtents: Size<N, Scalar>

    public init(center: Point<N, Scalar>, halfExtents: Size<N, Scalar>) {
        self.center = center
        self.halfExtents = halfExtents
    }
}

extension Orthotope: Equatable {}
extension Orthotope: Hashable where Scalar: Hashable {}
extension Orthotope: Sendable where Scalar: Sendable {}

extension Orthotope where Scalar: SignedNumeric {
    /// Closed membership in the box. The supplied displacement must express
    /// point minus center along the same coordinate axes as the half-extents.
    public func contains<Failure: Swift.Error>(
        _ point: Point<N, Scalar>,
        using displacement: (Point<N, Scalar>, Point<N, Scalar>) throws(Failure) -> Vector<N, Scalar>
    ) throws(Failure) -> Bool {
        let offset = try displacement(center, point)
        for i in 0..<N {
            let extent = halfExtents[i].value
            guard offset[i] >= -extent && offset[i] <= extent else { return false }
        }
        return true
    }

    /// Strict component-wise membership. A zero extent makes this false for N > 0.
    public func containsInterior<Failure: Swift.Error>(
        _ point: Point<N, Scalar>,
        using displacement: (Point<N, Scalar>, Point<N, Scalar>) throws(Failure) -> Vector<N, Scalar>
    ) throws(Failure) -> Bool {
        let offset = try displacement(center, point)
        for i in 0..<N {
            let extent = halfExtents[i].value
            guard offset[i] > -extent && offset[i] < extent else { return false }
        }
        return true
    }
}

#if !hasFeature(Embedded)
extension Orthotope {
    private enum CodingKeys: String, CodingKey { case center, halfExtents }
}

extension Orthotope: Decodable where Scalar: Decodable {
    /// The encoded center is its axis-ordered coordinates. Size validates extents.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            center: Point(coordinates: try container.decode(Vector<N, Scalar>.self, forKey: .center)),
            halfExtents: try container.decode(Size<N, Scalar>.self, forKey: .halfExtents)
        )
    }

}

extension Orthotope: Encodable where Scalar: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(center.coordinates, forKey: .center)
        try container.encode(halfExtents, forKey: .halfExtents)
    }
}
#endif

extension Orthotope {
    /// Expand the validated half-side along every coordinate axis.
    public init(_ hypercube: Hypercube<N, Scalar>) {
        self.init(center: hypercube.center, halfExtents: Size(repeating: hypercube.halfSide))
    }
}
