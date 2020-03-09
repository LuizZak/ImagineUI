import XCTest
import ImagineUI

class ViewTests: XCTestCase {
    func testLayoutWithNoSuperview() {
        let view = View()
        view.layout.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.width.equalTo(100)
            make.height.equalTo(20)
        }
        
        view.performLayout()
        
        XCTAssertEqual(view.location, .zero)
        XCTAssertEqual(view.size, Size(x: 100, y: 20))
    }
}
