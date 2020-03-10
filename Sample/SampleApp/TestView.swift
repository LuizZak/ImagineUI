//
//  TestView.swift
//  SampleApp
//
//  Created by luiz.fernando.silva on 29/01/20.
//  Copyright © 2020 luiz.fernando.silva. All rights reserved.
//

import Cocoa
import ImagineUI
import SwiftBlend2D

class TestView: NSView {
    var link: CVDisplayLink?

    var sample: Blend2DSample!
    var blImage: BLImage!
    var redrawBounds: [NSRect] = []

    override var bounds: NSRect {
        get {
            return super.bounds
        }
        set {
            super.bounds = newValue
        }
    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initializeDisplayLink()
        initializeSample()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeDisplayLink()
        initializeSample()
    }

    private func initializeDisplayLink() {
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        CVDisplayLinkSetOutputCallback(link!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(link!)
    }

    private func initializeSample() {
        let fileUrl = Bundle.main.path(forResource: "NotoSans-Regular", ofType: "ttf")
        Fonts.fontFilePath = fileUrl!

        let sample = ImagineUI(size: BLSizeI(w: Int32(bounds.width), h: Int32(bounds.height)))
        sample.delegate = self
        self.sample = sample

        blImage = BLImage(width: sample.width * Int(sample.sampleRenderScale.x),
                          height: sample.height * Int(sample.sampleRenderScale.y),
                          format: .xrgb32)
    }

    override func layout() {
        super.layout()

        resizeSample()
    }

    private func resizeSample() {
        sample.resize(width: Int(bounds.width), height: Int(bounds.height))

        blImage = BLImage(width: sample.width * Int(sample.sampleRenderScale.x),
                          height: sample.height * Int(sample.sampleRenderScale.y),
                          format: .xrgb32)

        redrawBounds.append(bounds)
        
        update()
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        let mouseEvent = makeMouseEventArgs(event)

        sample.mouseDown(event: mouseEvent)

        becomeFirstResponder()
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        let mouseEvent = makeMouseEventArgs(event)

        sample.mouseMoved(event: mouseEvent)
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)

        let mouseEvent = makeMouseEventArgs(event)

        sample.mouseMoved(event: mouseEvent)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        let mouseEvent = makeMouseEventArgs(event)

        sample.mouseUp(event: mouseEvent)
    }

    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)

        let mouseEvent = makeMouseEventArgs(event)

        sample.mouseScroll(event: mouseEvent)
    }

    override func keyDown(with event: NSEvent) {
        let keyboardEvent = makeKeyboardEventArgs(event)
        
        sample.keyDown(event: keyboardEvent)
    }

    override func keyUp(with event: NSEvent) {
        let keyboardEvent = makeKeyboardEventArgs(event)

        sample.keyUp(event: keyboardEvent)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        trackingAreas.forEach(removeTrackingArea(_:))

        let options: NSTrackingArea.Options = [.activeAlways, .inVisibleRect, .mouseEnteredAndExited, .mouseMoved]
        let area = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)

        addTrackingArea(area)
    }

    private func makeMouseEventArgs(_ event: NSEvent) -> MouseEventArgs {
        let windowPoint = event.locationInWindow
        let point = self.convert(windowPoint, from: nil)

        let mouseButton: MouseButton

        switch event.type {
        case .leftMouseDown, .leftMouseUp, .leftMouseDragged:
            mouseButton = .left
        case .rightMouseDown, .rightMouseUp, .rightMouseDragged:
            mouseButton = .right
        case .otherMouseDown, .otherMouseUp, .otherMouseDragged:
            mouseButton = .middle
        default:
            mouseButton = .none
        }

        var scrollingDeltaX = 0.0
        var scrollingDeltaY = 0.0
        if event.type == .scrollWheel {
            scrollingDeltaX = Double(event.scrollingDeltaX)
            scrollingDeltaY = Double(event.scrollingDeltaY)
        }
        
        let clickCount: Int
        if event.type == .leftMouseDown || event.type == .rightMouseDown || event.type == .otherMouseDown {
            clickCount = event.clickCount
        } else {
            clickCount = 0
        }

        return MouseEventArgs(location: Vector2(x: Double(point.x), y: Double(bounds.height - point.y)),
                              buttons: mouseButton,
                              delta: Vector2(x: scrollingDeltaX, y: scrollingDeltaY),
                              clicks: clickCount)
    }

    func update() {
        sample.update(CACurrentMediaTime())
        
        if let first = redrawBounds.first {
            let ctx = BLContext(image: blImage)!

            sample.render(context: ctx)

            ctx.end()
            
            let reduced = redrawBounds.reduce(first, { $0.union($1) })
            setNeedsDisplay(reduced)
            
            redrawBounds.removeAll()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current else {
            return
        }
        
        let imageData = blImage.getImageData()

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let imageContext = CGContext(data: imageData.pixelData,
                                     width: blImage.width,
                                     height: blImage.height,
                                     bitsPerComponent: 8,
                                     bytesPerRow: imageData.stride,
                                     space: colorSpace,
                                     bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGImageByteOrderInfo.order32Little.rawValue)

        let cgImage = imageContext!.makeImage()!

        context.imageInterpolation = .none
        context.shouldAntialias = false
        context.compositingOperation = .copy
        context.cgContext.draw(cgImage, in: bounds)
        context.flushGraphics()
    }
}

extension TestView: Blend2DSampleDelegate {
    func invalidate(bounds: Rectangle) {
        let rectBounds = NSRect(x: bounds.x,
                                y: Double(self.bounds.height) - bounds.y - bounds.height,
                                width: bounds.width,
                                height: bounds.height)

        let intersectedBounds = rectBounds.intersection(self.bounds)

        redrawBounds.append(intersectedBounds)
    }
}

func displayLinkOutputCallback(displayLink: CVDisplayLink,
                               _ inNow: UnsafePointer<CVTimeStamp>,
                               _ inOutputTime: UnsafePointer<CVTimeStamp>,
                               _ flagsIn: CVOptionFlags,
                               _ flagsOut: UnsafeMutablePointer<CVOptionFlags>,
                               _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {

    guard let context = displayLinkContext else {
        return kCVReturnSuccess
    }

    let view =
        Unmanaged<TestView>
            .fromOpaque(context)
            .takeUnretainedValue()

    DispatchQueue.main.async {
        view.update()
    }

    //  We are going to assume that everything went well for this mock up, and pass success as the CVReturn
    return kCVReturnSuccess
}
