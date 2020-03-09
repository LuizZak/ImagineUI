import SwiftBlend2D

public class ProgressBar: ControlView {
    public var progress: Double = 0 {
        didSet {
            progress = min(1, max(0, progress))
            invalidateControlGraphics()
        }
    }
    
    public var fillColor: BLRgba32 = .royalBlue {
        didSet {
            invalidateControlGraphics()
        }
    }
    
    public override var intrinsicSize: Size? {
        return Size(x: bounds.width, y: 5)
    }
    
    public override init() {
        super.init()
        backColor = .lightGray
        strokeColor = .lightGray
        strokeWidth = 1
    }
    
    public override func renderBackground(in context: BLContext, screenRegion: BLRegion) {
        let rect = progressBarRoundRect()
        
        context.setFillStyle(backColor)
        context.fillRoundRect(rect)
        
        context.save()
        context.clipToRect(boundsForCurrentProgress().asBLRect)
        
        context.setFillStyle(fillColor)
        context.fillRoundRect(rect)
        context.restore()
        
        context.setStrokeStyle(strokeColor)
        context.setStrokeWidth(strokeWidth)
        context.strokeRoundRect(rect)
    }
    
    func progressBarRoundRect() -> BLRoundRect {
        let rect = progressBarBounds().asBLRect
        return BLRoundRect(rect: rect, radius: BLPoint(x: rect.h / 2, y: rect.h / 2))
    }
    
    func progressBarBounds() -> Rectangle {
        return bounds
    }
    
    func boundsForCurrentProgress() -> Rectangle {
        let bounds = progressBarBounds()
        return bounds.withSize(width: bounds.width * progress,
                               height: bounds.height)
    }
}
