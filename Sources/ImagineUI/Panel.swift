import SwiftBlend2D

/// A container control that places components within an outlined panel area
public class Panel: ControlView {
    public let label: Label
    public let containerView: View

    public var title: String {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    public var containerInset: EdgeInsets = EdgeInsets(top: 0, left: 4, bottom: 4, right: 4) {
        didSet {
            updateConstraints()
        }
    }

    public init(title: String) {
        containerView = View()
        label = Label()
        label.text = title
        super.init()
        clipToBounds = false
        strokeWidth = 1
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        super.addSubview(containerView)
        super.addSubview(label)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        label.layout.makeConstraints { make in
            make.top.equalTo(self)
            make.left.equalTo(self, offset: 8)
        }

        containerView.layout.makeConstraints { make in
            make.top.equalTo(label.layout.bottom, offset: containerInset.top)
            make.left.equalTo(self, offset: containerInset.left)
            make.right.equalTo(self, offset: -containerInset.right)
            make.bottom.equalTo(self, offset: -containerInset.bottom)
        }

        updateConstraints()
    }

    private func updateConstraints() {
        containerView.layout.updateConstraints { make in
            make.top.equalTo(label.layout.bottom, offset: containerInset.top)
            make.left.equalTo(self, offset: containerInset.left)
            make.right.equalTo(self, offset: -containerInset.right)
            make.bottom.equalTo(self, offset: -containerInset.bottom)
        }
    }

    public override func addSubview(_ view: View) {
        containerView.addSubview(view)
    }

    public override func renderBackground(in context: BLContext) {
        super.renderBackground(in: context)

        renderBorder(in: context)
    }

    private func renderBorder(in context: BLContext) {
        // Create a clipping region for the borders
        var region = BLRegion(rectangle: BLRectI(rounding: boundsForRedraw().inflatedBy(x: 1, y: 1).asBLRect))

        let labelBounds = label.boundsForRedrawOnSuperview().insetBy(x: -4, y: -4)

        // Subtract from the borders region the bounds for the label
        region.combine(box: BLRectI(rounding: labelBounds.asBLRect).asBLBoxI,
                       operation: .sub)

        var borderBounds = bounds
        borderBounds.minimum.y = labelBounds.center.y

        let roundRect = BLRoundRect(rect: borderBounds.asBLRect,
                                    radius: BLPoint(x: 4, y: 4))

        context.setStrokeStyle(BLRgba32.white)
        context.setStrokeWidth(strokeWidth)
        context.save()

        // Use the region scans from the clipping region to clip the borders as
        // we draw them. This should result in a complete border around the view
        // which clips under the label
        for scan in region.regionScans {
            context.clipToRect(scan.asBLRectI)
            context.strokeRoundRect(roundRect)
            context.restoreClipping()
        }
    }
}

extension Panel: RadioButtonManagerType { }
