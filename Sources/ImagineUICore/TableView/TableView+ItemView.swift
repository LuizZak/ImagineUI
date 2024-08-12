import Text

extension TableView {
    class ItemView: ControlView {
        var cellViews: [CellView]

        init(cellViews: [CellView]) {
            self.cellViews = cellViews

            super.init()
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            for cellView in cellViews {
                addSubview(cellView)
            }
        }

        override func hasIndependentInternalLayout() -> Bool {
            return true
        }

        func loadCells(_ labels: [AttributedText]) {
            cellViews.forEach {
                $0.removeFromSuperview()
            }

            cellViews = labels.map { CellView(attributedText: $0) }

            cellViews.forEach {
                addSubview($0)
            }
        }

        func _doBoxLayout() {

        }

        class CellView: ControlView {
            let label: Label = Label(textColor: .white)

            var attributedText: AttributedText {
                get { label.attributedText }
                set { label.attributedText = newValue }
            }

            init(attributedText: AttributedText) {
                self.label.attributedText = attributedText

                super.init()
            }
        }
    }
}
