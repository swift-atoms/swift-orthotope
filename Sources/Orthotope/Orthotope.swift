@_exported public import Point
@_exported public import Size

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

    public init(_ hypercube: Hypercube<N, Scalar>) {
        self.init(center: hypercube.center, halfExtents: Size(repeating: hypercube.halfSide))
    }
}
