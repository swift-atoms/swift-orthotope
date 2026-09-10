import Orthotope
import Testing
import Tagged
import Foundation

@Suite struct `Orthotope coordinate contracts` {
    private func displacement(_ a: Point<2, Int>, _ b: Point<2, Int>) -> Vector<2, Int> {
        Vector(x: b.x - a.x, y: b.y - a.y)
    }

    @Test func `Center and extents share dimensional public types`() throws {
        let box = Orthotope(center: Point(x: 10, y: 20), halfExtents: try Size(width: 2, height: 3))
        let center: Point<2, Int> = box.center
        let extents: Size<2, Int> = box.halfExtents
        #expect(center.y == 20)
        #expect(extents.width.value == 2)
        #expect(box.contains(Point(x: 12, y: 23), using: displacement))
        #expect(!box.containsInterior(Point(x: 12, y: 23), using: displacement))
        #expect(box.containsInterior(Point(x: 10, y: 20), using: displacement))
        #expect(!box.contains(Point(x: 13, y: 20), using: displacement))
    }

    @Test func `A zero extent is a degenerate closed box rather than an empty set`() throws {
        let box = Orthotope(center: Point(x: 0, y: 0), halfExtents: try Size(width: 0, height: 2))
        #expect(box.contains(Point(x: 0, y: 1), using: displacement))
        #expect(!box.containsInterior(Point(x: 0, y: 1), using: displacement))
        #expect(!box.contains(Point(x: 1, y: 1), using: displacement))
    }

    @Test func `Half extents retain the Size validation invariant`() {
        #expect(throws: Magnitude<Int>.Error.negative) {
            Orthotope(center: Point(x: 0, y: 0), halfExtents: try Size(width: -1, height: 2))
        }
    }

    @Test func `Minimum integer offsets are compared without absolute value overflow`() throws {
        let box = Orthotope(center: Point(x: 0), halfExtents: try Size(length: Int.max))
        #expect(!box.contains(Point(x: Int.min)) { _, p in p.coordinates })
        #expect(box.contains(Point(x: Int.max)) { _, p in p.coordinates })
    }

    @Test func `Displacement errors retain their failure type`() throws {
        enum Failure: Error { case overflow }
        let box = Orthotope(center: Point(x: 0), halfExtents: Size<1, Int>.zero)
        func subtract(_ a: Point<1, Int>, _ b: Point<1, Int>) throws(Failure) -> Vector<1, Int> {
            throw .overflow
        }
        #expect(throws: Failure.overflow) { try box.contains(Point(x: 1), using: subtract) }
        #expect(throws: Failure.overflow) { try box.containsInterior(Point(x: 1), using: subtract) }
    }

    @Test func `Frame identity can wrap the whole coordinate representation`() throws {
        enum World {}
        let box = Orthotope(center: Point(x: 0, y: 0, z: 0), halfExtents: try Size(width: 1, height: 2, depth: 3))
        let framed = Tagged<World, Orthotope<3, Int>>(_unchecked: box)
        #expect(framed.underlying == box)
        #expect(Set([box, box]).count == 1)
    }

    @Test func `Zero dimensional boxes use vacuous coordinate membership`() {
        let point = Point(coordinates: Vector<0, Int>(repeating: 0))
        let box = Orthotope(center: point, halfExtents: Size<0, Int>.zero)
        #expect(box.contains(point) { _, p in p.coordinates })
        #expect(box.containsInterior(point) { _, p in p.coordinates })
    }
}

@Suite struct `Orthotope coding contracts` {
    @Test func `Coding preserves dimensional coordinates and half extents`() throws {
        let box = Orthotope(center: Point(x: 1, y: 2), halfExtents: try Size(width: 3, height: 4))
        let decoded = try JSONDecoder().decode(Orthotope<2, Int>.self, from: JSONEncoder().encode(box))
        #expect(decoded == box)
    }

    @Test(arguments: [
        #"{"center":[1],"halfExtents":[2,3]}"#,
        #"{"center":[1,2],"halfExtents":[3]}"#,
        #"{"center":[1,2],"halfExtents":[-1,3]}"#,
    ])
    func `Decoding cannot bypass dimension and extent validity`(_ json: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Orthotope<2, Int>.self, from: Data(json.utf8))
        }
    }
}

private func encode<let N: Int, Value: Magnitude::Scalar & Encodable>(
    _ value: Orthotope<N, Value>
) throws -> Data {
    try JSONEncoder().encode(value)
}

private func decode<let N: Int, Value: Magnitude::Scalar & Decodable>(
    _ type: Orthotope<N, Value>.Type, from data: Data
) throws -> Orthotope<N, Value> {
    try JSONDecoder().decode(type, from: data)
}

@Test func `Orthotope coding requires only the requested direction`() throws {
    let value = Orthotope(center: Point<2, Int>(coordinates: Vector([1, 2])), halfExtents: try Size(width: 4, height: 3))
    let data = try encode(value)
    #expect(try decode(Orthotope<2, Int>.self, from: data) == value)
}
