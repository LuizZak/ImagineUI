import Geometry
import SwiftBlend2D
import Rendering

/// A container control that places components within an outlined panel area
public class Panel: ControlView {
    let label: Label
    
    var isTitleVisible: Bool {
        return !title.isEmpty
    }
    
    /// Layout guide representing the area of the panel that subviews can be laid
    /// out safely without colliding with the panel's label
    public let containerLayoutGuide = LayoutGuide()

    public var title: String {
        get {
            return label.text
        }
        set {
            label.text = newValue
            updateConstraints()
        }
    }

    /// The inset from the edges `containerLayoutGuide` inhabits.
    /// The upper bounds of the container is always connected to the bottom of
    /// the panel's label, if `!title.isEmpty`, otherwise, the top edge relates
    /// to the panel's own top edge.
    public var containerInset: EdgeInsets = EdgeInsets(top: 4, left: 8, bottom: 8, right: 8) {
        didSet {
            updateConstraints()
        }
    }

    public init(title: String) {
        label = Label()
        label.text = title
        super.init()
        clipToBounds = false
        strokeWidth = 1
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(label)
        addLayoutGuide(containerLayoutGuide)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        label.layout.makeConstraints { make in
            make.top == self
            make.left == self + 8
        }

        updateConstraints()
    }

    private func updateConstraints() {
        containerLayoutGuide.layout.remakeConstraints { make in
            if isTitleVisible {
                make.top == label.layout.bottom + containerInset.top
            } else {
                make.top == self + containerInset.top
            }
            
            make.left == self + containerInset.left
            make.right == self - containerInset.right
            make.bottom == self - containerInset.bottom
        }
    }

    public override func renderBackground(in context: Renderer, screenRegion: ClipRegion) {
        super.renderBackground(in: context, screenRegion: screenRegion)

        renderBorder(in: context)
    }

    private func renderBorder(in renderer: Renderer) {
        let labelBounds = label.boundsForRedrawOnSuperview().insetBy(x: -4, y: -4)
        
        var borderBounds = bounds
        
        if isTitleVisible {
            borderBounds.minimum.y = labelBounds.center.y
        }
        
        let roundRect = borderBounds.rounded(radius: 4)
        
        renderer.setStroke(.white)
        renderer.setStrokeWidth(strokeWidth)
        // context.save()
        
        if title.isEmpty {
            renderer.stroke(roundRect)
            return
        }
        
        // Create a clipping region for the borders
        var region = renderer.context.createRegion()
        
        region.combine(boundsForRedraw().inflatedBy(x: 1, y: 1), operation: .or)
        
        // Subtract from the borders region the bounds for the label
        region.combine(labelBounds, operation: .subtract)
        
        // Use the region scans from the clipping region to clip the borders as
        // we draw them. This should result in a complete border around the view
        // which clips under the label
        for scan in region.scans() {
            renderer.clip(scan)
            renderer.stroke(roundRect)
            renderer.restoreClipping()
        }
    }
}

extension Panel: RadioButtonManagerType { }
