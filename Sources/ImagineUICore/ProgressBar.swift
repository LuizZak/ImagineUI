import Geometry
import Rendering

public class ProgressBar: ControlView {
    public var progress: Double = 0 {
        didSet {
            progress = min(1, max(0, progress))
            invalidateControlGraphics()
        }
    }

    public override var intrinsicSize: UISize? {
        return UISize(width: bounds.width, height: 5)
    }

    public override init() {
        super.init()
        backColor = .lightGray
        strokeColor = .lightGray
        strokeWidth = 1
        foreColor = .royalBlue
    }

    public override func renderBackground(in context: Renderer, screenRegion: ClipRegionType) {
        let rect = progressBarRoundRect()

        context.setFill(backColor)
        context.fill(rect)

        let state = context.saveState()
        context.clip(boundsForCurrentProgress())

        context.setFill(foreColor)
        context.fill(rect)
        context.restoreState(state)

        context.setStroke(strokeColor)
        context.setStrokeWidth(strokeWidth)
        context.stroke(rect)
    }

    func progressBarRoundRect() -> UIRoundRectangle {
        let rect = progressBarBounds()
        return rect.makeRoundedRectangle(radius: UIVector(x: rect.height / 2, y: rect.height / 2))
    }

    func progressBarBounds() -> UIRectangle {
        return bounds
    }

    func boundsForCurrentProgress() -> UIRectangle {
        let bounds = progressBarBounds()
        return bounds.withSize(width: bounds.width * progress,
                               height: bounds.height)
    }
}
