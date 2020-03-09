import Cassowary

/// A view that lays out a set of its arranged subviews horizontally or
/// vertically automatically
open class StackView: View {
    private var arrangedSubviews: [View] = []
    private var customSpacing: [View: Double] = [:]
    
    open var spacing: Double = 0 {
        didSet {
            recreateConstraints()
        }
    }
    
    open var orientation: Orientation {
        didSet {
            recreateConstraints()
        }
    }
    
    open var alignment: Alignment = .leading {
        didSet {
            recreateConstraints()
        }
    }
    
    public init(orientation: Orientation) {
        self.orientation = orientation
        super.init()
    }
    
    private func recreateConstraints() {
        for layoutGuide in layoutGuides {
            removeLayoutGuide(layoutGuide)
        }
        
        var previousGuide: LayoutGuide?
        var previousAfterSpacing: Double?
        for (i, view) in arrangedSubviews.enumerated() {
            defer {
                previousGuide = guide
                previousAfterSpacing = customSpacing[view]
            }
            
            let isLastView = i == arrangedSubviews.count - 1
            let guide = LayoutGuide()
            
            let viewSpacing = previousAfterSpacing ?? spacing
            
            addLayoutGuide(guide)
            
            view.layout.makeConstraints { make in
                switch alignment {
                case .leading:
                    switch orientation {
                    case .horizontal:
                        make.left == guide
                        make.right == guide
                        make.top == guide
                        make.bottom <= guide
                    case .vertical:
                        make.top == guide
                        make.bottom == guide
                        make.left == guide
                        make.right <= guide
                    }
                    
                case .trailing:
                    switch orientation {
                    case .horizontal:
                        make.left == guide
                        make.right == guide
                        make.top >= guide
                        make.bottom == guide
                    case .vertical:
                        make.top == guide
                        make.bottom == guide
                        make.width <= guide
                        make.right == guide
                    }
                    
                case .fill:
                    make.edges == guide
                
                case .centered:
                    switch orientation {
                    case .horizontal:
                        make.left == guide
                        make.height <= guide
                        make.centerY == guide
                        make.right == guide
                        
                    case .vertical:
                        make.top == guide
                        make.width <= guide
                        make.centerX == guide
                        make.bottom == guide
                    }
                }
            }
            
            guide.layout.makeConstraints { make in
                switch orientation {
                case .horizontal:
                    make.top == self
                    make.bottom == self
                    
                    if let previous = previousGuide {
                        make.right(of: previous, offset: viewSpacing)
                    } else {
                        make.left == self
                    }
                    if isLastView {
                        make.right == self
                    }
                default:
                    make.left == self
                    make.right == self
                    
                    if let previous = previousGuide {
                        make.under(previous, offset: viewSpacing)
                    } else {
                        make.top == self
                    }
                    if isLastView {
                        make.bottom == self
                    }
                }
            }
        }
    }
    
    open func addArrangedSubview(_ view: View) {
        if arrangedSubviews.contains(view) {
            return
        }
        
        arrangedSubviews.append(view)
        addSubview(view)
        
        recreateConstraints()
    }
    
    open override func willRemoveSubview(_ view: View) {
        super.willRemoveSubview(view)
        
        customSpacing.removeValue(forKey: view)
        arrangedSubviews.removeAll(where: { $0 === view })
        
        recreateConstraints()
    }
    
    open func setCustomSpacing(after view: View, _ spacing: Double?) {
        customSpacing[view] = spacing
    }
    
    public enum Orientation {
        case vertical
        case horizontal
    }
    
    public enum Alignment {
        case leading
        case trailing
        case fill
        case centered
    }
}
