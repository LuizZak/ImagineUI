import Foundation
import QuartzCore
import SwiftBlend2D
import ImagineUI
import CassowarySwift
import Cocoa
import Blend2DRenderer

private class DataSource: TreeView.DataSource {
    func hasSubItems(at index: TreeView.ItemIndex) -> Bool {
        if index.asHierarchyIndex.indices == [2] {
            return true
        }
        if index.asHierarchyIndex.isSubHierarchy(of: .init(indices: [2, 0])) {
            return true
        }

        return false
    }

    func numberOfItems(at hierarchyIndex: TreeView.HierarchyIndex) -> Int {
        if hierarchyIndex.isRoot {
            return 10
        }
        if hierarchyIndex.indices == [2] {
            return 2
        }
        if hierarchyIndex.isSubHierarchy(of: .init(indices: [2, 0])) {
            return 1
        }

        return 0
    }

    func titleForItem(at index: TreeView.ItemIndex) -> AttributedText {
        if !index.parent.isRoot {
            return "Item \(index.parent.indices.map { "\($0 + 1)" }.joined(separator: " -> ")) -> \(index.index + 1)"
        }
        
        return "Item \(index.index + 1)"
    }
}

class TreeSampleWindow: ImagineUIWindowContent {
    private let data: DataSource = DataSource()

    let rendererContext = Blend2DRendererContext()

    var sampleRenderScale = BLPoint(x: 2, y: 2)

    var currentRedrawRegion: UIRectangle? = nil

    init(size: BLSizeI) {
        super.init(size: UIIntSize(width: Int(size.w), height: Int(size.h)))

        initializeWindows()
    }

    func initializeWindows() {
        let window =
            Window(area: UIRectangle(x: 50, y: 120, width: 320, height: 330),
                   title: "Window")
        window.delegate = self
        window.areaIntoConstraintsMask = [.location]
        window.rootControlSystem = controlSystem
        window.invalidationDelegate = self

        let tree = TreeView()
        tree.dataSource = data
        tree.reloadData()

        window.addSubview(tree)

        LayoutConstraint.create(first: window.layout.height,
                                relationship: .greaterThanOrEqual,
                                offset: 100)

        tree.layout.makeConstraints { make in
            make.edges == window.contentsLayoutArea - 12
        }

        window.performLayout()

        createRenderSettingsWindow()

        addRootView(window)
    }
    
    func createRenderSettingsWindow() {
        func toggleFlag(_ sample: TreeSampleWindow,
                        _ flag: DebugDraw.DebugDrawFlags,
                        _ event: CancellableValueChangedEventArgs<Checkbox.State>) {

            if event.newValue == .checked {
                sample.debugDrawFlags.insert(flag)
            } else {
                sample.debugDrawFlags.remove(flag)
            }

            sample.invalidateScreen()
        }

        let window = Window(area: .zero, title: "Debug render settings")
        window.delegate = self
        window.areaIntoConstraintsMask = [.location]
        window.setShouldCompress(true)
        window.rootControlSystem = controlSystem
        window.invalidationDelegate = self

        let boundsCheckbox = Checkbox(title: "View Bounds")
        let layoutCheckbox = Checkbox(title: "Layout Guides")
        let constrCheckbox = Checkbox(title: "Constraints")
        let stackView = StackView(orientation: .vertical)
        stackView.spacing = 4

        stackView.addArrangedSubview(boundsCheckbox)
        stackView.addArrangedSubview(layoutCheckbox)
        stackView.addArrangedSubview(constrCheckbox)

        window.addSubview(stackView)

        stackView.layout.makeConstraints { make in
            make.left == window.contentsLayoutArea + 12
            make.top == window.contentsLayoutArea + 12
            make.bottom <= window.contentsLayoutArea - 12
            make.right <= window.contentsLayoutArea - 12
        }

        boundsCheckbox.checkboxStateWillChange.addWeakListener(self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .viewBounds, event.args)
        }
        layoutCheckbox.checkboxStateWillChange.addWeakListener(self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .layoutGuideBounds, event.args)
        }
        constrCheckbox.checkboxStateWillChange.addWeakListener(self) { [weak self] (_, event) in
            guard let self = self else { return }

            toggleFlag(self, .constraints, event.args)
        }

        addRootView(window)
    }
}
