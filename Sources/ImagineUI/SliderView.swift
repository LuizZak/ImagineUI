import SwiftBlend2D

public class SliderView: ControlView {
    private var isMouseDown = false
    private var mouseDownOffset = Vector2.zero
    
    private var knobSize = Size(x: 11, y: 19)
    private var knobTop = 2.0
    private var knobDip = 5.0
    private var knobPath = BLPath()
    
    public var minimumValue: Double = 0 {
        didSet {
            if minimumValue == oldValue {
                return
            }
            
            if minimumValue > maximumValue {
                minimumValue = maximumValue
            }
            
            limitValue()
            
            invalidateControlGraphics()
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
            
            limitValue()
            
            invalidateControlGraphics()
        }
    }
    
    public var value: Double = 0 {
        didSet {
            if value == oldValue {
                return
            }
            
            limitValue()
            
            if value != oldValue {
                onValueChanged(ValueChangedEventArgs<Double>(oldValue: oldValue, newValue: value))
            }
            
            invalidateControlGraphics()
        }
    }
    
    /// Event fired whenever `value` is changed
    @Event public var valueChanged: ValueChangeEvent<SliderView, Double>
    
    public override var intrinsicSize: Size? {
        return Size(x: bounds.width, y: knobSize.y)
    }
    
    public override init() {
        super.init()
        
        createKnobPath()
        
        mouseOverHighlight = false
    }
    
    public func onValueChanged(_ event: ValueChangedEventArgs<Double>) {
        _valueChanged.publishEvent(sender: self, event)
    }
    
    public override func onStateChanged(_ event: ValueChangedEventArgs<ControlViewState>) {
        super.onStateChanged(event)
        
        invalidateControlGraphics()
    }
    
    public override func onMouseMove(_ event: MouseEventArgs) {
        super.onMouseMove(event)
        
        isHighlighted = knobArea().contains(event.location)
        
        if isMouseDown {
            let offset = event.location + mouseDownOffset
            value = valueAtOffset(x: offset.x)
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
    
    private func limitValue() {
        value = max(minimumValue, min(maximumValue, value))
    }
    
    private func createKnobPath() {
        knobPath.clear()
        knobPath.moveTo(x: 0, y: knobTop)
        knobPath.lineTo(x: knobSize.x, y: knobTop)
        knobPath.lineTo(x: knobSize.x, y: knobSize.y - knobDip)
        knobPath.lineTo(x: knobSize.x / 2, y: knobSize.y)
        knobPath.lineTo(x: 0, y: knobSize.y - knobDip)
        knobPath.close()
    }
    
    public override func renderBackground(in context: BLContext) {
        super.renderBackground(in: context)
        
        let left = BLPoint(x: knobSize.x / 2, y: size.y / 2)
        let right = BLPoint(x: size.x - knobSize.x / 2, y: size.y / 2)
        let endsHeight = 3.0
        
        context.setStrokeStyle(BLRgba32.lightGray)
        context.setStrokeWidth(2)
        context.strokeLine(p0: left, p1: right)
        context.strokeLine(p0: left - BLPoint(x: 0, y: endsHeight), p1: left + BLPoint(x: 0, y: endsHeight))
        context.strokeLine(p0: right - BLPoint(x: 0, y: endsHeight), p1: right + BLPoint(x: 0, y: endsHeight))
    }
    
    public override func renderForeground(in context: BLContext) {
        super.renderForeground(in: context)
        
        renderKnob(in: context)
    }
    
    private func renderKnob(in context: BLContext) {
        context.translate(x: knobOffset(), y: 0)
        
        var color = BLRgba32.royalBlue
        if currentState == .highlighted {
            color = color.faded(towards: .white, factor: 0.2)
        }
        
        context.setFillStyle(color)
        context.setStrokeStyle(BLRgba32.white)
        context.fillPath(knobPath)
        context.setStrokeWidth(1)
        context.strokePath(knobPath)
        
        // Stroke two dashes within the knob's area
        let dash1x = knobSize.x / 3
        let dash2x = knobSize.x / 3 * 2
        let dashY = knobTop + 3
        let dashH = knobSize.y / 3
        
        context.setStrokeStyle(BLRgba32.royalBlue.faded(towards: .white, factor: 0.5))
        context.strokeLine(x0: dash1x, y0: dashY, x1: dash1x, y1: dashY + dashH)
        context.strokeLine(x0: dash2x, y0: dashY, x1: dash2x, y1: dashY + dashH)
    }
    
    private func knobArea() -> Rectangle {
        let x = knobOffset()
        
        return Rectangle(x: x, y: 0, width: knobSize.x, height: knobSize.y)
    }
    
    private func knobOffset() -> Double {
        let rate = (value - minimumValue) / (maximumValue - minimumValue)
        return rate * (size.x - knobSize.x)
    }
    
    private func valueAtOffset(x: Double) -> Double {
        let xOffset = (x - knobSize.x / 2) / (size.x - knobSize.x)
        return minimumValue + xOffset * (maximumValue - minimumValue)
    }
}
