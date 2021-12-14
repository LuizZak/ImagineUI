/// A view used to display auxiliary information.
public class TooltipView: ControlView {
    private let _label: Label = Label(textColor: .white)

    /// Inset from the bounds of the tooltip view to its contents.
    var contentInset: UIEdgeInsets = UIEdgeInsets(8) {
        didSet {
            _label.layout.updateConstraints { make in
                make.edges.equalTo(self, inset: contentInset)
            }
        }
    }

    public override init() {
        super.init()

        backColor = Color(red: 37, green: 37, blue: 38)
        strokeColor = .lightGray
        strokeWidth = 1
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(_label)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        _label.setContentCompressionResistance(.horizontal, .required)
        _label.setContentCompressionResistance(.vertical, .required)
        _label.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: contentInset)
        }
    }

    public func update(_ tooltip: Tooltip) {
        _label.attributedText = tooltip.text
    }
}
