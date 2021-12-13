import XCTest
import CassowarySwift
@testable import ImagineUI

class LayoutPriorityTests: XCTestCase {
    func testCassowaryStrength_cassowaryEquivalence() {
        XCTAssertEqual(LayoutPriority.required.cassowaryStrength, Strength.REQUIRED)
        XCTAssertEqual(LayoutPriority.high.cassowaryStrength, Strength.STRONG)
        XCTAssertEqual(LayoutPriority.medium.cassowaryStrength, Strength.MEDIUM)
        XCTAssertEqual(LayoutPriority.lowest.cassowaryStrength, Strength.WEAK)
    }

    func testCassowaryStrength_customPriority() {
        XCTAssertLessThan(LayoutPriority(800).cassowaryStrength, Strength.REQUIRED)
        XCTAssertLessThan(LayoutPriority(700).cassowaryStrength, LayoutPriority.high.cassowaryStrength)
        XCTAssertLessThan(LayoutPriority(300).cassowaryStrength, LayoutPriority.medium.cassowaryStrength)
        XCTAssertLessThan(LayoutPriority.low.cassowaryStrength, LayoutPriority(300).cassowaryStrength)
        XCTAssertLessThan(LayoutPriority.low.cassowaryStrength, Strength.MEDIUM)
        XCTAssertGreaterThan(LayoutPriority.low.cassowaryStrength, Strength.WEAK)
        XCTAssertGreaterThan(LayoutPriority.low.cassowaryStrength, LayoutPriority.veryLow.cassowaryStrength)
        XCTAssertGreaterThan(LayoutPriority.veryLow.cassowaryStrength, Strength.WEAK)
    }

    func testCassowaryStrength_isAscending() {
        for i in 1..<1000 {
            let cur = LayoutPriority(i).cassowaryStrength
            let next = LayoutPriority(i + 1).cassowaryStrength

            if cur >= next {
                XCTFail("LayoutPriority(\(i)) < LayoutPriority(\(i + 1)) failed: \(cur) >= \(next)")
                break
            }
        }
    }
}
