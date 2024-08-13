import Geometry
import Rendering

public class SliderView: ControlView {
    private var isMouseDown = false
    private var mouseDownOffset = UIVector.zero
    private var leftLabel = Label(textColor: .white)
    private var rightLabel = Label(textColor: .white)

    private var knobSize = UISize(width: 11, height: 19)
    private var knobTop = 2.0
    private var knobDip = 5.0
    private var knobPoly = UIPolygon()

    public var minimumValue: Double = 0 {
        didSet {
            if minimumValue == oldValue {
                return
            }

            if minimumValue > maximumValue {
                minimumValue = maximumValue
            }

            value = limitValue(value)
            updateLabels()

            invalidate()
        }
    }
    public var maximumValue: Double = 1 {
        didSet {
            if maximumValue == oldValue {
                return
            }

            if maximumValue < minimumValue {
                maximumValue = minimumValue
            }

            value = limitValue(value)
            updateLabels()

            invalidate()
        }
    }

    /// An interval that values from this slider snap to when the user tracks the
    /// control.
    /// `value` is limited to be multiples of this value, except if `value` is
    /// equal to `minimumValue` or `maximumValue`
    /// Specify a value of 0 for no stepping behavior (aka allow any value).
    ///
    /// Defaults to 0
    public var stepValue: Double = 0 {
        didSet {
            value = limitValue(value)
            invalidate()
        }
    }

    public var value: Double = 0 {
        didSet {
            if limitValue(value) == oldValue {
                return
            }

            value = limitValue(value)

            onValueChanged(.init(oldValue: oldValue, newValue: value))

            invalidate()
        }
    }

    /// Whether to show labels for minimum and maximum values
    public var showLabels: Bool = false {
        didSet {
            if showLabels == oldValue { return }

            updateLabels()
            updateLabelConstraints()
            setNeedsLayout()
            invalidate()
        }
    }

    /// A formatter function that is used to format the minimum and maximum values
    /// for the left and right labels
    public var labelFormat: (Double) -> String = { String(format: "%0.lf", $0) } {
        didSet {
            updateLabels()
        }
    }

    /// Event fired whenever `value` is changed
    @ValueChangedEventWithSender<SliderView, Double>
    public var valueChanged

    public override var intrinsicSize: IntrinsicSize {
        return .height(knobSize.height)
    }

    public override init() {
        super.init()

        initialize()

        mouseOverHighlight = false
    }

    private func initialize() {
        createKnobPath()
    }

    private func createKnobPath() {
        knobPoly.addVertex(x: 0, y: knobTop)
        knobPoly.addVertex(x: knobSize.width, y: knobTop)
        knobPoly.addVertex(x: knobSize.width, y: knobSize.height - knobDip)
        knobPoly.addVertex(x: knobSize.width / 2, y: knobSize.height)
        knobPoly.addVertex(x: 0, y: knobSize.height - knobDip)
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(leftLabel)
        addSubview(rightLabel)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        updateLabelConstraints()
    }

    private func setupLabelConstraints() {
        leftLabel.layout.makeConstraints { make in
            make.top == self + knobSize.height
            make.left == self + 2
            make.bottom == self
        }
        rightLabel.layout.makeConstraints { make in
            make.top == self + knobSize.height
            make.right == self - 2
            make.bottom == self
        }
    }

    public override func boundsForRedraw() -> UIRectangle {
        return bounds.inflatedBy(x: 2, y: 0)
    }

    public func onValueChanged(_ event: ValueChangedEventArgs<Double>) {
        _valueChanged(sender: self, event)
    }

    public override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)

        invalidate()
    }

    public override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)

        isHighlighted = knobArea().contains(event.location)

        if isMouseDown {
            let offset = event.location + mouseDownOffset
            value = limitValue(valueAtOffset(x: offset.x))
        }
    }

    public override func onMouseDown(_ event: MouseEventArgs) {
        super.onMouseDown(event)

        if knobArea().contains(event.location) {
            isMouseDown = true
            isSelected = true
            mouseDownOffset = knobArea().center - event.location
        }
    }

    public override func onMouseUp(_ event: MouseEventArgs) {
        super.onMouseUp(event)

        isMouseDown = false
        isSelected = false
    }

    public override func onMouseLeave() {
        super.onMouseLeave()

        isHighlighted = false
    }

    private func updateLabelConstraints() {
        if !showLabels {
            leftLabel.layout.remakeConstraints { _ in }
            rightLabel.layout.remakeConstraints { _ in }
            return
        }

        setupLabelConstraints()
    }

    private func updateLabels() {
        if !showLabels {
            leftLabel.isVisible = false
            rightLabel.isVisible = false
            return
        }

        leftLabel.isVisible = true
        rightLabel.isVisible = true
        leftLabel.text = labelFormat(minimumValue)
        rightLabel.text = labelFormat(maximumValue)
    }

    private func limitValue(_ value: Double) -> Double {
        var value = value
        let stepped: Double

        if stepValue > 0 {
            stepped = (value / stepValue).rounded() * stepValue
        } else {
            stepped = value
        }

        value = max(minimumValue, min(maximumValue, stepped))

        return value
    }

    public override func renderBackground(in renderer: Renderer, screenRegion: ClipRegionType) {
        super.renderBackground(in: renderer, screenRegion: screenRegion)

        let line = sliderLine()
        let endsHeight = 3.0

        renderer.setStroke(.lightGray)
        renderer.setStrokeWidth(2)
        renderer.stroke(line)
        renderer.strokeLine(start: line.start - UIVector(x: 0, y: endsHeight),
                            end: line.start + UIVector(x: 0, y: endsHeight))
        renderer.strokeLine(start: line.end - UIVector(x: 0, y: endsHeight),
                            end: line.end + UIVector(x: 0, y: endsHeight))
    }

    public override func renderForeground(in renderer: Renderer, screenRegion: ClipRegionType) {
        super.renderForeground(in: renderer, screenRegion: screenRegion)

        renderKnob(in: renderer)
    }

    private func renderKnob(in renderer: Renderer) {
        renderer.translate(x: knobOffset(), y: 0)

        var color: Color = .royalBlue
        if controlState == .highlighted {
            color = color.faded(towards: .white, factor: 0.2)
        }

        renderer.setFill(color)
        renderer.setStroke(.white)
        renderer.fill(knobPoly)
        renderer.setStrokeWidth(1)
        renderer.stroke(knobPoly)

        // Stroke two dashes within the knob's area
        let dash1x = knobSize.width / 3
        let dash2x = knobSize.width / 3 * 2
        let dashY = knobTop + 3
        let dashH = knobSize.height / 3

        renderer.setStroke(.royalBlue.faded(towards: .white, factor: 0.5))
        renderer.strokeLine(start: UIVector(x: dash1x, y: dashY), end: UIVector(x: dash1x, y: dashY + dashH))
        renderer.strokeLine(start: UIVector(x: dash2x, y: dashY), end: UIVector(x: dash2x, y: dashY + dashH))
    }

    private func knobArea() -> UIRectangle {
        let x = knobOffset()

        return UIRectangle(x: x, y: 0, width: knobSize.width, height: knobSize.height)
    }

    private func sliderLine() -> UILine {
        let left = knobSize.asUIPoint / 2
        let right = UIVector(x: size.width - knobSize.width / 2, y: knobSize.height / 2)

        return UILine(start: left, end: right)
    }

    private func knobOffset() -> Double {
        let rate = (value - minimumValue) / (maximumValue - minimumValue)
        return rate * (size.width - knobSize.width)
    }

    private func valueAtOffset(x: Double) -> Double {
        let line = sliderLine()

        let xOffset = (x - line.start.x) / line.length()
        return minimumValue + xOffset * (maximumValue - minimumValue)
    }
}
