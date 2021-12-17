import XCTest
@testable import ImagineUICore

class LayoutAnchorTests: XCTestCase {
    func testCreateConstraints() {
        let parent = View()
        let view = View()
        parent.addSubview(view)
        (view.layout.right == parent).create()

        XCTAssertEqual(view.constraints.count, 1)
        XCTAssertEqual(parent.constraints.count, 1)
    }

    func testRemoveConstraints() {
        let parent = View()
        let view = View()
        parent.addSubview(view)
        (view.layout.right == parent).create()

        view.layout.right.removeConstraints()

        XCTAssertEqual(view.constraints.count, 0)
        XCTAssertEqual(parent.constraints.count, 0)
    }

    func testRemoveConstraints_removesCorrectConstraints() {
        let parent = View()
        let view = View()
        parent.addSubview(view)
        (view.layout.left == parent.layout.right).create()

        view.layout.right.removeConstraints()

        XCTAssertEqual(view.constraints.count, 1)
        XCTAssertEqual(parent.constraints.count, 1)
    }
}
