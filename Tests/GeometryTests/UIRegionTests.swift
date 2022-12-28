import XCTest
@testable import Geometry

class UIRegionTests: XCTestCase {
    func testEphemeral() {
        let sut = UIRegion()

        XCTAssertTrue(sut.isEmpty)
        assertEquals(sut.allRectangles(), [])
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

        sut.addRectangle(rect1)
        sut.addRectangle(rect2)

        assertEquals(sut.allRectangles(), [
            .init(left: 5, top: 5, right: 15, bottom: 10),
            .init(left: 5, top: 10, right: 20, bottom: 15),
            .init(left: 10, top: 15, right: 20, bottom: 20),
        ])
    }

    func testAddRectangle_add_empty() {
        let sut = UIRegion()
        let rect = UIRectangle(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0)

        sut.addRectangle(rect, operation: .add)

        assertEquals(sut.allRectangles(), [rect])
    }

    func testAddRectangle_add_contained() {
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0)
        let rect2 = UIRectangle(left: 2.0, top: 2.0, right: 7.0, bottom: 7.0)

        sut.addRectangle(rect1, operation: .add)
        sut.addRectangle(rect2, operation: .add)

        assertEquals(sut.allRectangles(), [rect1])
    }

    func testAddRectangle_add_nonIntersecting() {
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0)
        let rect2 = UIRectangle(left: 5.0, top: 15.0, right: 10.0, bottom: 20.0)

        sut.addRectangle(rect1, operation: .add)
        sut.addRectangle(rect2, operation: .add)

        assertEquals(sut.allRectangles(), [rect1, rect2])
    }

    func testAddRectangle_add_intersecting() {
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 5, top: 5, right: 15, bottom: 15)
        let rect2 = UIRectangle(left: 10, top: 10, right: 20, bottom: 20)

        sut.addRectangle(rect1, operation: .add)
        sut.addRectangle(rect2, operation: .add)

        assertEquals(sut.allRectangles(), [
            .init(left: 5, top: 5, right: 15, bottom: 10),
            .init(left: 5, top: 10, right: 20, bottom: 15),
            .init(left: 10, top: 15, right: 20, bottom: 20),
        ])
    }

    func testAddRectangle_add_sideBySide_merges() {
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 0, top: 0, right: 10, bottom: 10)
        let rect2 = UIRectangle(left: 10, top: 0, right: 20, bottom: 10)

        sut.addRectangle(rect1, operation: .add)
        sut.addRectangle(rect2, operation: .add)

        assertEquals(sut.allRectangles(), [
            .init(left: 0, top: 0, right: 20, bottom: 10),
        ])
    }

    func testAddRectangle_subtract_empty() {
        let sut = UIRegion()
        let rect = UIRectangle(left: 0, top: 0, right: 10, bottom: 10)

        sut.addRectangle(rect, operation: .subtract)

        assertEquals(sut.allRectangles(), [])
    }

    func testAddRectangle_subtract_nonIntersecting() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 10.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
        let rect = UIRectangle(left: 0, top: 40, right: 10, bottom: 45)

        sut.addRectangle(rect, operation: .subtract)

        assertEquals(sut.allRectangles(), [
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

        assertEquals(sut.allRectangles(), [
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

        assertEquals(sut.allRectangles(), [
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

        assertEquals(sut.allRectangles(), [])
    }

    func testAddRectangle_intersect_empty() {
        let sut = UIRegion()
        let rect = UIRectangle(left: 0, top: 0, right: 10, bottom: 10)

        sut.addRectangle(rect, operation: .intersect)

        assertEquals(sut.allRectangles(), [])
    }

    func testAddRectangle_intersect_nonIntersecting_singleRect() {
        let sut = UIRegion(rectangles: [
            .init(left: 10, top: 10, right: 20, bottom: 20),
        ])
        let rect = UIRectangle(left: 0, top: 0, right: 5, bottom: 5)

        sut.addRectangle(rect, operation: .intersect)

        assertEquals(sut.allRectangles(), [])
    }

    func testAddRectangle_intersect_nonIntersecting_multiRect() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 10.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
        let rect = UIRectangle(left: 0, top: 40, right: 10, bottom: 45)

        sut.addRectangle(rect, operation: .intersect)

        assertEquals(sut.allRectangles(), [])
    }

    func testAddRectangle_intersect_intersecting() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 20.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 10.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
        let rect = UIRectangle(left: 5, top: 5, right: 25, bottom: 25)

        sut.addRectangle(rect, operation: .intersect)

        assertEquals(sut.allRectangles(), [
            .init(left: 5.0, top: 5.0, right: 20.0, bottom: 10.0),
            .init(left: 5.0, top: 10.0, right: 25.0, bottom: 20.0),
            .init(left: 10.0, top: 20.0, right: 25.0, bottom: 25.0),
        ])
    }

    func testAddRectangle_xor_empty() {
        let sut = UIRegion()
        let rect = UIRectangle(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0)

        sut.addRectangle(rect, operation: .xor)

        assertEquals(sut.allRectangles(), [rect])
    }

    func testAddRectangle_xor_nonIntersecting() {
        let sut = UIRegion(rectangles: [
            .init(left: 0.0, top: 0.0, right: 10.0, bottom: 10.0),
        ])
        let rect = UIRectangle(left: 5.0, top: 15.0, right: 10.0, bottom: 20.0)

        sut.addRectangle(rect, operation: .xor)

        assertEquals(sut.allRectangles(), [
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

        assertEquals(sut.allRectangles(), [
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

        assertEquals(sut.allRectangles(), [
            .init(left: 0.0, top: 0.0, right: 30.0, bottom: 10.0),
            .init(left: 0.0, top: 10.0, right: 10.0, bottom: 20.0),
            .init(left: 20.0, top: 10.0, right: 30.0, bottom: 20.0),
            .init(left: 0.0, top: 20.0, right: 30.0, bottom: 30.0),
        ])
    }

    func testAddRectangle_xor_ladder_overlapping() {
        // Repeatedly add a box that is shifted right and downwards, overlapping
        // the previous placed box.
        let sut = UIRegion()
        let box = UIRectangle(location: .zero, size: .init(width: 10, height: 10))
        let translation = UIPoint(x: 5, y: 5)

        for i in 0..<5 {
            sut.addRectangle(box.offsetBy(translation * i), operation: .xor)
        }

        assertEquals(sut.allRectangles(), [
            .init(left: 0.0, top: 0.0, right: 10.0, bottom: 5.0),
            .init(left: 0.0, top: 5.0, right: 5.0, bottom: 10.0),
            .init(left: 10.0, top: 5.0, right: 15.0, bottom: 10.0),
            .init(left: 5.0, top: 10.0, right: 10.0, bottom: 15.0),
            .init(left: 15.0, top: 10.0, right: 20.0, bottom: 15.0),
            .init(left: 10.0, top: 15.0, right: 15.0, bottom: 20.0),
            .init(left: 20.0, top: 15.0, right: 25.0, bottom: 20.0),
            .init(left: 15.0, top: 20.0, right: 20.0, bottom: 25.0),
            .init(left: 25.0, top: 20.0, right: 30.0, bottom: 25.0),
            .init(left: 20.0, top: 25.0, right: 30.0, bottom: 30.0),
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

        assertEquals(sut.allRectangles(), [
            .init(left:  0.0, top:  0.0, right: 40.0, bottom: 10.0),
            .init(left:  0.0, top: 10.0, right: 10.0, bottom: 30.0),
            .init(left: 50.0, top: 15.0, right: 60.0, bottom: 40.0),
            .init(left: 20.0, top: 40.0, right: 60.0, bottom: 45.0),
        ])
        
        // End result should be:
        //    0       10      20      30      40      50      60
        // 0  +-------·-------·-------·-------+                 
        //    |                               |                 
        //    |                               |                 
        //    |                               |                 
        // 10 +-------·-------·-------·-------+                 
        //    |       |                                         
        // 15 + -  -  +  -  -  -  -  -  -  -  -  -  - +-------+ 
        //    |       |                               |       | 
        // 20 |       |                               |       | 
        //    |       |                               |       | 
        //    |       |                               |       | 
        //    |       |                               |       | 
        // 30 +-------+                               |       | 
        //                                            |       | 
        //                                            |       | 
        //                                            |       | 
        // 40                 +-------·-------·-------+-------+ 
        //                    |                               | 
        // 45                 +-------·-------·-------·-------+ 
    }

    func testAddRectangle_repeatedComplexSlicing() {
        // Re-use same setup as testAddRectangle_complex but repeat the operations
        // circling around the origin
        let sut = UIRegion()
        let rect1 = UIRectangle(left: 0, top: 0, right: 40, bottom: 30)
        let rect2 = UIRectangle(left: 20, top: 15, right: 60, bottom: 45)
        let rect3 = UIRectangle(left: 10, top: 10, right: 50, bottom: 40)

        for index in 0..<60 {
            let t = Double(index)
            let r = (t * 14) * (.pi / 360)
            let dx = cos(r) * 20
            let dy = sin(r) * 20

            let offset = UIVector(x: dx, y: dy)
            
            let rect1t = rect1.offsetBy(offset)
            let rect2t = rect2.offsetBy(offset)
            let rect3t = rect3.offsetBy(offset)

            sut.addRectangle(rect1t, operation: .add)
            sut.addRectangle(rect2t, operation: .add)
            sut.addRectangle(rect3t, operation: .subtract)
        }

        assertEquals(Set(sut.allRectangles()), [
            .init(left: -1.3951294748825116, top: -19.696155060244163, right: 43.4729635533386, bottom: -19.63254366895328),
            .init(left: -1.3951294748825116, top: -19.951281005196485, right: 41.04671912485888, bottom: -19.696155060244163),
            .init(left: -10.5983852846641, top: -15.760215072134436, right: 52.31322950651317, bottom: -15.542919229139411),
            .init(left: -10.5983852846641, top: -16.96096192312852, right: 50.300761498201084, bottom: -15.760215072134436),
            .init(left: -11.75570504584946, top: 44.62707403238341, right: -8.910371511986337, bottom: 46.180339887498945),
            .init(left: -12.586407820996756, top: -14.142135623730955, right: 54.14213562373095, bottom: -13.893167409179947),
            .init(left: -12.586407820996756, top: -15.542919229139411, right: 52.31322950651317, bottom: -14.142135623730955),
            .init(left: -13.639967201249966, top: 42.855752193730794, right: -9.562952014676114, bottom: 44.158233816355185),
            .init(left: -13.639967201249966, top: 44.158233816355185, right: -8.910371511986337, bottom: 44.62707403238341),
            .init(left: -14.386796006773022, top: -12.313229506513164, right: 55.76021507213444, bottom: -12.036300463040968),
            .init(left: -14.386796006773022, top: -13.893167409179947, right: 54.14213562373095, bottom: -12.313229506513164),
            .init(left: -15.320888862379558, top: 40.89278070030055, right: -9.92389396183491, bottom: 41.74311485495316),
            .init(left: -15.320888862379558, top: 41.74311485495316, right: -9.562952014676114, bottom: 42.855752193730794),
            .init(left: -15.972710200945857, top: -10.30076149820109, right: 57.14334601404225, bottom: -10.000000000000002),
            .init(left: -15.972710200945857, top: -12.036300463040968, right: 55.76021507213444, bottom: -10.30076149820109),
            .init(left: -16.77341135890848, top: 38.767422935781546, right: -9.987816540381914, bottom: 39.302010065949986),
            .init(left: -16.77341135890848, top: 39.302010065949986, right: -9.92389396183491, bottom: 40.89278070030055),
            .init(left: -17.32050807568877, top: -10.000000000000002, right: 57.143346014042244, bottom: -8.134732861516003),
            .init(left: -17.32050807568877, top: -8.134732861516003, right: 58.27090915285202, bottom: -7.814622569785471),
            .init(left: -17.97588092598334, top: 36.51136308914313, right: -9.987816540381914, bottom: 38.767422935781546),
            .init(left: -18.410097069048806, top: -5.847434094454743, right: 59.12609511926071, bottom: -5.51274711633998),
            .init(left: -18.410097069048806, top: -7.814622569785471, right: 58.27090915285203, bottom: -5.847434094454743),
            .init(left: -18.910371511986337, top: 34.158233816355185, right: -9.987816540381914, bottom: 36.51136308914313),
            .init(left: -19.225233918766378, top: -3.472963553338608, right: 59.696155060244166, bottom: -3.1286893008046146),
            .init(left: -19.225233918766378, top: -5.51274711633998, right: 59.12609511926071, bottom: -3.472963553338608),
            .init(left: -19.225233918766378, top: 23.38261212717716, right: -9.225233918766378, bottom: 23.382612127177165),
            .init(left: -19.562952014676114, top: 31.743114854953163, right: -9.987816540381914, bottom: 34.158233816355185),
            .init(left: -19.753766811902757, top: -1.0467191248588874, right: 59.972590695091476, bottom: -0.697989934050018),
            .init(left: -19.753766811902757, top: -3.1286893008046146, right: 59.69615506024416, bottom: -1.0467191248588872),
            .init(left: -19.92389396183491, top: 29.302010065949982, right: -9.987816540381914, bottom: 31.743114854953163),
            .init(left: -19.987816540381914, top: -0.697989934050018, right: 59.97259069509147, bottom: 3.8161799075309015),
            .init(left: -19.987816540381914, top: 10.367456331046721, right: 3.8196601125010474, bottom: 10.97886967409693),
            .init(left: -19.987816540381914, top: 10.97886967409693, right: 1.547634765186018, bottom: 11.873844259266999),
            .init(left: -19.987816540381914, top: 11.873844259266999, right: -0.5983852846641007, bottom: 13.039038076871481),
            .init(left: -19.987816540381914, top: 13.039038076871481, right: -2.5864078209967545, bottom: 14.457080770860589),
            .init(left: -19.987816540381914, top: 14.457080770860589, right: -4.386796006773022, bottom: 16.106832590820055),
            .init(left: -19.987816540381914, top: 16.106832590820055, right: -5.972710200945857, bottom: 17.963699536959034),
            .init(left: -19.987816540381914, top: 17.963699536959034, right: -7.320508075688771, bottom: 20.0),
            .init(left: -19.987816540381914, top: 20.0, right: -8.410097069048806, bottom: 22.18537743021453),
            .init(left: -19.987816540381914, top: 22.18537743021453, right: -9.225233918766378, bottom: 23.38261212717716),
            .init(left: -19.987816540381914, top: 23.382612127177165, right: -9.225233918766378, bottom: 24.48725288366002),
            .init(left: -19.987816540381914, top: 24.48725288366002, right: -9.753766811902757, bottom: 26.871310699195384),
            .init(left: -19.987816540381914, top: 26.871310699195384, right: -9.987816540381914, bottom: 27.855752193730787),
            .init(left: -19.987816540381914, top: 27.85575219373079, right: -9.987816540381914, bottom: 29.302010065949982),
            .init(left: -19.987816540381914, top: 3.816179907530901, right: 59.97259069509147, bottom: 8.953280875141113),
            .init(left: -19.987816540381914, top: 8.953280875141113, right: 59.95128100519648, bottom: 10.367456331046721),
            .init(left: -3.816179907530892, top: -19.126095119260707, right: 45.847434094454734, bottom: -19.02113032590307),
            .init(left: -3.816179907530892, top: -19.63254366895328, right: 43.4729635533386, bottom: -19.126095119260707),
            .init(left: -6.180339887498951, top: -18.27090915285202, right: 48.134732861516, bottom: -18.126155740733),
            .init(left: -6.180339887498951, top: -19.02113032590307, right: 45.847434094454734, bottom: -18.27090915285202),
            .init(left: -8.452365234813984, top: -17.143346014042248, right: 50.300761498201084, bottom: -16.96096192312852),
            .init(left: -8.452365234813984, top: -18.126155740733, right: 48.134732861516, bottom: -17.143346014042248),
            .init(left: -9.696192404926741, top: 46.180339887498945, right: -8.910371511986337, bottom: 46.51136308914313),
            .init(left: -9.696192404926741, top: 46.51136308914313, right: -7.97588092598334, bottom: 47.492394142787916),
            .init(left: 0.01218345961808609, top: 39.302010065949986, right: 22.036300463040966, bottom: 44.302010065949986),
            .init(left: 0.07610603816508998, top: 44.302010065949986, right: 22.036300463040966, bottom: 46.74311485495316),
            .init(left: 0.24623318809724282, top: 36.871310699195384, right: 22.036300463040966, bottom: 39.302010065949986),
            .init(left: 0.4370479853238862, top: 46.74311485495316, right: 22.036300463040966, bottom: 49.158233816355185),
            .init(left: 0.7747660812336221, top: 34.48725288366002, right: 22.036300463040966, bottom: 36.871310699195384),
            .init(left: 1.046719124858879, top: -19.972590695091476, right: 41.04671912485888, bottom: -19.951281005196485),
            .init(left: 1.0896284880136626, top: 49.158233816355185, right: 22.036300463040966, bottom: 51.51136308914313),
            .init(left: 1.5899029309511938, top: 32.18537743021453, right: 22.036300463040966, bottom: 34.48725288366002),
            .init(left: 10.300761498201084, top: 11.72909084714798, right: 59.632543668953275, bottom: 12.856653985957752),
            .init(left: 10.303807595073259, top: 61.180339887498945, right: 71.18385806941494, bottom: 61.58075145110084),
            .init(left: 10.303807595073259, top: 61.58075145110084, right: 69.07980999479093, bottom: 62.492394142787916),
            .init(left: 11.547634765186016, top: 21.873844259267, right: 55.542919229139414, bottom: 22.58640782099675),
            .init(left: 11.547634765186016, top: 22.58640782099675, right: 53.89316740917995, bottom: 23.03903807687148),
            .init(left: 12.036300463040968, top: 15.972710200945857, right: 59.02113032590307, bottom: 16.180339887498945),
            .init(left: 12.036300463040968, top: 16.180339887498945, right: 58.126155740733, bottom: 18.45236523481399),
            .init(left: 12.036300463040968, top: 18.45236523481399, right: 56.96096192312852, bottom: 20.598385284664094),
            .init(left: 12.036300463040968, top: 20.598385284664094, right: 55.542919229139414, bottom: 21.873844259267),
            .init(left: 12.31322950651317, top: 12.856653985957752, right: 59.632543668953275, bottom: 13.816179907530902),
            .init(left: 12.31322950651317, top: 13.816179907530902, right: 59.02113032590307, bottom: 14.239784927865564),
            .init(left: 12.507868131681759, top: 62.492394142787916, right: 69.07980999479093, bottom: 62.82013048376736),
            .init(left: 12.507868131681759, top: 62.82013048376736, right: 66.84040286651337, bottom: 63.54367709133575),
            .init(left: 13.893167409179952, top: 14.386796006773018, right: 59.02113032590307, bottom: 15.972710200945857),
            .init(left: 14.142135623730947, top: 14.239784927865564, right: 59.02113032590307, bottom: 14.386796006773018),
            .init(left: 14.823619097949583, top: 63.54367709133575, right: 66.84040286651337, bottom: 63.79385241571816),
            .init(left: 14.823619097949583, top: 63.79385241571816, right: 64.49902108687729, bottom: 64.31851652578136),
            .init(left: 17.21653798079869, top: 64.31851652578136, right: 64.49902108687729, bottom: 64.4874012957047),
            .init(left: 17.21653798079869, top: 64.4874012957047, right: 62.09056926535307, bottom: 64.8053613748314),
            .init(left: 19.650951871254332, top: 64.8053613748314, right: 62.09056926535307, bottom: 64.89043790736547),
            .init(left: 19.650951871254332, top: 64.89043790736547, right: 59.650951871254335, bottom: 64.99695390312783),
            .init(left: 2.02411907401666, top: 51.51136308914313, right: 22.036300463040966, bottom: 53.767422935781546),
            .init(left: 2.679491924311229, top: 30.0, right: 22.036300463040966, bottom: 32.18537743021453),
            .init(left: 3.2265886410915208, top: 53.767422935781546, right: 22.036300463040966, bottom: 55.89278070030055),
            .init(left: 4.027289799054143, top: 27.963699536959034, right: 22.036300463040966, bottom: 30.0),
            .init(left: 4.679111137620442, top: 55.89278070030055, right: 22.036300463040966, bottom: 55.972710200945855),
            .init(left: 4.679111137620442, top: 55.972710200945855, right: 76.38304088577985, bottom: 56.471528727020925),
            .init(left: 4.679111137620442, top: 56.471528727020925, right: 75.54291922913941, bottom: 57.586407820996754),
            .init(left: 4.679111137620442, top: 57.586407820996754, right: 74.86289650954788, bottom: 57.855752193730794),
            .init(left: 5.613203993226978, top: 26.106832590820055, right: 22.036300463040966, bottom: 27.963699536959034),
            .init(left: 5.8474340944547345, top: 10.367456331046721, right: 59.951281005196485, bottom: 10.873904880739293),
            .init(left: 6.360032798750034, top: 57.855752193730794, right: 74.86289650954788, bottom: 58.38261212717717),
            .init(left: 6.360032798750034, top: 58.38261212717717, right: 73.89316740917997, bottom: 59.38679600677302),
            .init(left: 6.360032798750034, top: 59.38679600677302, right: 73.12118057981016, bottom: 59.62707403238341),
            .init(left: 62.036300463040966, top: 30.972710200945855, right: 80.0, bottom: 45.0),
            .init(left: 62.036300463040966, top: 45.0, right: 79.95128100519648, bottom: 46.3951294748825),
            .init(left: 62.036300463040966, top: 46.3951294748825, right: 79.85092303282644, bottom: 47.43738686810295),
            .init(left: 62.036300463040966, top: 47.43738686810295, right: 79.63254366895328, bottom: 48.8161799075309),
            .init(left: 62.036300463040966, top: 48.8161799075309, right: 79.40591452551993, bottom: 49.83843791199335),
            .init(left: 62.036300463040966, top: 49.83843791199335, right: 79.02113032590307, bottom: 51.180339887498945),
            .init(left: 62.036300463040966, top: 51.180339887498945, right: 78.67160852994405, bottom: 52.16735899090601),
            .init(left: 62.036300463040966, top: 52.16735899090601, right: 78.126155740733, bottom: 53.45236523481399),
            .init(left: 62.036300463040966, top: 53.45236523481399, right: 77.65895185717855, bottom: 54.38943125571782),
            .init(left: 62.036300463040966, top: 54.38943125571782, right: 76.96096192312852, bottom: 55.59838528466409),
            .init(left: 62.036300463040966, top: 55.59838528466409, right: 76.38304088577985, bottom: 55.972710200945855),
            .init(left: 62.31322950651317, top: -4.696155060244163, right: 63.4729635533386, bottom: -4.142135623730955),
            .init(left: 63.89316740917995, top: 29.386796006773018, right: 80.0, bottom: 30.972710200945855),
            .init(left: 64.14213562373095, top: -3.2709091528520204, right: 68.134732861516, bottom: -2.3132295065131636),
            .init(left: 64.14213562373095, top: -4.126095119260707, right: 65.84743409445474, bottom: -3.2709091528520204),
            .init(left: 65.54291922913941, top: 27.58640782099675, right: 80.0, bottom: 29.386796006773018),
            .init(left: 65.76021507213444, top: -0.697989934050018, right: 72.31322950651317, bottom: -0.30076149820109066),
            .init(left: 65.76021507213444, top: -0.7602150721344358, right: 72.31322950651318, bottom: -0.697989934050018),
            .init(left: 65.76021507213444, top: -2.1433460140422476, right: 70.3007614982011, bottom: -0.7602150721344358),
            .init(left: 65.76021507213444, top: -2.3132295065131636, right: 68.134732861516, bottom: -2.1433460140422476),
            .init(left: 66.96096192312852, top: 25.598385284664094, right: 80.0, bottom: 27.58640782099675),
            .init(left: 67.14334601404224, top: -0.30076149820109066, right: 72.31322950651317, bottom: 0.8578643762690454),
            .init(left: 67.14334601404224, top: 0.8578643762690454, right: 74.14213562373095, bottom: 1.865267138483997),
            .init(left: 68.126155740733, top: 23.45236523481399, right: 80.0, bottom: 25.598385284664094),
            .init(left: 68.27090915285203, top: 1.865267138483997, right: 74.14213562373095, bottom: 2.6867704934868364),
            .init(left: 68.27090915285203, top: 2.6867704934868364, right: 75.76021507213444, bottom: 4.152565905545257),
            .init(left: 69.02113032590307, top: 21.180339887498945, right: 80.0, bottom: 23.45236523481399),
            .init(left: 69.12609511926071, top: 4.152565905545257, right: 75.76021507213444, bottom: 4.699238501798909),
            .init(left: 69.12609511926071, top: 4.699238501798909, right: 77.14334601404224, bottom: 6.527036446661392),
            .init(left: 69.63254366895328, top: 18.816179907530902, right: 80.0, bottom: 21.180339887498945),
            .init(left: 69.69615506024417, top: 6.527036446661392, right: 77.14334601404224, bottom: 6.865267138483997),
            .init(left: 69.69615506024417, top: 6.865267138483997, right: 78.27090915285203, bottom: 8.953280875141113),
            .init(left: 69.95128100519648, top: 16.395129474882502, right: 80.0, bottom: 18.816179907530902),
            .init(left: 69.97259069509147, top: 11.527036446661391, right: 79.69615506024417, bottom: 13.953280875141113),
            .init(left: 69.97259069509147, top: 13.953280875141113, right: 79.97259069509147, bottom: 15.0),
            .init(left: 69.97259069509147, top: 15.0, right: 80.0, bottom: 16.395129474882502),
            .init(left: 69.97259069509147, top: 8.953280875141113, right: 78.27090915285203, bottom: 9.152565905545256),
            .init(left: 69.97259069509147, top: 9.152565905545256, right: 79.12609511926071, bottom: 11.527036446661391),
            .init(left: 7.413592179003244, top: 24.45708077086059, right: 52.036300463040966, bottom: 25.972710200945855),
            .init(left: 7.413592179003244, top: 25.972710200945855, right: 22.036300463040966, bottom: 26.106832590820055),
            .init(left: 8.134732861515996, top: 10.873904880739293, right: 59.95128100519649, bottom: 11.395129474882502),
            .init(left: 8.134732861515996, top: 11.395129474882502, right: 59.632543668953275, bottom: 11.72909084714798),
            .init(left: 8.24429495415054, top: 59.62707403238341, right: 73.12118057981016, bottom: 60.09419160445544),
            .init(left: 8.24429495415054, top: 60.09419160445544, right: 72.03630046304096, bottom: 60.972710200945855),
            .init(left: 8.24429495415054, top: 60.972710200945855, right: 71.18385806941494, bottom: 61.180339887498945),
            .init(left: 9.4016147153359, top: 23.03903807687148, right: 53.89316740917995, bottom: 24.386796006773018),
            .init(left: 9.4016147153359, top: 24.386796006773018, right: 52.03630046304096, bottom: 24.45708077086059),
        ])
    }

    // MARK: - Performance tests

    func testPerformance_repeatedComplexSlicing() {
        // Re-use same setup as testAddRectangle_complex but repeat the operations
        // circling around the origin
        let rect1 = UIRectangle(left: 0, top: 0, right: 40, bottom: 30)
        let rect2 = UIRectangle(left: 20, top: 15, right: 60, bottom: 45)
        let rect3 = UIRectangle(left: 10, top: 10, right: 50, bottom: 40)

        doPerformanceTest(repeatCount: 5) {
            let sut = UIRegion()

            for index in 0..<60 {
                let t = Double(index)
                let r = (t * 14) * (.pi / 360)
                let dx = cos(r) * 20
                let dy = sin(r) * 20

                let offset = UIVector(x: dx, y: dy)
                
                let rect1t = rect1.offsetBy(offset)
                let rect2t = rect2.offsetBy(offset)
                let rect3t = rect3.offsetBy(offset)

                sut.addRectangle(rect1t, operation: .add)
                sut.addRectangle(rect2t, operation: .add)
                sut.addRectangle(rect3t, operation: .subtract)
            }
        }
    }

    // MARK: - Test internals
    private func doPerformanceTest(
        repeatCount: Int = 1,
        file: StaticString = #file,
        line: Int = #line,
        run block: @escaping () -> Void
    ) {

        measure(file: file, line: line) {
            var repeatCount = repeatCount
            
            while repeatCount > 0 {
                repeatCount -= 1

                block()
            }
        }
    }
}

private func assertEquals<C: Collection>(
    _ actual: C,
    _ expected: C,
    line: UInt = #line
) where C.Element == UIRectangle, C: Equatable & ExpressibleByArrayLiteral {

    guard actual != expected else {
        return
    }

    let format: (UIRectangle) -> String = {
        ".init(left: \($0.left), top: \($0.top), right: \($0.right), bottom: \($0.bottom))"
    }
    let formatCollection: (C) -> String = {
        if $0.isEmpty {
            return "[]"
        }

        return "[\n    " + $0.map(format).joined(separator: ",\n    ") + ",\n]"
    }

    let v1Format = formatCollection(actual)
    let v2Format = formatCollection(expected)

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
