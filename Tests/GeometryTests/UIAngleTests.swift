import XCTest

@testable import Geometry

class UIAngleTests: XCTestCase {
    func testClamp_negative() {
        let sut = UIAngle(radians: -.pi / 4)

        XCTAssertEqual(sut.radians, -0.7853981633974483)
    }

    func testClamp_positive() {
        let sut = UIAngle(radians: .pi * 3.5)

        XCTAssertEqual(sut.radians, 1.5707963267948966)
    }

    func testClamp_positive_pi() {
        let sut = UIAngle(radians: .pi * 3)

        XCTAssertEqual(sut.radians, 0.0)
    }
}
