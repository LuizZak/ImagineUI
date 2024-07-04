import XCTest

@testable import Geometry

class UIAngleTests: XCTestCase {
    func testClamp_negative() {
        let sut = UIAngle(radians: -.pi / 4)

        XCTAssertEqual(sut.radians, 5.497787143782138)
    }

    func testClamp_positive() {
        let sut = UIAngle(radians: .pi * 3.5)

        XCTAssertEqual(sut.radians, 4.71238898038469)
    }

    func testClamp_positive_pi() {
        let sut = UIAngle(radians: .pi * 3)

        XCTAssertEqual(sut.radians, 3.141592653589793)
    }
}
