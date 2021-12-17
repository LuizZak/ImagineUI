import XCTest
import Geometry
@testable import ImagineUICore

class ViewTests: XCTestCase {
    func testLayoutWithNoSuperview() {
        let view = View()
        view.layout.makeConstraints { make in
            make.top == 0
            make.left == 0
            make.width == 100
            make.height == 20
        }
        
        view.performLayout()
        
        XCTAssertEqual(view.location, .zero)
        XCTAssertEqual(view.size, UISize(width: 100, height: 20))
    }
    
    // MARK: - addSubview / removeFromSuperview
    
    func testAddSubview() {
        let view = View()
        let child = View()
        
        view.addSubview(child)
        
        XCTAssertEqual(child.superview, view)
        XCTAssertEqual(view.subviews, [child])
    }
    
    func testAddSubviewRemovesSubviewFromPreviousView() {
        let view1 = View()
        let view2 = View()
        let child = View()
        view1.addSubview(child)
        
        view2.addSubview(child)
        
        XCTAssertEqual(child.superview, view2)
        XCTAssert(view1.subviews.isEmpty)
        XCTAssertEqual(view2.subviews, [child])
    }
    
    func testRemoveFromSuperview() {
        let view = View()
        let child = View()
        view.addSubview(child)
        
        child.removeFromSuperview()
        
        XCTAssertNil(child.superview)
        XCTAssert(view.subviews.isEmpty)
    }
    
    func testRemoveFromSuperviewRemovesConstraintFromOutsideHierarchy() {
        let base = View()
        let view1 = View()
        let view2 = View()
        let child = View()
        base.addSubview(view1)
        base.addSubview(view2)
        view1.addSubview(child)
        child.layout.makeConstraints { make in
            make.left == view1
            make.left == view2
        }
        
        view1.removeFromSuperview()
        
        XCTAssertEqual(child.constraints.count, 1)
        XCTAssert(child.constraints.first?.first.owner === child)
        XCTAssert(child.constraints.first?.second?.owner === view1)
    }
    
    func testRemoveFromSuperviewRemovesConstraintFromOutsideHierarchy_LayoutGuides() {
        let base = View()
        let view1 = View()
        let view2 = View()
        let guide = LayoutGuide()
        base.addSubview(view1)
        base.addSubview(view2)
        view1.addLayoutGuide(guide)
        guide.layout.makeConstraints { make in
            make.left == view1
            make.left == view2
        }
        
        view1.removeFromSuperview()
        
        XCTAssertEqual(guide.constraints.count, 1)
        XCTAssert(guide.constraints.first?.first.owner === guide)
        XCTAssert(guide.constraints.first?.second?.owner === view1)
    }
    
    // MARK: - setNeedsLayout / suspendLayout / resumeLayout
    
    func testSetNeedsLayout() {
        class Spy: View {
            var didCallSetNeedsLayout = false
            override func setNeedsLayout() {
                super.setNeedsLayout()
                
                didCallSetNeedsLayout = true
            }
        }
        
        let view = View()
        let spy = Spy()
        spy.addSubview(view)
        spy.performLayout()
        
        view.setNeedsLayout()
        
        XCTAssert(spy.didCallSetNeedsLayout)
        XCTAssert(view.needsLayout)
    }
    
    func testSuspendLayout() {
        class Spy: View {
            var didCallSetNeedsLayout = false
            override func setNeedsLayout() {
                super.setNeedsLayout()
                
                didCallSetNeedsLayout = true
            }
        }
        
        let view = View()
        let spy = Spy()
        view.suspendLayout()
        spy.addSubview(view)
        spy.performLayout()
        spy.didCallSetNeedsLayout = false
        
        view.setNeedsLayout()
        
        XCTAssertFalse(spy.didCallSetNeedsLayout)
        XCTAssertFalse(view.needsLayout)
    }
    
    func testResumeLayout() {
        class Spy: View {
            var didCallSetNeedsLayout = false
            override func setNeedsLayout() {
                super.setNeedsLayout()
                
                didCallSetNeedsLayout = true
            }
        }
        
        let view = View()
        let spy = Spy()
        view.suspendLayout()
        spy.addSubview(view)
        spy.performLayout()
        spy.didCallSetNeedsLayout = false
        
        view.resumeLayout(setNeedsLayout: false)
        
        view.setNeedsLayout()
        
        XCTAssert(spy.didCallSetNeedsLayout)
        XCTAssert(view.needsLayout)
    }
    
    func testResumeLayoutSetNeedsLayoutTrue() {
        class Spy: View {
            var didCallSetNeedsLayout = false
            override func setNeedsLayout() {
                super.setNeedsLayout()
                
                didCallSetNeedsLayout = true
            }
        }
        
        let view = View()
        let spy = Spy()
        view.suspendLayout()
        spy.addSubview(view)
        spy.performLayout()
        spy.didCallSetNeedsLayout = false
        
        view.resumeLayout(setNeedsLayout: true)
        
        XCTAssert(spy.didCallSetNeedsLayout)
        XCTAssert(view.needsLayout)
    }
    
    // MARK: - Layout Guides
    
    func testAddLayoutGuide() {
        let view = View()
        let guide = LayoutGuide()
        
        view.addLayoutGuide(guide)
        
        XCTAssertEqual(guide.owningView, view)
        XCTAssertEqual(view.layoutGuides, [guide])
    }
    
    func testAddLayoutGuideRemovesGuideFromPreviousView() {
        let view1 = View()
        let view2 = View()
        let guide = LayoutGuide()
        view1.addLayoutGuide(guide)
        
        view2.addLayoutGuide(guide)
        
        XCTAssertEqual(guide.owningView, view2)
        XCTAssertEqual(view2.layoutGuides, [guide])
        XCTAssert(view1.layoutGuides.isEmpty)
    }
    
    func testRemoveLayoutGuide() {
        let view = View()
        let guide = LayoutGuide()
        view.addLayoutGuide(guide)
        
        guide.removeFromSuperview()
        
        XCTAssertNil(guide.owningView)
        XCTAssert(view.layoutGuides.isEmpty)
    }
    
    // MARK: -
}
