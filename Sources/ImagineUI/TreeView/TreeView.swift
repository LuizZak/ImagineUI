import Rendering

public class TreeView: ControlView {
    private let _scrollView: ScrollView = ScrollView(scrollBarsMode: .both)
    private let _content: View = View()

    private var _expanded: Set<ItemIndex> = []
    private var _visible: [ItemView] = []

    public weak var dataSource: TreeViewDataSource?

    public override init() {
        super.init()

        backColor = .white
    }

    public override func setupHierarchy() {
        super.setupHierarchy()

        addSubview(_scrollView)
        _scrollView.addSubview(_content)
    }

    public override func setupConstraints() {
        super.setupConstraints()

        _scrollView.layout.makeConstraints { make in
            make.edges == self
        }

        _content.layout.makeConstraints { make in
            (make.left, make.top) == _scrollView.contentView
            make.bottom <= _scrollView.contentView
            make.right <= _scrollView.contentView
        }

        _content.areaIntoConstraintsMask = [.location, .size]
    }
    
    public override func performLayout() {
        super.performLayout()
    }
    
    public override func renderForeground(in renderer: Renderer, screenRegion: ClipRegion) {
        super.renderForeground(in: renderer, screenRegion: screenRegion)
    }

    /// Repopulates the tree view's items.
    public func reloadData() {
        suspendLayout()
        defer {
            resumeLayout(setNeedsLayout: false)
        }

        for view in _visible {
            view.removeFromSuperview()
        }

        _visible.removeAll()

        guard let dataSource = self.dataSource else {
            _content.size = .zero
            return
        }

        let totalSize = _recursiveAddItems(hierarchy: .root, dataSource: dataSource, origin: .zero)
        _content.size = totalSize
    }

    private func _isExpanded(index: ItemIndex) -> Bool {
        return _expanded.contains(index)
    }

    private func _recursiveAddItems(hierarchy: HierarchyIndex, dataSource: TreeViewDataSource, origin: UIPoint) -> UISize {
        let count = dataSource.numberOfItems(at: hierarchy)
        var currentLocation = origin
        var totalArea = UIRectangle(location: origin, size: .zero)

        for index in 0..<count {
            let itemIndex = hierarchy.subItem(index: index)

            let itemView = _makeItemView(itemIndex: itemIndex, dataSource: dataSource)
            itemView.location = currentLocation

            totalArea = totalArea.union(itemView.area)
            currentLocation.y += itemView.size.height

            _visible.append(itemView)
            _content.addSubview(itemView)
        }

        return totalArea.size
    }

    private func _makeItemView(itemIndex: ItemIndex, dataSource: TreeViewDataSource) -> ItemView {
        let itemView = ItemView(index: itemIndex)
        itemView.isChevronVisible = _isExpanded(index: itemIndex)
        itemView.title = dataSource.titleForItem(at: itemIndex)
        itemView.layoutToFit(size: .zero)

        return itemView
    }

    private class ItemView: ControlView {
        private let _chevronView: ChevronView = ChevronView()
        private let _titleView: Label = Label(textColor: .black)

        var index: ItemIndex

        var isChevronVisible: Bool {
            get {
                return _chevronView.isVisible
            }
            set {
                _chevronView.isVisible = newValue
            }
        }

        var isExpanded: Bool {
            get {
                return _chevronView.isExpanded
            }
            set {
                _chevronView.isExpanded = newValue
            }
        }

        var title: String {
            get {
                return _titleView.text
            }
            set {
                _titleView.text = newValue
            }
        }

        init(index: ItemIndex) {
            self.index = index

            super.init()
        }

        override func setupHierarchy() {
            super.setupHierarchy()

            addSubview(_chevronView)
            addSubview(_titleView)
        }

        override func performInternalLayout() {
            super.performInternalLayout()

            _chevronView.size = .init(width: 10, height: 10)

            _chevronView.area.centerY = bounds.centerY

            _titleView.layoutToFit(size: UISize(width: size.width - _titleView.location.x, height: 0))

            _titleView.area = _titleView.area.alignRight(of: _chevronView.area, verticalAlignment: .center)
        }

        override func layoutSizeFitting(size: UISize) -> UISize {
            return withSuspendedLayout(setNeedsLayout: false) {
                let snapshot = LayoutAreaSnapshot.snapshotHierarchy(self)

                performInternalLayout()
                let optimalSize = UIRectangle.union(_chevronView.area, _titleView.area).size

                snapshot.restore()

                return optimalSize
            }
        }

        private class ChevronView: ControlView {
            var isExpanded: Bool = false {
                didSet {
                    if isExpanded != oldValue {
                        setNeedsLayout()
                        invalidateControlGraphics()
                    }
                }
            }

            override var intrinsicSize: UISize? {
                return UISize(width: 10, height: 10)
            }

            override init() {
                super.init()

                foreColor = .gray
                cacheAsBitmap = false
            }

            override func renderForeground(in renderer: Renderer, screenRegion: ClipRegion) {
                let stroke = StrokeStyle(
                    color: foreColor,
                    width: 2,
                    startCap: .round,
                    endCap: .round
                )
                renderer.setStroke(stroke)

                let strokePoints: UIPolygon = UIPolygon(vertices: [
                    UIVector(x: 0, y: 0),
                    UIVector(x: 5, y: 5),
                    UIVector(x: 0, y: 10),
                ]).withCenter(on: bounds.center)

                if isExpanded {
                    renderer.stroke(polyline: strokePoints.rotatedAroundCenter(by: .pi / 2).vertices)
                } else {
                    renderer.stroke(polyline: strokePoints.vertices)
                }
            }
        }
    }
}
