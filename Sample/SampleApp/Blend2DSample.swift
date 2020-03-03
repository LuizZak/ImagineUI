import Foundation
import blend2d
import SwiftBlend2D
import ImagineUI

protocol Blend2DSampleDelegate: class {
    func invalidate(bounds: Rectangle)
}

protocol Blend2DSample: class {
    var width: Int { get }
    var height: Int { get }
    var sampleRenderScale: BLPoint { get }

    func resize(width: Int, height: Int)

    func update(_ time: TimeInterval)
    func render(context ctx: BLContext)

    func mouseDown(event: MouseEventArgs)
    func mouseMoved(event: MouseEventArgs)
    func mouseUp(event: MouseEventArgs)
    func mouseScroll(event: MouseEventArgs)

    func keyDown(event: KeyEventArgs)
    func keyUp(event: KeyEventArgs)
}

extension Blend2DSample {
    func update(_ time: TimeInterval) {

    }

    func mouseDown(event: MouseEventArgs) { }
    func mouseMoved(event: MouseEventArgs) { }
    func mouseUp(event: MouseEventArgs) { }
    func mouseScroll(event: MouseEventArgs) { }
    func keyDown(event: KeyEventArgs) { }
    func keyUp(event: KeyEventArgs) { }
}
