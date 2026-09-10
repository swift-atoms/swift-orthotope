public import Point
public import Size

public struct Hypercube<let N: Int, Scalar: Magnitude::Scalar> {
    public var center: Point<N, Scalar>
    public var halfSide: Magnitude<Scalar>

    public init(center: Point<N, Scalar>, halfSide: Magnitude<Scalar>) {
        self.center = center
        self.halfSide = halfSide
    }

    public var orthotope: Orthotope<N, Scalar> {
        Orthotope(self)
    }

}

extension Hypercube: Equatable {}
extension Hypercube: Hashable where Scalar: Hashable {}
extension Hypercube: Sendable where Scalar: Sendable {}

#if !hasFeature(Embedded)
extension Hypercube {
    private enum CodingKeys: String, CodingKey { case center, halfSide }
}

extension Hypercube: Encodable where Scalar: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(center.coordinates, forKey: .center)
        try container.encode(halfSide, forKey: .halfSide)
    }
}

extension Hypercube: Decodable where Scalar: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            center: Point(coordinates: try container.decode(Vector<N, Scalar>.self, forKey: .center)),
            halfSide: try container.decode(Magnitude<Scalar>.self, forKey: .halfSide)
        )
    }
}
#endif

extension Hypercube {

    public init?(_ orthotope: Orthotope<N, Scalar>) {
        let side: Magnitude<Scalar>
        if N == 0 {
            side = .zero
        } else {
            side = orthotope.halfExtents[0]
            for index in 1..<N {
                guard orthotope.halfExtents[index] == side else { return nil }
            }
        }
        self.init(center: orthotope.center, halfSide: side)
    }
}
