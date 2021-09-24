import XCTest
@testable import ImagineUI
import Geometry
import SwiftBlend2D
import TestUtils
import Blend2DRenderer

extension SnapshotTestCase {
    func recordSnapshot(_ view: View, testName: String = #function,
                        file: StaticString = #file,
                        line: UInt = #line) {
        
        do {
            let img = try produceSnapshot(view)
            
            recordImage(img, testName, file: file, line: line)
        } catch {
            XCTFail("Error recording snapshot for \(testName): \(error)")
        }
    }
    
    func matchSnapshot(_ view: View, testName: String = #function,
                       file: StaticString = #file,
                       line: UInt = #line) {
        
        if forceRecordMode {
            recordSnapshot(view, testName: testName, file: file, line: line)
            return
        }
        
        do {
            let img = try produceSnapshot(view)
            
            assertImageMatch(img, testName, file: file, line: line)
        } catch {
            XCTFail("Error performing snapshot test for \(testName): \(error)",
                    file: file, line: line)
        }
    }
    
    func produceSnapshot(_ view: View) throws -> BLImage {
        let bounds = view.boundsForRedraw()
        if bounds.size.width <= .zero && bounds.size.height <= .zero {
            throw SnapshotError.emptyViewBounds
        }
        
        let region = BLRegion(rectangle: BLRectI(rounding: bounds.asBLRect))
        
        let image = BLImage(width: Int(ceil(bounds.width)),
                            height: Int(ceil(bounds.height)),
                            format: .prgb32)
        let ctx = BLContext(image: image)!
        ctx.clearAll()
        
        ctx.translate(x: -bounds.x, y: -bounds.y)
        
        let renderer = Blend2DRenderer(context: ctx)
        
        view.renderRecursive(in: renderer, screenRegion: Blend2DClipRegion(region: region))
        
        ctx.end()
        
        return image
    }
    
    enum SnapshotError: Error {
        case emptyViewBounds
    }
}
