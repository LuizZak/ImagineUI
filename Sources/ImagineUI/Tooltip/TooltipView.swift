/// A view used to display auxiliary information.
public class TooltipView: ControlView {
    private let _label: Label = Label(textColor: .white)
    private let _contentInset: UIEdgeInsets = UIEdgeInsets(8)

    public override init() {
        super.init()

        backColor = Color(red: 37, green: 37, blue: 38)
        strokeColor = .transparentBlack
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(_label)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        _label.layout.makeConstraints { make in
            make.edges.equalTo(self, inset: _contentInset)
        }
    }

    public func update(_ tooltip: Tooltip) {
        _label.attributedText = tooltip.text
    }
}
