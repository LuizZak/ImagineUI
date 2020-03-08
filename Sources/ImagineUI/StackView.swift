/// A view that lays out a set of its arranged subviews horizontally or
/// vertically automatically
open class StackView: View {
    private var arrangedSubviews: [View] = []
    
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
    
    public init(orientation: Orientation) {
        self.orientation = orientation
        super.init()
    }
    
    private func recreateConstraints() {
        for layoutGuide in layoutGuides {
            removeLayoutGuide(layoutGuide)
        }
        
        var previousGuide: LayoutGuide?
        for (i, view) in arrangedSubviews.enumerated() {
            defer { previousGuide = guide }
            
            let isLastView = i == arrangedSubviews.count - 1
            let guide = LayoutGuide()
            
            addLayoutGuide(guide)
            
            view.layout.makeConstraints { make in
                make.edges == guide
            }
            
            guide.layout.makeConstraints { make in
                switch orientation {
                case .horizontal:
                    make.top == self
                    make.bottom == self
                    
                    if let previous = previousGuide {
                        make.right(of: previous, offset: spacing)
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
                        make.under(previous, offset: spacing)
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
        
        arrangedSubviews.removeAll(where: { $0 === view })
        
        recreateConstraints()
    }
    
    public enum Orientation {
        case vertical
        case horizontal
    }
}
