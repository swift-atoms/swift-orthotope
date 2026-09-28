#if Boundary
import Orthotope
import Testing

@Suite struct `Orthotope corner interpretation` {
    @Test func `All four corners preserve the legacy positive y top convention`() throws {
        let box = Orthotope(center: Point(x: 1.5, y: 2.0), halfExtents: try Size<2, Double>(width: 3.5, height: 5))
        let affine = Point<2, Double>.cartesian
        #expect(box.corner(.bottomLeft, using: affine) == Point(x: -2.0, y: -3.0))
        #expect(box.corner(.bottomRight, using: affine) == Point(x: 5.0, y: -3.0))
        #expect(box.corner(.topLeft, using: affine) == Point(x: -2.0, y: 7.0))
        #expect(box.corner(.topRight, using: affine) == Point(x: 5.0, y: 7.0))
    }

    @Test func `Degenerate boxes retain labels even when corner points coincide`() throws {
        let point = Point(x: 2, y: 3)
        let collapsed = Orthotope(center: point, halfExtents: try Size<2, Int>(width: 0, height: 0))
        let line = Orthotope(center: point, halfExtents: try Size<2, Int>(width: 0, height: 4))
        for corner in Boundary.Corner.allCases {
            #expect(collapsed.corner(corner, using: Point<2, Int>.cartesian) == point)
        }
        #expect(line.corner(.topLeft, using: Point<2, Int>.cartesian) == Point(x: 2, y: 7))
        #expect(line.corner(.topRight, using: Point<2, Int>.cartesian) == Point(x: 2, y: 7))
    }

    @Test func `Opposite corners are opposite displacements from the center`() throws {
        let box = Orthotope(center: Point(x: 7, y: -9), halfExtents: try Size<2, Int>(width: 2, height: 5))
        let affine = Point<2, Int>.cartesian
        for corner in Boundary.Corner.allCases {
            let a = affine.displacement(from: box.center, to: box.corner(corner, using: affine))
            let b = affine.displacement(from: box.center, to: box.corner(corner.opposite, using: affine))
            #expect(a + b == .zero)
        }
    }

    private enum Failure: Error { case overflow }
    @Test func `Checked affine failures propagate with their concrete type`() throws {
        let box = Orthotope(center: Point(x: Int.max, y: 0), halfExtents: try Size<2, Int>(width: 1, height: 0))
        let checked = Affine<Point<2, Int>, Displacement<2, Int>, Failure>.componentwise(
            coordinates: { $0.coordinates }, point: Point.init,
            components: { $0.components }, displacement: Displacement.init,
            translating: { (value, delta) throws(Failure) in
                let result = value.addingReportingOverflow(delta)
                guard !result.overflow else { throw .overflow }
                return result.partialValue
            },
            subtracting: { (a, b) throws(Failure) in
                let result = b.subtractingReportingOverflow(a)
                guard !result.overflow else { throw .overflow }
                return result.partialValue
            }
        )
        do {
            _ = try box.corner(.topRight, using: checked)
            Issue.record("Expected overflow")
        } catch {
            let failure: Failure = error
            #expect(failure == .overflow)
        }
        #expect(try box.corner(.topLeft, using: checked).x == Int.max - 1)
    }
}
#endif
