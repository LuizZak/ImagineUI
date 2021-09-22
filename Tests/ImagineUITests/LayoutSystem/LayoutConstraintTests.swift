import XCTest
@testable import ImagineUI

class LayoutConstraintTests: XCTestCase {
    func testCreateConstraintSingleView() {
        let view = View()
        
        let result = LayoutConstraint.create(first: view.layout.width,
                                             relationship: .equal,
                                             offset: 10,
                                             priority: 100)
        
        XCTAssertEqual(view.constraints, [result])
        XCTAssertNil(view.constraints.first?.second)
        XCTAssertEqual(view.constraints.first?.relationship, .equal)
        XCTAssertEqual(view.constraints.first?.offset, 10)
        XCTAssertEqual(view.constraints.first?.multiplier, 1)
        XCTAssertEqual(view.constraints.first?.priority, 100)
    }
    
    func testUpdateConstraintSingleView() {
        let view = View()
        let constraint = LayoutConstraint.create(first: view.layout.width,
                                                 relationship: .equal,
                                                 offset: 10,
                                                 priority: 100)
        
        let result = LayoutConstraint.update(first: view.layout.width,
                                             relationship: .equal,
                                             offset: 100,
                                             priority: 1000)
        
        XCTAssertEqual(constraint, result)
        XCTAssertEqual(view.constraints, [result])
        XCTAssertNil(view.constraints.first?.second)
        XCTAssertEqual(view.constraints.first?.relationship, .equal)
        XCTAssertEqual(view.constraints.first?.offset, 100)
        XCTAssertEqual(view.constraints.first?.multiplier, 1)
        XCTAssertEqual(view.constraints.first?.priority, 1000)
    }
    
    func testCreateConstraintTwoViews() {
        let parent = View()
        let view1 = View()
        let view2 = View()
        parent.addSubview(view1)
        parent.addSubview(view2)
        
        let result = LayoutConstraint.create(first: view1.layout.left,
                                             second: view2.layout.left,
                                             relationship: .equal,
                                             offset: 10,
                                             multiplier: 2,
                                             priority: 100)
        
        XCTAssertEqual(view1.constraints, [result])
        XCTAssertEqual(view2.constraints, [result])
        XCTAssertTrue(result.container === parent)
        XCTAssertNotNil(view1.constraints.first?.second)
        XCTAssertEqual(view1.constraints.first?.relationship, .equal)
        XCTAssertEqual(view1.constraints.first?.offset, 10)
        XCTAssertEqual(view1.constraints.first?.multiplier, 2)
        XCTAssertEqual(view1.constraints.first?.priority, 100)
    }
    
    func testUpdateConstraintTwoViews() {
        let parent = View()
        let view1 = View()
        let view2 = View()
        parent.addSubview(view1)
        parent.addSubview(view2)
        let constraint = LayoutConstraint.create(first: view1.layout.left,
                                                 second: view2.layout.left,
                                                 relationship: .equal,
                                                 offset: 10,
                                                 multiplier: 2,
                                                 priority: 100)
        
        let result = LayoutConstraint.update(first: view1.layout.left,
                                             second: view2.layout.left,
                                             relationship: .equal,
                                             offset: 100,
                                             multiplier: 3,
                                             priority: 1000)
        
        XCTAssertEqual(constraint, result)
        XCTAssertEqual(view1.constraints, [constraint])
        XCTAssertEqual(view2.constraints, [constraint])
        XCTAssertTrue(constraint.container === parent)
        XCTAssertNotNil(view1.constraints.first?.second)
        XCTAssertEqual(view1.constraints.first?.relationship, .equal)
        XCTAssertEqual(view1.constraints.first?.offset, 100)
        XCTAssertEqual(view1.constraints.first?.multiplier, 3)
        XCTAssertEqual(view1.constraints.first?.priority, 1000)
    }
}
