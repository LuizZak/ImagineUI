import Geometry
import Text

/// A message dialog containing a message label and buttons.
public class MessageBoxDialog: Window {
    let messageLabel: Label = .init(textColor: .white)
    let buttonsStackView: StackView = .init(orientation: .horizontal)
    let buttonEntries: [ButtonEntry]

    let contentInset: UIEdgeInsets = .init(left: 4, top: 8, right: 4, bottom: 8)

    /// The delegate associated with this message box dialog view.
    public var dialogDelegate: UIDialogDelegate?

    public init(message: AttributedText, title: String, buttons: [ButtonEntry]) {
        self.messageLabel.attributedText = message
        self.messageLabel.horizontalTextAlignment = .center
        self.messageLabel.verticalTextAlignment = .center
        self.messageLabel.setContentHuggingPriority(.vertical, .lowest)
        self.buttonEntries = buttons

        super.init(area: .zero, title: title)

        self.setShouldCompress(true)
        self.areaIntoConstraintsMask = [.location]
        self.enabledButtons = []
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        self.suspendLayout()
        defer { self.resumeLayout(setNeedsLayout: true) }

        addSubview(messageLabel)
        addSubview(buttonsStackView)

        for buttonEntry in buttonEntries {
            let button = makeButton(buttonEntry)

            buttonsStackView.addArrangedSubview(button)
        }
    }

    public override func setupConstraints() {
        super.setupConstraints()

        self.suspendLayout()
        defer { self.resumeLayout(setNeedsLayout: true) }

        messageLabel.layout.makeConstraints { make in
            make.left == self.contentsLayoutArea + contentInset.left
            make.top == self.contentsLayoutArea + contentInset.top
            make.right == self.contentsLayoutArea - contentInset.right
            make.bottom == buttonsStackView.layout.top - 10
        }

        buttonsStackView.layout.makeConstraints { make in
            make.bottom == self.contentsLayoutArea - contentInset.bottom
            make.left >= self.contentsLayoutArea + contentInset.left
            make.right <= self.contentsLayoutArea - contentInset.right
            make.centerX == (self.contentsLayoutArea + (contentInset.left - contentInset.right))
        }
    }

    func makeButton(_ entry: ButtonEntry) -> Button {
        let button: Button

        switch entry {
        case .close(let title, let action):
            button = Button(title: "")
            button.label.attributedText = title
            button.mouseClicked.addWeakListener(self) { (self, _) in
                action()

                self.dialogDelegate?.dialogWantsToClose(self)
            }
        }

        return button
    }

    /// A button in a message dialog.
    public enum ButtonEntry {
        /// A button that closes the message dialog.
        case close(AttributedText, () -> Void = { })
    }
}

extension MessageBoxDialog: UIDialog {
    public func didOpen() {
    }

    public func didClose() {
    }
}
