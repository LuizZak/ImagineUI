import Geometry
import Text

extension TableView {
    class TableHeader: View {
        let stackView: StackView = .init(orientation: .horizontal)
        let entries: [Entry]

        var entryViews: [EntryView] = []

        init(entries: [Entry]) {
            self.entries = entries

            super.init()
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            for entry in entries {
                let view = EntryView(entry: entry)
                stackView.addArrangedSubview(view)
                entryViews.append(view)
            }

            addSubview(stackView)
        }

        override func setupConstraints() {
            super.setupConstraints()

            stackView.layout.makeConstraints { make in
                make.edges == self
            }
        }

        class EntryView: ControlView {
            let entry: Entry
            let label: Label = Label(textColor: .white)
            let contentInset: UIEdgeInsets = .init(left: 8, top: 4, right: 8, bottom: 4)

            override var intrinsicSize: View.IntrinsicSize {
                .size(UISize(width: entry.width, height: 14))
            }

            init(entry: Entry) {
                self.entry = entry
                label.attributedText = entry.title

                super.init()
            }

            override func setupHierarchy() {
                super.setupHierarchy()

                addSubview(label)
            }

            override func setupConstraints() {
                super.setupConstraints()

                label.layout.makeConstraints { make in
                    make.edges.equalTo(self, inset: contentInset)
                    make.width <= entry.width
                }
            }
        }

        struct Entry {
            var title: AttributedText
            var width: Double
        }
    }
}
