import Orthotope
import Testing
import Foundation

@Suite struct `Hypercube specialization contracts` {
    @Test func `One half side expands equally across all dimensions`() throws {
        var cube = Hypercube(center: Point(x: 1, y: 2, z: 3), halfSide: try Magnitude(validating: 4))
        #expect(cube.orthotope.halfExtents == (try Size(width: 4, height: 4, depth: 4)))
        cube.halfSide = try Magnitude(validating: 7)
        #expect(cube.orthotope.halfExtents == (try Size(width: 7, height: 7, depth: 7)))
        #expect(cube.orthotope.center == Point(x: 1, y: 2, z: 3))
    }

    @Test func `Conversion requires exactly equal extents`() throws {
        let equal = Orthotope(center: Point(x: 0, y: 0), halfExtents: try Size(width: 2, height: 2))
        #expect(Hypercube(equal)?.orthotope == equal)
        let unequal = Orthotope(center: Point(x: 0, y: 0), halfExtents: try Size(width: 2, height: 3))
        #expect(Hypercube(unequal) == nil)
    }

    @Test func `Zero half side remains a valid degenerate box`() {
        let cube = Hypercube(center: Point(x: 0), halfSide: Magnitude<Int>.zero)
        #expect(cube.orthotope.contains(Point(x: 0)) { _, p in p.coordinates })
        #expect(!cube.orthotope.containsInterior(Point(x: 0)) { _, p in p.coordinates })
    }

    @Test func `Zero dimensions do not read a first extent`() throws {
        let point = Point(coordinates: Vector<0, Int>(repeating: 0))
        let cube = Hypercube(center: point, halfSide: try Magnitude(validating: 5))
        #expect(cube.orthotope.halfExtents == Size<0, Int>.zero)
        #expect(Hypercube(cube.orthotope)?.halfSide == .zero)
    }

    @Test func `Mutating an expanded box does not change the equal side value`() throws {
        let cube = Hypercube(center: Point(x: 0, y: 0), halfSide: try Magnitude(validating: 2))
        var box = cube.orthotope
        box.halfExtents = try Size(width: 3, height: 4)
        #expect(cube.halfSide.value == 2)
        #expect(Hypercube(box) == nil)
        #expect(Set([cube, cube]).count == 1)
    }

    @Test func `Coding round trips while rejecting negative half sides`() throws {
        let cube = Hypercube(center: Point(x: 1, y: 2), halfSide: try Magnitude(validating: 3))
        #expect(try JSONDecoder().decode(Hypercube<2, Int>.self, from: JSONEncoder().encode(cube)) == cube)
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(Hypercube<2, Int>.self, from: Data(#"{"center":[1,2],"halfSide":-1}"#.utf8))
        }
    }
}
