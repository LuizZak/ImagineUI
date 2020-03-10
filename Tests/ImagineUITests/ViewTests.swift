import XCTest
import ImagineUI

class ViewTests: XCTestCase {
    func testLayoutWithNoSuperview() {
        let view = View(bounds: .empty)
        view.layout.makeConstraints { make in
            make.top == 0
            make.left == 0
            make.width == 100
            make.height == 20
        }
        
        view.performLayout()
        
        XCTAssertEqual(view.location, .zero)
        XCTAssertEqual(view.size, Size(x: 100, y: 20))
    }
}
