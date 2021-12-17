import XCTest
@testable import Geometry

class UIRegionTests: XCTestCase {
    func testEphemeral() {
        let sut = UIRegion()

        XCTAssertTrue(sut.isEmpty)
        assertEqual(sut.allRectangles(), [])
    }

    func testIsEmpty() {
        let sut = UIRegion()
        let rect = UIRectangle(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0)
        sut.addRectangle(rect, operation: .add)

        XCTAssertFalse(sut.isEmpty)
    }

    func testAddRectangle_defaultOperationIsAdd() {
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 5, top: 5, right: 15, bottom: 15)
        let rect2 = UIRectangle(left: 10, top: 10, right: 20, bottom: 20)

        sut.addRectangle(rect1, operation: .add)
        sut.addRectangle(rect2, operation: .add)

        assertEqual(sut.allRectangles(), [
            .init(left: 5, top: 5, right: 15, bottom: 10),
            .init(left: 5, top: 10, right: 20, bottom: 15),
            .init(left: 10, top: 15, right: 20, bottom: 20),
        ])
    }

    func testAddRectangle_add_empty() {
        let sut = UIRegion()
        let rect = UIRectangle(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0)

        sut.addRectangle(rect, operation: .add)

        assertEqual(sut.allRectangles(), [rect])
    }

    func testAddRectangle_add_contained() {
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0)
        let rect2 = UIRectangle(left: 2.0, top: 2.0, right: 7.0, bottom: 7.0)

        sut.addRectangle(rect1, operation: .add)
        sut.addRectangle(rect2, operation: .add)

        assertEqual(sut.allRectangles(), [rect1])
    }

    func testAddRectangle_add_nonIntersecting() {
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0)
        let rect2 = UIRectangle(left: 5.0, top: 15.0, right: 10.0, bottom: 20.0)

        sut.addRectangle(rect1, operation: .add)
        sut.addRectangle(rect2, operation: .add)

        assertEqual(sut.allRectangles(), [rect1, rect2])
    }

    func testAddRectangle_add_intersecting() {
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 5, top: 5, right: 15, bottom: 15)
        let rect2 = UIRectangle(left: 10, top: 10, right: 20, bottom: 20)

        sut.addRectangle(rect1, operation: .add)
        sut.addRectangle(rect2, operation: .add)

        assertEqual(sut.allRectangles(), [
            .init(left: 5, top: 5, right: 15, bottom: 10),
            .init(left: 5, top: 10, right: 20, bottom: 15),
            .init(left: 10, top: 15, right: 20, bottom: 20),
        ])
    }

    func testAddRectangle_add_sidebyside_merges() {
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 0, top: 0, right: 10, bottom: 10)
        let rect2 = UIRectangle(left: 10, top: 0, right: 20, bottom: 10)

        sut.addRectangle(rect1, operation: .add)
        sut.addRectangle(rect2, operation: .add)

        assertEqual(sut.allRectangles(), [
            .init(left: 0, top: 0, right: 20, bottom: 10),
        ])
    }

    func testAddRectangle_subtract_empty() {
        let sut = UIRegion()
        let rect = UIRectangle(left: 0, top: 0, right: 10, bottom: 10)

        sut.addRectangle(rect, operation: .subtract)

        assertEqual(sut.allRectangles(), [])
    }

    func testAddRectangle_subtract_nonIntersecting() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 10.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
        let rect = UIRectangle(left: 0, top: 40, right: 10, bottom: 45)

        sut.addRectangle(rect, operation: .subtract)

        assertEqual(sut.allRectangles(), [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 10.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
    }

    func testAddRectangle_subtract_intersecting() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 20.0),
        ])
        let rect = UIRectangle(left: 10, top: 10, right: 30, bottom: 30)

        sut.addRectangle(rect, operation: .subtract)

        assertEqual(sut.allRectangles(), [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 10.0, bottom: 20.0),
        ])
    }

    func testAddRectangle_subtract_contained() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 30.0, bottom: 30.0),
        ])
        let rect = UIRectangle(left: 10, top: 10, right: 20, bottom: 20)

        sut.addRectangle(rect, operation: .subtract)

        assertEqual(sut.allRectangles(), [
            .init(left: 0.0, top: 0.0, right: 30.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 10.0, bottom: 20.0),
            .init(left: 20.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 0.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
    }

    func testAddRectangle_subtract_complete() {
        let sut = UIRegion(rectangles: [
            .init(left: 10, top: 10, right: 20, bottom: 20),
        ])
        let rect = UIRectangle(left: 0.0, top: 0.0, right: 30.0, bottom: 30.0)

        sut.addRectangle(rect, operation: .subtract)

        assertEqual(sut.allRectangles(), [])
    }

    func testAddRectangle_intersect_empty() {
        let sut = UIRegion()
        let rect = UIRectangle(left: 0, top: 0, right: 10, bottom: 10)

        sut.addRectangle(rect, operation: .intersect)

        assertEqual(sut.allRectangles(), [])
    }

    func testAddRectangle_intersect_nonIntersecting_singleRect() {
        let sut = UIRegion(rectangles: [
            .init(left: 10, top: 10, right: 20, bottom: 20),
        ])
        let rect = UIRectangle(left: 0, top: 0, right: 5, bottom: 5)

        sut.addRectangle(rect, operation: .intersect)

        assertEqual(sut.allRectangles(), [])
    }

    func testAddRectangle_intersect_nonIntersecting_multiRect() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 10.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
        let rect = UIRectangle(left: 0, top: 40, right: 10, bottom: 45)

        sut.addRectangle(rect, operation: .intersect)

        assertEqual(sut.allRectangles(), [])
    }

    func testAddRectangle_intersect_intersecting() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 10.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
        let rect = UIRectangle(left: 5, top: 5, right: 25, bottom: 25)

        sut.addRectangle(rect, operation: .intersect)

        assertEqual(sut.allRectangles(), [
            .init(left: 5.0, top: 5.0, right: 20.0, bottom: 10.0),
            .init(left: 5.0, top: 10.0, right: 25.0, bottom: 20.0),
            .init(left: 10.0, top: 20.0, right: 25.0, bottom: 25.0),
        ])
    }

    func testAddRectangle_xor_empty() {
        let sut = UIRegion()
        let rect = UIRectangle(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0)

        sut.addRectangle(rect, operation: .xor)

        assertEqual(sut.allRectangles(), [rect])
    }

    func testAddRectangle_xor_nonIntersecting() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0),
        ])
        let rect = UIRectangle(left: 5.0, top: 15.0, right: 10.0, bottom: 20.0)

        sut.addRectangle(rect, operation: .xor)

        assertEqual(sut.allRectangles(), [
            .init(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0),
            rect
        ])
    }

    func testAddRectangle_xor_intersecting() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 20.0),
        ])
        let rect = UIRectangle(left: 10.0, top: 10.0, right: 30.0, bottom: 30.0)

        sut.addRectangle(rect, operation: .xor)

        assertEqual(sut.allRectangles(), [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 10.0, bottom: 20.0),
            .init(left: 20.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 10.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
    }

    func testAddRectangle_xor_contained() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 30.0, bottom: 30.0),
        ])
        let rect = UIRectangle(left: 10, top: 10, right: 20, bottom: 20)

        sut.addRectangle(rect, operation: .xor)

        assertEqual(sut.allRectangles(), [
            .init(left: 0.0, top: 0.0, right: 30.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 10.0, bottom: 20.0),
            .init(left: 20.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 0.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
    }

    func testAddRectangle_complex() {
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 0, top: 0, right: 40, bottom: 30)
        let rect2 = UIRectangle(left: 20, top: 15, right: 60, bottom: 45)
        let rect3 = UIRectangle(left: 10, top: 10, right: 50, bottom: 40)

        sut.addRectangle(rect1, operation: .add)
        sut.addRectangle(rect2, operation: .add)
        sut.addRectangle(rect3, operation: .subtract)

        assertEqual(sut.allRectangles(), [
            .init(left:  0.0, top:  0.0, right: 40.0, bottom: 10.0),
            .init(left:  0.0, top: 10.0, right: 10.0, bottom: 30.0),
            .init(left: 50.0, top: 15.0, right: 60.0, bottom: 40.0),
            .init(left: 20.0, top: 40.0, right: 60.0, bottom: 45.0),
        ])
        
        // End result should be:
        //    0         10        20        30        40        50        60
        // 0  |---------.---------.---------.---------|
        //    |                                       |
        //    |                                       |
        //    |                                       |
        //    |                                       |
        // 10 |---------.---------.---------.---------|
        //    |         |
        //    |         |
        // 15 |         |                                       |---------|
        //    |         |                                       |         |
        // 20 |         |                                       |         |
        //    |         |                                       |         |
        //    |         |                                       |         |
        //    |         |                                       |         |
        //    |         |                                       |         |
        // 30 |---------|                                       |         |
        //                                                      |         |
        //                                                      |         |
        //                                                      |         |
        //                                                      |         |
        // 40                     |---------.---------.---------|---------|
        //                        |                                       |
        //                        |                                       |
        // 45                     |---------.---------.---------.---------|
    }
}

private func assertEqual(_ actual: [UIRectangle], _ expected: [UIRectangle], line: UInt = #line) {
    guard actual != expected else {
        return
    }

    let format: (UIRectangle) -> String = {
        ".init(left: \($0.left), top: \($0.top), right: \($0.right), bottom: \($0.bottom))"
    }
    let formatArray: ([UIRectangle]) -> String = {
        if $0.isEmpty {
            return "[]"
        }

        return "[  \n  " + $0.map(format).joined(separator: ",\n  ") + ",\n]"
    }

    let v1Format = formatArray(actual)
    let v2Format = formatArray(expected)

    XCTFail("""
        Error: Rectangle arrays don't match
        Actual: 
        \(v1Format)
        Expected:
        \(v2Format)
        """,
        line: line
    )
}
